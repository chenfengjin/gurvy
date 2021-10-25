#include "textflag.h"
// func squareElement(res,y *Element)
TEXT ·squareElement(SB), NOSPLIT, $0-16
	// the algorithm is described here
	// https://hackmd.io/@zkteam/modular_multiplication
	// for i=0 to N-1
	// A, t[i] = x[i] * x[i] + t[i]
	// p = 0
	// for j=i+1 to N-1
	//     p,A,t[j] = 2*x[j]*x[i] + t[j] + (p,A)
	// m = t[0] * q'[0]
	// C, _ = t[0] + q[0]*m
	// for j=1 to N-1
	//     C, t[j-1] = q[j]*m +  t[j] + C
	// t[N-1] = C + A

	// if adx and mulx instructions are not available, uses MUL algorithm.
	
    CMPB ·supportAdx(SB), $0x0000000000000001             // check if we support MULX and ADOX instructions
    JNE no_adx                                            // no support for MULX or ADOX instructions
    MOVQ y+8(FP), R9                                       // dereference y
    // outter loop 0
    XORQ AX, AX                                            // clear up flags
    // dx = y[0]
    MOVQ 0(R9), DX
    MULXQ 8(R9), R11, R12
    MULXQ 16(R9), AX, R13
    ADCXQ AX, R12
    MULXQ 24(R9), AX, R14
    ADCXQ AX, R13
    MULXQ 32(R9), AX, R15
    ADCXQ AX, R14
    MULXQ 40(R9), AX, R10
    ADCXQ AX, R15
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R10
    XORQ AX, AX                                            // clear up flags
    MULXQ DX, CX, DX
    ADCXQ R11, R11
    MOVQ R11, BX
    ADOXQ DX, BX
    ADCXQ R12, R12
    MOVQ R12, BP
    ADOXQ AX, BP
    ADCXQ R13, R13
    MOVQ R13, SI
    ADOXQ AX, SI
    ADCXQ R14, R14
    MOVQ R14, DI
    ADOXQ AX, DI
    ADCXQ R15, R15
    MOVQ R15, R8
    ADOXQ AX, R8
    ADCXQ R10, R10
    ADOXQ AX, R10
    MOVQ $0x89f3fffcfffcfffd, DX
    MULXQ CX, R11, DX
    XORQ DX, DX                                            // clear up flags
    MOVQ $0xb9feffffffffaaab, DX
    MULXQ R11, AX, DX
    ADCXQ CX, AX
    MOVQ DX, CX
    MOVQ $0x1eabfffeb153ffff, DX
    ADCXQ BX, CX
    MULXQ R11, AX, BX
    ADOXQ AX, CX
    MOVQ $0x6730d2a0f6b0f624, DX
    ADCXQ BP, BX
    MULXQ R11, AX, BP
    ADOXQ AX, BX
    MOVQ $0x64774b84f38512bf, DX
    ADCXQ SI, BP
    MULXQ R11, AX, SI
    ADOXQ AX, BP
    MOVQ $0x4b1ba7b6434bacd7, DX
    ADCXQ DI, SI
    MULXQ R11, AX, DI
    ADOXQ AX, SI
    MOVQ $0x1a0111ea397fe69a, DX
    ADCXQ R8, DI
    MULXQ R11, AX, R8
    ADOXQ AX, DI
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    // outter loop 1
    XORQ AX, AX                                            // clear up flags
    // dx = y[1]
    MOVQ 8(R9), DX
    MULXQ 16(R9), R12, R13
    MULXQ 24(R9), AX, R14
    ADCXQ AX, R13
    MULXQ 32(R9), AX, R15
    ADCXQ AX, R14
    MULXQ 40(R9), AX, R10
    ADCXQ AX, R15
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R10
    XORQ AX, AX                                            // clear up flags
    ADCXQ R12, R12
    ADOXQ R12, BP
    ADCXQ R13, R13
    ADOXQ R13, SI
    ADCXQ R14, R14
    ADOXQ R14, DI
    ADCXQ R15, R15
    ADOXQ R15, R8
    ADCXQ R10, R10
    ADOXQ AX, R10
    XORQ AX, AX                                            // clear up flags
    MULXQ DX, AX, DX
    ADOXQ AX, BX
    MOVQ $0x0000000000000000, AX
    ADOXQ DX, BP
    ADOXQ AX, SI
    ADOXQ AX, DI
    ADOXQ AX, R8
    ADOXQ AX, R10
    MOVQ $0x89f3fffcfffcfffd, DX
    MULXQ CX, R11, DX
    XORQ DX, DX                                            // clear up flags
    MOVQ $0xb9feffffffffaaab, DX
    MULXQ R11, AX, DX
    ADCXQ CX, AX
    MOVQ DX, CX
    MOVQ $0x1eabfffeb153ffff, DX
    ADCXQ BX, CX
    MULXQ R11, AX, BX
    ADOXQ AX, CX
    MOVQ $0x6730d2a0f6b0f624, DX
    ADCXQ BP, BX
    MULXQ R11, AX, BP
    ADOXQ AX, BX
    MOVQ $0x64774b84f38512bf, DX
    ADCXQ SI, BP
    MULXQ R11, AX, SI
    ADOXQ AX, BP
    MOVQ $0x4b1ba7b6434bacd7, DX
    ADCXQ DI, SI
    MULXQ R11, AX, DI
    ADOXQ AX, SI
    MOVQ $0x1a0111ea397fe69a, DX
    ADCXQ R8, DI
    MULXQ R11, AX, R8
    ADOXQ AX, DI
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    // outter loop 2
    XORQ AX, AX                                            // clear up flags
    // dx = y[2]
    MOVQ 16(R9), DX
    MULXQ 24(R9), R12, R13
    MULXQ 32(R9), AX, R14
    ADCXQ AX, R13
    MULXQ 40(R9), AX, R10
    ADCXQ AX, R14
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R10
    XORQ AX, AX                                            // clear up flags
    ADCXQ R12, R12
    ADOXQ R12, SI
    ADCXQ R13, R13
    ADOXQ R13, DI
    ADCXQ R14, R14
    ADOXQ R14, R8
    ADCXQ R10, R10
    ADOXQ AX, R10
    XORQ AX, AX                                            // clear up flags
    MULXQ DX, AX, DX
    ADOXQ AX, BP
    MOVQ $0x0000000000000000, AX
    ADOXQ DX, SI
    ADOXQ AX, DI
    ADOXQ AX, R8
    ADOXQ AX, R10
    MOVQ $0x89f3fffcfffcfffd, DX
    MULXQ CX, R15, DX
    XORQ DX, DX                                            // clear up flags
    MOVQ $0xb9feffffffffaaab, DX
    MULXQ R15, AX, DX
    ADCXQ CX, AX
    MOVQ DX, CX
    MOVQ $0x1eabfffeb153ffff, DX
    ADCXQ BX, CX
    MULXQ R15, AX, BX
    ADOXQ AX, CX
    MOVQ $0x6730d2a0f6b0f624, DX
    ADCXQ BP, BX
    MULXQ R15, AX, BP
    ADOXQ AX, BX
    MOVQ $0x64774b84f38512bf, DX
    ADCXQ SI, BP
    MULXQ R15, AX, SI
    ADOXQ AX, BP
    MOVQ $0x4b1ba7b6434bacd7, DX
    ADCXQ DI, SI
    MULXQ R15, AX, DI
    ADOXQ AX, SI
    MOVQ $0x1a0111ea397fe69a, DX
    ADCXQ R8, DI
    MULXQ R15, AX, R8
    ADOXQ AX, DI
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    // outter loop 3
    XORQ AX, AX                                            // clear up flags
    // dx = y[3]
    MOVQ 24(R9), DX
    MULXQ 32(R9), R11, R12
    MULXQ 40(R9), AX, R10
    ADCXQ AX, R12
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R10
    XORQ AX, AX                                            // clear up flags
    ADCXQ R11, R11
    ADOXQ R11, DI
    ADCXQ R12, R12
    ADOXQ R12, R8
    ADCXQ R10, R10
    ADOXQ AX, R10
    XORQ AX, AX                                            // clear up flags
    MULXQ DX, AX, DX
    ADOXQ AX, SI
    MOVQ $0x0000000000000000, AX
    ADOXQ DX, DI
    ADOXQ AX, R8
    ADOXQ AX, R10
    MOVQ $0x89f3fffcfffcfffd, DX
    MULXQ CX, R13, DX
    XORQ DX, DX                                            // clear up flags
    MOVQ $0xb9feffffffffaaab, DX
    MULXQ R13, AX, DX
    ADCXQ CX, AX
    MOVQ DX, CX
    MOVQ $0x1eabfffeb153ffff, DX
    ADCXQ BX, CX
    MULXQ R13, AX, BX
    ADOXQ AX, CX
    MOVQ $0x6730d2a0f6b0f624, DX
    ADCXQ BP, BX
    MULXQ R13, AX, BP
    ADOXQ AX, BX
    MOVQ $0x64774b84f38512bf, DX
    ADCXQ SI, BP
    MULXQ R13, AX, SI
    ADOXQ AX, BP
    MOVQ $0x4b1ba7b6434bacd7, DX
    ADCXQ DI, SI
    MULXQ R13, AX, DI
    ADOXQ AX, SI
    MOVQ $0x1a0111ea397fe69a, DX
    ADCXQ R8, DI
    MULXQ R13, AX, R8
    ADOXQ AX, DI
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    // outter loop 4
    XORQ AX, AX                                            // clear up flags
    // dx = y[4]
    MOVQ 32(R9), DX
    MULXQ 40(R9), R14, R10
    ADCXQ R14, R14
    ADOXQ R14, R8
    ADCXQ R10, R10
    ADOXQ AX, R10
    XORQ AX, AX                                            // clear up flags
    MULXQ DX, AX, DX
    ADOXQ AX, DI
    MOVQ $0x0000000000000000, AX
    ADOXQ DX, R8
    ADOXQ AX, R10
    MOVQ $0x89f3fffcfffcfffd, DX
    MULXQ CX, R15, DX
    XORQ DX, DX                                            // clear up flags
    MOVQ $0xb9feffffffffaaab, DX
    MULXQ R15, AX, DX
    ADCXQ CX, AX
    MOVQ DX, CX
    MOVQ $0x1eabfffeb153ffff, DX
    ADCXQ BX, CX
    MULXQ R15, AX, BX
    ADOXQ AX, CX
    MOVQ $0x6730d2a0f6b0f624, DX
    ADCXQ BP, BX
    MULXQ R15, AX, BP
    ADOXQ AX, BX
    MOVQ $0x64774b84f38512bf, DX
    ADCXQ SI, BP
    MULXQ R15, AX, SI
    ADOXQ AX, BP
    MOVQ $0x4b1ba7b6434bacd7, DX
    ADCXQ DI, SI
    MULXQ R15, AX, DI
    ADOXQ AX, SI
    MOVQ $0x1a0111ea397fe69a, DX
    ADCXQ R8, DI
    MULXQ R15, AX, R8
    ADOXQ AX, DI
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    // outter loop 5
    XORQ AX, AX                                            // clear up flags
    // dx = y[5]
    MOVQ 40(R9), DX
    MULXQ DX, AX, R10
    ADCXQ AX, R8
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R10
    MOVQ $0x89f3fffcfffcfffd, DX
    MULXQ CX, R11, DX
    XORQ DX, DX                                            // clear up flags
    MOVQ $0xb9feffffffffaaab, DX
    MULXQ R11, AX, DX
    ADCXQ CX, AX
    MOVQ DX, CX
    MOVQ $0x1eabfffeb153ffff, DX
    ADCXQ BX, CX
    MULXQ R11, AX, BX
    ADOXQ AX, CX
    MOVQ $0x6730d2a0f6b0f624, DX
    ADCXQ BP, BX
    MULXQ R11, AX, BP
    ADOXQ AX, BX
    MOVQ $0x64774b84f38512bf, DX
    ADCXQ SI, BP
    MULXQ R11, AX, SI
    ADOXQ AX, BP
    MOVQ $0x4b1ba7b6434bacd7, DX
    ADCXQ DI, SI
    MULXQ R11, AX, DI
    ADOXQ AX, SI
    MOVQ $0x1a0111ea397fe69a, DX
    ADCXQ R8, DI
    MULXQ R11, AX, R8
    ADOXQ AX, DI
    MOVQ $0x0000000000000000, AX
    ADCXQ AX, R8
    ADOXQ R10, R8
    // dereference res
    MOVQ res+0(FP), R12
reduce:
    MOVQ $0x1a0111ea397fe69a, DX
    CMPQ R8, DX                                            // note: this is not constant time, comment out to have constant time mul
    JCC sub_t_q                                           // t > q
t_is_smaller:
    MOVQ CX, 0(R12)
    MOVQ BX, 8(R12)
    MOVQ BP, 16(R12)
    MOVQ SI, 24(R12)
    MOVQ DI, 32(R12)
    MOVQ R8, 40(R12)
    RET
sub_t_q:
    MOVQ CX, R13
    MOVQ $0xb9feffffffffaaab, DX
    SUBQ DX, R13
    MOVQ BX, R14
    MOVQ $0x1eabfffeb153ffff, DX
    SBBQ DX, R14
    MOVQ BP, R15
    MOVQ $0x6730d2a0f6b0f624, DX
    SBBQ DX, R15
    MOVQ SI, R11
    MOVQ $0x64774b84f38512bf, DX
    SBBQ DX, R11
    MOVQ DI, R9
    MOVQ $0x4b1ba7b6434bacd7, DX
    SBBQ DX, R9
    MOVQ R8, R10
    MOVQ $0x1a0111ea397fe69a, DX
    SBBQ DX, R10
    JCS t_is_smaller
    MOVQ R13, 0(R12)
    MOVQ R14, 8(R12)
    MOVQ R15, 16(R12)
    MOVQ R11, 24(R12)
    MOVQ R9, 32(R12)
    MOVQ R10, 40(R12)
    RET
no_adx:
    // dereference y
    MOVQ y+8(FP), R9
    MOVQ 0(R9), AX
    MOVQ 0(R9), R14
    MULQ R14
    MOVQ AX, CX
    MOVQ DX, R15
    MOVQ $0x89f3fffcfffcfffd, R11
    IMULQ CX, R11
    MOVQ $0xb9feffffffffaaab, AX
    MULQ R11
    ADDQ CX, AX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R13
    MOVQ 8(R9), AX
    MULQ R14
    MOVQ R15, BX
    ADDQ AX, BX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1eabfffeb153ffff, AX
    MULQ R11
    ADDQ BX, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, CX
    MOVQ DX, R13
    MOVQ 16(R9), AX
    MULQ R14
    MOVQ R15, BP
    ADDQ AX, BP
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x6730d2a0f6b0f624, AX
    MULQ R11
    ADDQ BP, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BX
    MOVQ DX, R13
    MOVQ 24(R9), AX
    MULQ R14
    MOVQ R15, SI
    ADDQ AX, SI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x64774b84f38512bf, AX
    MULQ R11
    ADDQ SI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BP
    MOVQ DX, R13
    MOVQ 32(R9), AX
    MULQ R14
    MOVQ R15, DI
    ADDQ AX, DI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x4b1ba7b6434bacd7, AX
    MULQ R11
    ADDQ DI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, SI
    MOVQ DX, R13
    MOVQ 40(R9), AX
    MULQ R14
    MOVQ R15, R8
    ADDQ AX, R8
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1a0111ea397fe69a, AX
    MULQ R11
    ADDQ R8, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, DI
    MOVQ DX, R13
    ADDQ R13, R15
    MOVQ R15, R8
    MOVQ 0(R9), AX
    MOVQ 8(R9), R14
    MULQ R14
    ADDQ AX, CX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x89f3fffcfffcfffd, R11
    IMULQ CX, R11
    MOVQ $0xb9feffffffffaaab, AX
    MULQ R11
    ADDQ CX, AX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R13
    MOVQ 8(R9), AX
    MULQ R14
    ADDQ R15, BX
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1eabfffeb153ffff, AX
    MULQ R11
    ADDQ BX, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, CX
    MOVQ DX, R13
    MOVQ 16(R9), AX
    MULQ R14
    ADDQ R15, BP
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BP
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x6730d2a0f6b0f624, AX
    MULQ R11
    ADDQ BP, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BX
    MOVQ DX, R13
    MOVQ 24(R9), AX
    MULQ R14
    ADDQ R15, SI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, SI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x64774b84f38512bf, AX
    MULQ R11
    ADDQ SI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BP
    MOVQ DX, R13
    MOVQ 32(R9), AX
    MULQ R14
    ADDQ R15, DI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, DI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x4b1ba7b6434bacd7, AX
    MULQ R11
    ADDQ DI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, SI
    MOVQ DX, R13
    MOVQ 40(R9), AX
    MULQ R14
    ADDQ R15, R8
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R8
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1a0111ea397fe69a, AX
    MULQ R11
    ADDQ R8, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, DI
    MOVQ DX, R13
    ADDQ R13, R15
    MOVQ R15, R8
    MOVQ 0(R9), AX
    MOVQ 16(R9), R14
    MULQ R14
    ADDQ AX, CX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x89f3fffcfffcfffd, R11
    IMULQ CX, R11
    MOVQ $0xb9feffffffffaaab, AX
    MULQ R11
    ADDQ CX, AX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R13
    MOVQ 8(R9), AX
    MULQ R14
    ADDQ R15, BX
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1eabfffeb153ffff, AX
    MULQ R11
    ADDQ BX, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, CX
    MOVQ DX, R13
    MOVQ 16(R9), AX
    MULQ R14
    ADDQ R15, BP
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BP
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x6730d2a0f6b0f624, AX
    MULQ R11
    ADDQ BP, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BX
    MOVQ DX, R13
    MOVQ 24(R9), AX
    MULQ R14
    ADDQ R15, SI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, SI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x64774b84f38512bf, AX
    MULQ R11
    ADDQ SI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BP
    MOVQ DX, R13
    MOVQ 32(R9), AX
    MULQ R14
    ADDQ R15, DI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, DI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x4b1ba7b6434bacd7, AX
    MULQ R11
    ADDQ DI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, SI
    MOVQ DX, R13
    MOVQ 40(R9), AX
    MULQ R14
    ADDQ R15, R8
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R8
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1a0111ea397fe69a, AX
    MULQ R11
    ADDQ R8, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, DI
    MOVQ DX, R13
    ADDQ R13, R15
    MOVQ R15, R8
    MOVQ 0(R9), AX
    MOVQ 24(R9), R14
    MULQ R14
    ADDQ AX, CX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x89f3fffcfffcfffd, R11
    IMULQ CX, R11
    MOVQ $0xb9feffffffffaaab, AX
    MULQ R11
    ADDQ CX, AX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R13
    MOVQ 8(R9), AX
    MULQ R14
    ADDQ R15, BX
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1eabfffeb153ffff, AX
    MULQ R11
    ADDQ BX, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, CX
    MOVQ DX, R13
    MOVQ 16(R9), AX
    MULQ R14
    ADDQ R15, BP
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BP
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x6730d2a0f6b0f624, AX
    MULQ R11
    ADDQ BP, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BX
    MOVQ DX, R13
    MOVQ 24(R9), AX
    MULQ R14
    ADDQ R15, SI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, SI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x64774b84f38512bf, AX
    MULQ R11
    ADDQ SI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BP
    MOVQ DX, R13
    MOVQ 32(R9), AX
    MULQ R14
    ADDQ R15, DI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, DI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x4b1ba7b6434bacd7, AX
    MULQ R11
    ADDQ DI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, SI
    MOVQ DX, R13
    MOVQ 40(R9), AX
    MULQ R14
    ADDQ R15, R8
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R8
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1a0111ea397fe69a, AX
    MULQ R11
    ADDQ R8, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, DI
    MOVQ DX, R13
    ADDQ R13, R15
    MOVQ R15, R8
    MOVQ 0(R9), AX
    MOVQ 32(R9), R14
    MULQ R14
    ADDQ AX, CX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x89f3fffcfffcfffd, R11
    IMULQ CX, R11
    MOVQ $0xb9feffffffffaaab, AX
    MULQ R11
    ADDQ CX, AX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R13
    MOVQ 8(R9), AX
    MULQ R14
    ADDQ R15, BX
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1eabfffeb153ffff, AX
    MULQ R11
    ADDQ BX, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, CX
    MOVQ DX, R13
    MOVQ 16(R9), AX
    MULQ R14
    ADDQ R15, BP
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BP
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x6730d2a0f6b0f624, AX
    MULQ R11
    ADDQ BP, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BX
    MOVQ DX, R13
    MOVQ 24(R9), AX
    MULQ R14
    ADDQ R15, SI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, SI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x64774b84f38512bf, AX
    MULQ R11
    ADDQ SI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BP
    MOVQ DX, R13
    MOVQ 32(R9), AX
    MULQ R14
    ADDQ R15, DI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, DI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x4b1ba7b6434bacd7, AX
    MULQ R11
    ADDQ DI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, SI
    MOVQ DX, R13
    MOVQ 40(R9), AX
    MULQ R14
    ADDQ R15, R8
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R8
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1a0111ea397fe69a, AX
    MULQ R11
    ADDQ R8, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, DI
    MOVQ DX, R13
    ADDQ R13, R15
    MOVQ R15, R8
    MOVQ 0(R9), AX
    MOVQ 40(R9), R14
    MULQ R14
    ADDQ AX, CX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x89f3fffcfffcfffd, R11
    IMULQ CX, R11
    MOVQ $0xb9feffffffffaaab, AX
    MULQ R11
    ADDQ CX, AX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R13
    MOVQ 8(R9), AX
    MULQ R14
    ADDQ R15, BX
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BX
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1eabfffeb153ffff, AX
    MULQ R11
    ADDQ BX, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, CX
    MOVQ DX, R13
    MOVQ 16(R9), AX
    MULQ R14
    ADDQ R15, BP
    ADCQ $0x0000000000000000, DX
    ADDQ AX, BP
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x6730d2a0f6b0f624, AX
    MULQ R11
    ADDQ BP, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BX
    MOVQ DX, R13
    MOVQ 24(R9), AX
    MULQ R14
    ADDQ R15, SI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, SI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x64774b84f38512bf, AX
    MULQ R11
    ADDQ SI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, BP
    MOVQ DX, R13
    MOVQ 32(R9), AX
    MULQ R14
    ADDQ R15, DI
    ADCQ $0x0000000000000000, DX
    ADDQ AX, DI
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x4b1ba7b6434bacd7, AX
    MULQ R11
    ADDQ DI, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, SI
    MOVQ DX, R13
    MOVQ 40(R9), AX
    MULQ R14
    ADDQ R15, R8
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R8
    ADCQ $0x0000000000000000, DX
    MOVQ DX, R15
    MOVQ $0x1a0111ea397fe69a, AX
    MULQ R11
    ADDQ R8, R13
    ADCQ $0x0000000000000000, DX
    ADDQ AX, R13
    ADCQ $0x0000000000000000, DX
    MOVQ R13, DI
    MOVQ DX, R13
    ADDQ R13, R15
    MOVQ R15, R8
    // dereference res
    MOVQ res+0(FP), R12
    JMP reduce
