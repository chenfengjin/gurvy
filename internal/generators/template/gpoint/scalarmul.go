package gpoint

const ScalarMul = `
// ScalarMul multiplies a by scalar
// algorithm: a special case of Pippenger described by Bootle:
// https://jbootle.github.io/Misc/pippenger.pdf
func (p *{{.PName}}Jac) ScalarMul(curve *Curve, a *{{.PName}}Jac, scalar {{.GroupType}}.Element) *{{.PName}}Jac {
	// see MultiExp and pippenger documentation for more details about these constants / variables
	const s = 4
	const b = s
	const TSize = (1 << b) - 1
	var T [TSize]{{.PName}}Jac
	computeT := func(T []{{.PName}}Jac, t0 *{{.PName}}Jac) {
		T[0].Set(t0)
		for j := 1; j < (1<<b)-1; j = j + 2 {
			T[j].Set(&T[j/2]).Double()
			T[j+1].Set(&T[(j+1)/2]).Add(curve, &T[j/2])
		}
	}
	return p.pippenger(curve, []{{.PName}}Jac{*a}, []{{.GroupType}}.Element{scalar}, s, b, T[:], computeT)
}
// ScalarMulByGen multiplies curve.{{toLower .PName}}Gen by scalar
// algorithm: a special case of Pippenger described by Bootle:
// https://jbootle.github.io/Misc/pippenger.pdf
func (p *{{.PName}}Jac) ScalarMulByGen(curve *Curve, scalar {{.GroupType}}.Element) *{{.PName}}Jac {
	computeT := func(T []{{.PName}}Jac, t0 *{{.PName}}Jac) {}
	return p.pippenger(curve, []{{.PName}}Jac{curve.{{toLower .PName}}Gen}, []{{.GroupType}}.Element{scalar}, sGen, bGen, curve.tGen{{.PName}}[:], computeT)
}
`

const MultiExp = `
// MultiExp complexity O(n)
func (p *{{.PName}}Jac) MultiExp(curve *Curve, points []{{.PName}}Affine, scalars []{{.GroupType}}.Element) chan {{.PName}}Jac {
	nbPoints := len(points)
	debug.Assert(nbPoints == len(scalars))

	chRes := make(chan {{.PName}}Jac, 1)

	// under 50 points, the windowed multi exp performs better
	const minPoints = 50 
	if nbPoints <= minPoints {
		_points := make([]{{.PName}}Jac, len(points))
		for i := 0; i < len(points); i++ {
			points[i].ToJacobian(&_points[i])
		}
		go func() {
			p.WindowedMultiExp(curve, _points, scalars)
			chRes <- *p
		}()
		return chRes
	}

	// empirical values
	var nbChunks, chunkSize int
	var mask uint64
	if nbPoints <= 10000 {
		chunkSize = 8
	} else if nbPoints <= 80000 {
		chunkSize = 11
	} else if nbPoints <= 400000 {
		chunkSize = 13
	} else if nbPoints <= 800000 {
		chunkSize = 14
	} else {
		chunkSize = 16
	}

	const sizeScalar = {{.GroupType}}.ElementLimbs * 64

	var bitsForTask [][]int
	if sizeScalar%chunkSize == 0 {
		counter := sizeScalar - 1
		nbChunks = sizeScalar / chunkSize
		bitsForTask = make([][]int, nbChunks)
		for i := 0; i < nbChunks; i++ {
			bitsForTask[i] = make([]int, chunkSize)
			for j := 0; j < chunkSize; j++ {
				bitsForTask[i][j] = counter
				counter--
			}
		}
	} else {
		counter := sizeScalar - 1
		nbChunks = sizeScalar/chunkSize + 1
		bitsForTask = make([][]int, nbChunks)
		for i := 0; i < nbChunks; i++ {
			if i < nbChunks-1 {
				bitsForTask[i] = make([]int, chunkSize)
			} else {
				bitsForTask[i] = make([]int, sizeScalar%chunkSize)
			}
			for j := 0; j < chunkSize && counter >= 0; j++ {
				bitsForTask[i][j] = counter
				counter--
			}
		}
	}

	accumulators := make([]{{.PName}}Jac, nbChunks)
	chIndices := make([]chan struct{}, nbChunks)
	chPoints := make([]chan struct{}, nbChunks)
	for i := 0; i < nbChunks; i++ {
		chIndices[i] = make(chan struct{}, 1)
		chPoints[i] = make(chan struct{}, 1)
	}

	mask = (1 << chunkSize) - 1
	nbPointsPerSlots := nbPoints / int(mask)
	// [][] is more efficient than [][][] for storage, elements are accessed via i*nbChunks+k
	indices := make([][]int, int(mask)*nbChunks) 
	for i := 0; i < int(mask)*nbChunks; i++ {
		indices[i] = make([]int, 0, nbPointsPerSlots)
	}

	// if chunkSize=8, nbChunks=32 (the scalars are chunkSize*nbChunks bits long)
	// for each 32 chunk, there is a list of 2**8=256 list of indices
	// for the i-th chunk, accumulateIndices stores in the k-th list all the indices of points
	// for which the i-th chunk of 8 bits is equal to k 
	accumulateIndices := func(cpuID, nbTasks, n int) {
		for i := 0; i < nbTasks; i++ {
			task := cpuID + i*n
			idx := task*int(mask)-1
			for j := 0; j < nbPoints; j++ {
				val := 0
				for k := 0; k < len(bitsForTask[task]); k++ {
					val = val << 1
					c := bitsForTask[task][k] / int(64)
					o := bitsForTask[task][k] % int(64)
					b := (scalars[j][c] >> o) & 1
					val += int(b)
				}
				if val != 0 {
					indices[idx+int(val)] = append(indices[idx+int(val)], j)
				}
			}
			chIndices[task] <- struct{}{}
			close(chIndices[task])
		}
	}

	// if chunkSize=8, nbChunks=32 (the scalars are chunkSize*nbChunks bits long)
	// for each chunk, sum up elements in index 0, add to current result, sum up elements
	// in index 1, add to current result, etc, up to 255=2**8-1
	accumulatePoints := func(cpuID, nbTasks, n int) {
		for i := 0; i < nbTasks; i++ {
			var tmp {{toLower .PName}}JacExtended
			var _tmp {{.PName}}Jac
			task := cpuID + i*n

			// init points
			tmp.SetInfinity()
			accumulators[task].Set(&curve.{{toLower .PName}}Infinity)

			// wait for indices to be ready
			<-chIndices[task]

			for j := int(mask - 1); j >= 0; j-- {
				for _, k := range indices[task*int(mask)+j] {
					tmp.mAdd(&points[k])
				}
				tmp.ToJac(&_tmp)
				accumulators[task].Add(curve, &_tmp)
			}
			chPoints[task] <- struct{}{}
			close(chPoints[task])
		}
	}

	// double and add algo to collect all small reductions
	reduce := func() {
		var res {{.PName}}Jac
		res.Set(&curve.{{toLower .PName}}Infinity)
		for i := 0; i < nbChunks; i++ {
			for j := 0; j < len(bitsForTask[i]); j++ {
				res.Double()
			}
			<-chPoints[i]
			res.Add(curve, &accumulators[i])
		}
		p.Set(&res)
		chRes <- *p
	}

	nbCpus := runtime.NumCPU()
	nbTasksPerCpus := nbChunks / nbCpus
	remainingTasks := nbChunks % nbCpus
	for i := 0; i < nbCpus; i++ {
		if remainingTasks > 0 {
			go accumulateIndices(i, nbTasksPerCpus+1, nbCpus)
			go accumulatePoints(i, nbTasksPerCpus+1, nbCpus)
			remainingTasks--
		} else {
			go accumulateIndices(i, nbTasksPerCpus, nbCpus)
			go accumulatePoints(i, nbTasksPerCpus, nbCpus)
		}
	}

	go reduce()

	return chRes
}

`

const WindowedMultiExp = `
// WindowedMultiExp set p = scalars[0]*points[0] + ... + scalars[n]*points[n]
// assume: scalars in non-Montgomery form!
// assume: len(points)==len(scalars)>0, len(scalars[i]) equal for all i
// algorithm: a special case of Pippenger described by Bootle:
// https://jbootle.github.io/Misc/pippenger.pdf
// uses all availables runtime.NumCPU()
func (p *{{.PName}}Jac) WindowedMultiExp(curve *Curve, points []{{.PName}}Jac, scalars []{{.GroupType}}.Element) *{{.PName}}Jac {
	var lock sync.Mutex
	parallel.Execute(0, len(points), func(start, end int) {
		var t {{.PName}}Jac
		t.multiExp(curve, points[start:end], scalars[start:end])
		lock.Lock()
		p.Add(curve, &t)
		lock.Unlock()
	}, false)
	return p
}
// multiExp set p = scalars[0]*points[0] + ... + scalars[n]*points[n]
// assume: scalars in non-Montgomery form!
// assume: len(points)==len(scalars)>0, len(scalars[i]) equal for all i
// algorithm: a special case of Pippenger described by Bootle:
// https://jbootle.github.io/Misc/pippenger.pdf
func (p *{{.PName}}Jac) multiExp(curve *Curve, points []{{.PName}}Jac, scalars []{{.GroupType}}.Element) *{{.PName}}Jac {
	const s = 4 // s from Bootle, we choose s divisible by scalar bit length
	const b = s // b from Bootle, we choose b equal to s
	// WARNING! This code breaks if you switch to b!=s
	// Because we chose b=s, each set S_i from Bootle is simply the set of points[i]^{2^j} for each j in [0:s]
	// This choice allows for simpler code
	// If you want to use b!=s then the S_i from Bootle are different
	const TSize = (1 << b) - 1 // TSize is size of T_i sets from Bootle, equal to 2^b - 1
	// Store only one set T_i at a time---don't store them all!
	var T [TSize]{{.PName}}Jac // a set T_i from Bootle, the set of g^j for j in [1:2^b] for some choice of g
	computeT := func(T []{{.PName}}Jac, t0 *{{.PName}}Jac) {
		T[0].Set(t0)
		for j := 1; j < (1<<b)-1; j = j + 2 {
			T[j].Set(&T[j/2]).Double()
			T[j+1].Set(&T[(j+1)/2]).Add(curve, &T[j/2])
		}
	}
	return p.pippenger(curve, points, scalars, s, b, T[:], computeT)
}
// algorithm: a special case of Pippenger described by Bootle:
// https://jbootle.github.io/Misc/pippenger.pdf
func (p *{{.PName}}Jac) pippenger(curve *Curve, points []{{.PName}}Jac, scalars []{{.GroupType}}.Element, s, b uint64, T []{{.PName}}Jac, computeT func(T []{{.PName}}Jac, t0 *{{.PName}}Jac)) *{{.PName}}Jac {
	var t, selectorIndex, ks int
	var selectorMask, selectorShift, selector uint64
	
	t = {{.GroupType}}.ElementLimbs * 64 / int(s) // t from Bootle, equal to (scalar bit length) / s
	selectorMask = (1 << b) - 1 // low b bits are 1
	morePoints := make([]{{.PName}}Jac, t)       // morePoints is the set of G'_k points from Bootle
	for k := 0; k < t; k++ {
		morePoints[k].Set(&curve.{{toLower .PName}}Infinity)
	}
	for i := 0; i < len(points); i++ {
		// compute the set T_i from Bootle: all possible combinations of elements from S_i from Bootle
		computeT(T, &points[i])
		// for each morePoints: find the right T element and add it
		for k := 0; k < t; k++ {
			ks = k * int(s)
			selectorIndex = ks / 64
			selectorShift = uint64(ks - (selectorIndex * 64))
			selector = (scalars[i][selectorIndex] & (selectorMask << selectorShift)) >> selectorShift
			if selector != 0 {
				morePoints[k].Add(curve, &T[selector-1])
			}
		}
	}
	// combine morePoints to get the final result
	p.Set(&morePoints[t-1])
	for k := t - 2; k >= 0; k-- {
		for j := uint64(0); j < s; j++ {
			p.Double()
		}
		p.Add(curve, &morePoints[k])
	}
	return p
}
`

const EndoMul = `

// queryNthBit returns the i-th bit of s
func queryNthBit(s fr.Element, i int) uint64 {
	limb := i / 64
	offset := i % 64
	b := (s[limb] >> offset) & 1
	return b
}

// doubleandadd algo for exponentiation
// n=number of bits of the scalar s
func (p *G1Jac) doubleandadd(curve *Curve, a *G1Affine, s fr.Element, n int) *G1Jac {

	var res G1Jac
	res.Set(&curve.g1Infinity)

	for i := n - 1; i >= 0; i-- {
		b := queryNthBit(s, i)
		res.Double()
		if b == 1 {
			res.AddMixed(a)
		}
	}
	p.Set(&res)
	return &res
}

// ScalarMulEndo performs scalar multiplication
// using the endo phi(p=(x,y))=(ux,y) where u is a 3rd root of 1,
// phi(P) = lambda*P
// u = {{.ThirdRootOne}}
// lambda = {{.Lambda}} ({{.Size1}} bits)
// s1, s2 are scalars such that s1*lambda+s2 = s
// s1 on {{.Size1}} bits
// s2 on {{.Size2}} bits
func (p *G1Jac) ScalarMulEndo(curve *Curve, a *G1Affine, s fr.Element) G1Jac {

	// operation using big int
	var lambda, _s, _s1, _s2 big.Int
	lambda.SetString("{{.Lambda}}", 10)
	s.ToBigInt(&_s)
	_s1.DivMod(&_s, &lambda, &_s2)
	var s1, s2 fr.Element
	s1.SetBigInt(&_s1).FromMont()
	s2.SetBigInt(&_s2).FromMont()

	// eigenvalue of phi
	var thirdRootOne fp.Element
	thirdRootOne.SetString("{{.ThirdRootOne}}")

	// result
	chDone := make(chan G1Jac, 1)

	// chan monitoring the computation of s1*a and s2*phi(a) respectively
	chTasks := []chan struct{}{
		make(chan struct{}),
		make(chan struct{}),
	}

	//scalars
	scalars := []fr.Element{
		s1,
		s2,
	}

	// sizes of s1 and s2
	sizes := []int{
		{{.Size1}},
		{{.Size2}},
	}

	// a, phi(a)
	points := []G1Affine{
		*a,
		*a,
	}
	points[0].X.MulAssign(&thirdRootOne)

	// s1*phi(a), s2*(a)
	tmpRes := make([]G1Jac, 2)

	// subtask computing a single scalar mul
	task := func(i int) {
		tmpRes[i].doubleandadd(curve, &points[i], scalars[i], sizes[i])
		chTasks[i] <- struct{}{}
	}

	// wait for each task to be done and add the results
	reduce := func() {
		var res G1Jac
		res.Set(&curve.g1Infinity)
		<-chTasks[0]
		res.Add(curve, &tmpRes[0])
		<-chTasks[1]
		res.Add(curve, &tmpRes[1])
		p.Set(&res)
		chDone <- res
	}

	go task(0)
	go task(1)
	go reduce()

	<-chDone

	return *p
}
`
