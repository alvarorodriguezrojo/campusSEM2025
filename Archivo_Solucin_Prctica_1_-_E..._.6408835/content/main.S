		.text
		.global main
main:
	stmfd	sp!, {r4, lr}		@ salva LR por si retornamos
	adr		r0, texto1
	bl		_U0puts

	ldr		r4,	=0xFFAA5500		@ número a representar

	adr		r0, bin				@ en binario
	bl		_U0puts
		
	mov		r0, r4		
	bl		U0prtbin	
	adr		r0, crlf
	bl		_U0puts
		
	adr		r0, hexa			@ en hexadecimal
	bl		_U0puts
		
	mov		r0, r4
	bl		_U0prthex
	adr		r0, crlf
	bl		_U0puts
		
	adr		r0, dec				@ en decimal (sin signo)
	bl		_U0puts
		
	mov		r0, r4
	bl		_U0prtnum
	adr		r0, crlf
	bl		_U0puts
		
	adr		r0, ados			@ en decimal (con signo) - complemento a dos
	bl		_U0puts
		
	mov		r0, r4
	bl		U0prtados
	adr		r0, crlf
	bl		_U0puts
		
	ldmfd	sp!, {r4, pc}		@ retornamos

texto1:	.asciz "\r\nBienvenidos al LPC2103\r\n-- Esqueleto de programa en ensamblador --\r\n"
crlf:   .asciz "\r\n"
bin:    .asciz "en binario:\r\n"
hexa:   .asciz "en hexadecimal:\r\n"
dec:    .asciz "en decimal (sin signo):\r\n"
ados:	.asciz "en decimal (con signo):\r\n"


        .align 2

		
U0prtbin:						@ conversion a binario número de 32 bits en r0
	stmfd	sp!, {r4, r5, lr}
	
	mov		r4, r0				@ copia número en r4
	mov		r5, #32				@ contador de bits en r5
1:	movs	r4, r4, lsl #1		@ bits del número pasan por C
	movcs	r0, #'1'			@ si C=1 copia el ascii '1' en r0
	movcc	r0, #'0'			@ si C=0 copia el ascii '0' en r0
	
	bl 		_U0putch			@ imprime el carácter ascii
	
	subs	r5, r5, #1			@ decrementa el índice del bucle en r5
	bne		1b					@ repite bucle 32 veces
	
	ldmfd	sp!, {r4, r5, pc}	@ retorno a main
	
	
U0prtados:						@ conversion a decimal (con signo) número en r0
	stmfd	sp!, {r4, lr}
	
	mov		r4, r0				@ copia número en r4
	tst		r4, #0x80000000		@ signo=0 => Z=1, signo=1 => Z=0
	
	rsbne	r4, r4, #0			@ halla módulo si núm. es negativo (resta 0-r4)
	mov		r0, #'-'			@ copia signo menos en ascii en r0
	blne	_U0putch			@ imprime signo menos si núm. es negativo
	
	mov		r0, r4				@ copia módulo en r0
	bl		_U0prtnum			@ imprime el módulo del número	
		
	ldmfd	sp!, {r4, pc}		@ retorno a main

	
		.end