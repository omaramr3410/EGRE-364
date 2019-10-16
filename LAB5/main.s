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
	;EXPORT processname
		
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
	
	LDR r0,=steps
	
	

st	LDR r1, [r0],#4
	LDR r2, =GPIOE_BASE
	LDR r3, [r2, #GPIO_ODR]
	LDR r4,=0x20000024
	CMP r0, r4
	BEQ reset
	BL A3Check
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, r1
	STR r3, [r2, #GPIO_ODR]
	B delay
	
delay 	PUSH{r0,r1,r2,r3}
		LDR r10,=1500
subin	SUB r10, r10, #1		
		CMP r10, #0x0
		BEQ p
		BNE subin
p		POP{r0,r1,r2,r3}
		B st
	
reset	LDR r0, =steps
		B st
		
A3Check LDR r4, =GPIOA_BASE 
		 LDR r5,[r4,#GPIO_IDR]
		 LDR r6, =0x28
		 AND r7,r6,r4
		 CMP r7,#0x8
		 BEQ incspeed
		 BNE st
		 	 
incspeed	LDR r4, =GPIOA_BASE 
			LDR r5,[r4,#GPIO_IDR]
			LDR r6, =0x28
			AND r7,r6,r4
			CMP r7,#0x8
			BEQ subn
			BNE st
			
subn		SUB r10, #1000
			 	

A5Check LDR r4, =GPIOA_BASE 
		 LDR r5,[r4,#GPIO_IDR]
		 LDR r6, =0x28
		 AND r7,r6,r4
		 CMP r7,#0x2
		 BEQ decspeed
		 BNE A5Check
		 
		 
		 
decspeed	LDR r4, =GPIOA_BASE 
			LDR r5,[r4,#GPIO_IDR]
			LDR r6, =0x28
			AND r7,r6,r4
			CMP r7,#0x2
			BEQ addn
			BNE st
addn			ADD r10, #500


	ENDP


		
	AREA    myData, DATA, READWRITE
	ALIGN
steps	DCD   0x1<<12, 0x3<<12, 0x1<<13,0x3<<13, 0x1<<14, 0x3<<14, 0x1<<15,0x9<<12
delayv DCD 1500
	END