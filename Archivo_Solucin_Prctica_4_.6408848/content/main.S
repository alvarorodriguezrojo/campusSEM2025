		.text
		.global main
main:
		@ r4: puntero a registros del GPIO
		@ r5: puntero a bytes para el display
		@ r6: contador de cifras decimales
								
		stmfd	sp!, {r4-r6, lr}	@ salva LR por si retornamos
		adr		r0, texto1
		bl		_U0puts
		
		ldr		r4, =0xE0028000 @ direccion base de legacy GPIO (IOPIN)
		ldr		r0, =0x00007F80   
		str		r0, [r4, #8]	@ escribo en IODIR pines 14-7 son salidas para el display 7-seg
		
2:		mov		r6, #10			@ contador de cifras decimales
		adr		r5, seg7
1:		ldr		r0, =7372799	@ período de 0.5 segundos 
		bl		_delay_loop
		ldrb	r0, [r5], #1
		mov		r0, r0, lsl #7
		str		r0, [r4]		@ escribo en IOPIN
		subs	r6, r6, #1		@ cuento 10 cifras, del 0 al 9
		bne		1b
		b		2b				@ bucle infinito
		
		ldmfd	sp!, {r4-r6, pc}	@ retornamos


texto1:	.asciz "\r\nBienvenidos al LPC2103\r\n-- Esqueleto de programa en ensamblador --\r\n"
seg7:	.byte 0xFC			@ 0 (7-seg)
		.byte 0x60			@ 1
		.byte 0xDA			@ 2
		.byte 0xF2			@ 3
		.byte 0x66			@ 4
		.byte 0xB6			@ 5
		.byte 0xBE			@ 6
		.byte 0xE0			@ 7
		.byte 0xFE			@ 8
		.byte 0xF6			@ 9

        .align 2

		.end

