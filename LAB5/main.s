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
	
    ; Enable the clock to GPIO Port E, H and A
	
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIOEEN
	STR r1, [r0, #RCC_AHB2ENR]
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIOHEN
	STR r1, [r0, #RCC_AHB2ENR]
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIOAEN
	STR r1, [r0, #RCC_AHB2ENR]

	; MODE: 00: Input mode, 01: General purpose output mode
    ;       10: Alternate function mode, 11: Analog mode (reset state)
	LDR r0, =GPIOE_BASE
	LDR r1, [r0, #GPIO_MODER] ;1 01 01 01 01 01 00 00 00 00 00 00 00 00 00 00
	LDR r3, =0xFF000000
	LDR r4, =0x55000000
	BIC r1, r1,  r3
	ORR r1, r1,  r4
	STR r1, [r0, #GPIO_MODER]
	
	
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_MODER] ;1 01 01 01 01 01 00 00 00 00 00 00 00 00 00 00
	LDR r2,=0xFFC
	BIC r1, r1, r2
	STR r1, [r0, #GPIO_MODER]
	
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_PUPDR]
	LDR r2,=0xFFC
	BIC r1, r1, r2
	LDR r2,=0xAA8
	ORR r1, r1, r2
	STR r1, [r0, #GPIO_PUPDR]
	
	LDR r0,=0x20000000
	
	

st	LDR r1, [r0],#4
	B st



	ENDP

		
	AREA    myData, DATA, READWRITE
	ALIGN
steps	DCD   0x1<<12, 0x3<<12, 0x1<<13,0x3<<13, 0x1<<14, 0x3<<14, 0x1<<15,0x9<<12
	END