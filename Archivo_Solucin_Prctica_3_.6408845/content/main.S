		.text
		.global main
main:

		stmfd	sp!, {r4-r8, lr}	@ salva LR por si retornamos
		adr		r0, texto1
		bl		_U0puts

		adr		r5, lista
		add		r4, r5, #256	@ coloco r4 en la posicion siguiente al final de la lista (256 tamaño en bytes de la lista)
1:		mov		r0, r5
		bl 		_U0puts
		add		r5, r5, #16
		adr		r0, space
		bl		_U0puts
		cmp		r5, r4			@ llego al final de la lista?
		bne 	1b

		adr		r0, texto2		
		bl		_U0puts
		adr		r0, return
		bl		_U0puts
			
		ldr 	r6, =0x40000000		@ r6 puntero a lista ordenada
		add 	r7, r6, #256		@ r7 puntero a final de lista ordenada
		sub 	r8, r7, #16			@ r8 puntero a ultima palabra
			
		adr 	r1, lista
		mov 	r0, r6
		bl 		cpypalabra			@ copia la lista de la flash a la RAM
			
		mov 	r4, r6				@ r4 puntero palabra r0
		add 	r5, r4, #16			@ r5 puntero a palabra r1
			
2:		mov 	r0, r4
		mov 	r1, r5
		bl 		cmppalabra
		movhi 	r0, r4
		movhi 	r1, r5
		blhi 	exchpalabra
		add 	r5, r5, #16
		cmp 	r5, r7
		bne 	2b
		add		r4, r4, #16
			
		add 	r5, r4, #16
			
		cmp 	r4, r8
		bne 	2b
			
3:		mov		r0, r6
		bl 		_U0puts
		add		r6, r6, #16
		adr		r0, space
		bl		_U0puts
		cmp		r6, r7			@ llego al final de la lista ordenada?
		bne 	3b
			
		ldmfd	sp!, {r4-r8, pc}	@ retornamos


texto1:	.asciz "\r\nPrograma que ordena alfabeticamente palabras de como maximo 15 caracteres. \r\nVamos a ordenar: \r\n" @ son 15 en vez de 16 ya que el caracter nulo 0x00 es el caracter 16
return:	.asciz "\r\n"
space:	.asciz " "
texto2:	.asciz "\r\nLista ordenada:"
		.align 4
lista:	.asciz "enero"
		.align 4
		.asciz "febrero"
		.align 4
		.asciz "marzo"
		.align 4
		.asciz "abril"
		.align 4
		.asciz "mayo"
		.align 4
		.asciz "junio"
		.align 4
		.asciz "xxxxxxxxxxxxxxx"		@ cualquier palabra de 15 caracteres
		.align 4
		.asciz "julio"
		.align 4
		.asciz "agosto"
		.align 4
		.asciz "septiembre"
		.align 4
		.asciz "y"
		.align 4
		.asciz "octubre"
		.align 4
		.asciz "noviembre"
		.align 4
		.asciz "diciembre"
		.align 4
		.asciz "mayo"
		.align 4
		.asciz "ahora"
		.align 4


@@@@@@@@@@@@@@@@@@@ subrutina cpypalabra @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@		
@ r0: destino, r1: fuente, basada en la subrutina memcopy
@ Copiamos la lista de 32 en 32 bits a través del registro r3
cpypalabra: 
		add		r2, r0, #256	@ r2 dirección final de la copia
1:		ldr		r3, [r1], #4	@ r3 registro intermedio
		str		r3, [r0], #4 	
		cmp 	r0, r2		 	@ compruebo si es el final de la lista
		bne		1b
		mov 	pc, lr

@@@@@@@@@@@@@@@@@@@ subrutina cmppalabra @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@		
@ r0 y r1 contienen punteros a palabras a comparar
@ devuelve en registro de estado resultado de comparacion
cmppalabra:
		ldrb 	r2, [r0], #1
		ldrb 	r3, [r1], #1
		cmp 	r2, r3
		movne 	pc, lr		@ retorna C=0 si r0<r1, C=1 si r0>r1. En ambos casos Z=0
		cmp 	r2, #0x00	@ si llego aqui es porque los caracteres son iguales
		moveq 	pc, lr		@ si r2=#0x00 => r3=0x00 => las palabras son iguales => retorna Z=1	
		b 		cmppalabra
	
@@@@@@@@@@@@@@@@@@@ subrutina exchpalabra @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@		
@ r0 y r1 contienen punteros a palabras a intercambiar
exchpalabra:
		mov 	r2, #0		 	@ r2 contador para el bucle 		
1:		ldr 	r3, [r0]
		ldr	    r12, [r1]
		add		r2, r2, #1	 	@ incremento contador
		str     r12, [r0], #4
		str	    r3, [r1], #4
		cmp		r2, #4
		bne 	1b
        mov     pc, lr
			
.end