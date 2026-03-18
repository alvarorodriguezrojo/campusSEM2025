	.text
	.global main
	
	
main:
	stmfd	sp!, {r4-r8, lr}	@ Salva LR por si retornamos
	adr		r0, texto1
	bl		_U0puts

@ En r4: para generar el primer número
@ En r5: para generar el segundo número
@ En r6: código de operación (0: suma, 1: resta, 2: producto, 3: división)
@ En r7: 10 (para ir generando los números decimales de más de una cifra)
@ En r8: Para guardar copia del dígito capturado antes de llamar a _U0putch

	mov		r7, #10
		
1:	bl 		_U0getch	@ Introducción del primer dígito del primer número
	cmp		r0, #'0'	@ Debe ser un dígito entre 0 y 9
	blo		1b
	cmp		r0, #'9'
	bhi		1b
	mov		r4, r0		
	bl		_U0putch	@ Imprime el primer dígito del primer número
	sub		r4, r4, #'0'	@ Pasa de ascii a decimal
	
2:	bl 		_U0getch	@ Introducción de los demás dígitos del primer número o
	cmp		r0, #'+'	@ la operación
	moveq	r6, #0
	beq		3f
	cmp		r0, #'-'
	moveq	r6, #1
	beq		3f
	cmp		r0, #'x'
	moveq	r6, #2
	beq		3f
	cmp		r0, #'/'
	moveq	r6, #3
	beq		3f
	cmp		r0, #'0'	@ Si no es una operación, debe ser un dígito entre 0 y 9
	blo		2b
	cmp		r0, #'9'
	bhi		2b
	mov		r8, r0
	bl		_U0putch	@ Imprime los dígitos del segundo número y genera número en r4
	sub		r8, r8, #'0'	@ Pasa de ascii a decimal
	mla		r4, r7, r4, r8
	b		2b
		
3:	bl		_U0putch	@ Imprime operación

4:	bl 		_U0getch	@ Introducción del primer dígito del segundo número
	cmp		r0, #'0'	@ Debe ser un dígito entre 0 y 9
	blo		4b
	cmp		r0, #'9'
	bhi		4b
	mov		r5, r0
	bl		_U0putch	@ Imprime el primer dígito del segundo número
	sub		r5, r5, #'0'	@ Pasa de ascii a decimal

5:	bl 		_U0getch	@ Introducción de los demás dígitos del segundo número o ENTER
	cmp		r0, #'\r'
	beq		6f
	cmp		r0, #'0'	@ Si no es ENTER, debe ser un dígito entre 0 y 9
	blo		5b
	cmp		r0, #'9'
	bhi		5b
	mov		r8, r0
	bl		_U0putch	@ Imprime los dígitos del segundo número y genera número en r5
	sub		r8, r8, #'0'	@ Pasa de ascii a decimal
	mla		r5, r7, r5, r8
	b		5b		
		
6:	mov		r0, #'='	@ Imprime '='
	bl		_U0putch
		
	cmp		r6, #0		@ Calcula resultado y lo imprime
	addeq	r0, r4, r5
	bleq	_U0prtnum	@ Suma
	cmp		r6, #1
	subeq	r0, r4, r5
	bleq	U0prtados	@ Resta
	cmp		r6, #2
	muleq	r0, r4, r5
	bleq	_U0prtnum	@ Multiplicación
	cmp		r6, #3
	moveq	r0, r4
	moveq	r1, r5
	bleq	divi
	moveq	r4, r1
	bleq	_U0prtnum	@ Cociente
	adreq	r0, textdiv
	bleq	_U0puts
	moveq	r0, r4
	bleq	_U0prtnum	@ Resto
		
	adr		r0, crlf	@ Nueva línea
	bl		_U0puts
		
	b		1b			@ Volver a empezar
	
	ldmfd	sp!, {r4-r8, pc}	@ Retornamos
		
		
texto1:	.asciz "\r\nCALCULADORA: 1er numero, operacion (+,-,x,/), 2o numero, ENTER\r\n"
textdiv: .asciz ", resto="
crlf:   .asciz "\r\n"


	.align 2

	
U0prtados:		@ Conversion a decimal (con signo) número en r0

	stmfd	sp!, {r4, lr}
	
	mov		r4, r0				@ Copia número en r4
	tst		r4, #0x80000000		@ Signo=0 => Z=1, signo=1 => Z=0
	
	rsbne	r4, r4, #0			@ Halla módulo si núm. es negativo (resta 0-r4)
	mov		r0, #'-'			@ Copia signo menos en ascii en r0
	blne	_U0putch			@ Imprime signo menos si núm. es negativo
	
	mov		r0, r4				@ Copia módulo en r0
	bl		_U0prtnum			@ Imprime el módulo del número	
		
	ldmfd	sp!, {r4, pc}		@ Retorno a main

	
divi:			@ Subrutina para la división
				@ Llamada: r0 dividendo y r1 divisor
				@ Retorno: r0 cociente y r1 resto
						
	mov		r3, #32		@ Inicializo r3 = 32  (contador de bits dividendo)
	mov		r2, #0		@ Inicializo r2 a 0. En r2 se van generando los restos

1:	adds	r0, r0, r0	@ Desplazo un bit a la izq. el dividendo en r0. En C aparece
						@ su msb y el lsb queda en 0 (es el nuevo bit del cociente)
	adc		r2, r2, r2	@ El bit extraído lo coloco a la derecha del resto (r2)
	cmp		r1, r2		@ Comparo divisor (r1) con resto (r2) (r1-r2)
	subls	r2, r2, r1	@ Si el divisor es menor o igual al resto, calculo el nuevo
						@ resto restando el resto menos el divisor
	addls	r0, r0, #1	@ Y también pongo un 1 en el cociente (cambio el 0 por un 1)
	subs	r3, r3, #1	@ Decremento el contador de bits (siempre)
	bne		1b			@ Mientras el contador no llegue a 0, vuelvo atrás y hago lo
						@ mismo con el siguiente bit

	mov		r1, r2		@ Copio el resto en r1 para devolverlo al programa principal

	mov		pc, lr		@ Retorno

	
	.end