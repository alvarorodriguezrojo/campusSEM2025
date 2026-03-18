		.text
		.global main

main:
	stmfd	sp!, {lr}		@ salva LR por si retornamos

	adr		r0, texto1
	bl		_U0puts

	ldr		r0,	=0xFFAA5500		@ número a representar
	bl		U0prtbin	

	adr		r0, crlf
	bl		_U0puts
		
	ldmfd	sp!, {pc}		@ retornamos

texto1:	.asciz "\r\nBienvenidos al LPC2103\r\n-- Esqueleto de programa en ensamblador --\r\n"
crlf:   .asciz "\r\n"


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
	
	
		.end
