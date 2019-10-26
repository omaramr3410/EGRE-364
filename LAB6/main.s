;******************** (C) Yifeng ZHU *******************************************
; @file    main.s
; @author  Yifeng Zhu
; @date    May-17-2015
; @note
;           This code is for the book "Embedded Systems with ARM Cortex-M 
;           Microcontrollers in Assembly Language and C, Yifeng Zhu, 
;           ISBN-13: 978-0982692639, ISBN-10: 0982692633
; @attension
;           This code is provided for education purpose. The author shall not be 
;           held liable for any direct, indirect or consequential damages, for any 
;           reason whatever. More information can be found from book website: 
;           http:;www.eece.maine.edu/~zhu/book
;*******************************************************************************

	INCLUDE core_cm4_constants.s		; Load Constant Definitions
	INCLUDE stm32l476xx_constants.s      

	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
    ; Enable the clock to GPIO Port D	
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIODEN
	STR r1, [r0, #RCC_AHB2ENR]

	; MODE: 00: Input mode, 01: General purpose output mode
    ;       10: Alternate function mode, 11: Analog mode (reset state)
	LDR r0, =GPIOD_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, r1, #(0xF<<(2*5))
	ORR r1, r1, #(0xA<<(2*5))
	STR r1, [r0, #GPIO_MODER]
	
	LDR r1, [r0, #GPIO_AFR0]
	ORR r1, r1, #(0x77<<(4*5))
	STR r1, [r0, #GPIO_AFR0]

	LDR r1, [r0, #GPI0_OSPEEDR]
	ORR r1, r1, #(0xF<<(2*5))
	STR r1, [r0, #GPIO_OSPEEDR]
	
	LDR r1, [r0, #GPIO_OTYPER]
	BIC r1, r1, #(0x1<<5)
	ORR r1, r1, #(0x<<6)
	STR r1, [r0, #GPIO_OTYPER]
	
	LDR r1, [r0, #GPIO_PUPDR]
	BIC r1, r1, #(0xF<<(2*5))
	STR r1, [r0, #GPIO_PUPDR]
	
	
	; Enable the clock to GPIO Port E	
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIOEEN
	STR r1, [r0, #RCC_AHB2ENR]

	LDR r0, =GPIOE_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, r1, #(0xF<<(2*10))
	ORR r1, r1, #(0xA<<(2*5))
	STR r1, [r0, #GPIO_MODER]
	
	
	
	
	
	
stop 	B 		stop     		; dead loop & program hangs here

	ENDP
					
	ALIGN			

	AREA    myData, DATA, READWRITE
	ALIGN
;array	DCD   1, 2, 3, 4
;mask    DCD   0x3F,0x6,0x1B,0x,0x,0x,0x,0x,0x ;array of masks for port E
	END
