/*
 *  linux/arch/arm/kernel/debug_macro.S
 *
 *  Copyright (c) 2011 Wind River Systems, Inc.
 *  Stanley.Miao <stanley.miao@windriver.com>
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License version 2 as
 * published by the Free Software Foundation.
 *
 *  32-bit debugging code
 */

#ifdef CONFIG_DEBUG_LL

	.macro  kputc,val
	mov     r0, \val
	bl      printch
	.endm

	.macro	dbgmsg, str
	stmfd   sp!, {r0-r3, lr}
	adr	r0, \str
	bl	printascii
	ldmfd   sp!, {r0-r3, lr}
	.endm

	.macro  read_reg reg, num
	stmfd	sp!, {r0-r4, lr}
	kputc	#'r'
	mov	r4, #\num
	cmp	r4, #10
	blt	901f
	sub	r4, r4, #10
	kputc	#'1'
901:	add	r0, r4, #'0'
	bl	printch
	kputc   #':'
	ldmfd	sp, {r0-r4, lr}
	mov     r0, \reg
	bl      printhex8
	kputc   #'\n'
	ldmfd   sp!, {r0-r4, lr}
	.endm

	.macro	PRINT_SCTLR
	stmfd	sp!, {r0-r4, lr}
	kputc	#'S'
	kputc	#'C'
	kputc	#'T'
	kputc	#'L'
	kputc	#'R'
	kputc	#':'
	mrc	p15, 0, r0, c1, c0, 0
	bl	printhex8
	kputc	#'\n'
	ldmfd   sp!, {r0-r4, lr}
	.endm

	.macro	PRINT_CPSR
	stmfd	sp!, {r0-r4, lr}
	kputc	#'C'
	kputc	#'P'
	kputc	#'S'
	kputc	#'R'
	kputc	#':'
	mrs	r0, cpsr
	bl	printhex8
	kputc	#'\n'
	ldmfd   sp!, {r0-r4, lr}
	.endm

#define DBG_MSG(x)	dbgmsg dbg_##x
#define PRINT_REG(x)	read_reg r##x, x

#undef ENDPROC
#define ENDPROC(name) \
	.type name, %function; \
		END(name); \
	dbg_##name:; \
	.ascii #name; \
	.asciz " enter.\n"; \
	.align 2

#else
#define DBG_MSG(x)
#define PRINT_REG(x)
#endif
