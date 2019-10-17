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
	
	LDR r0,=steps ; loads array 
	LDR r12, =1200 ; base delay var
	LDR r11, =4000 ; delay max
	LDR r10, =400  ; delay min

st	LDR r1, [r0],#4
	LDR r2, =GPIOE_BASE
	LDR r3, [r2, #GPIO_ODR]
	LDR r4,=0x20000024
	CMP r0, r4
	BEQ reset
	BNE ret3	
ret3	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, r1
	STR r3, [r2, #GPIO_ODR]
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x8
	AND r7,r6,r5
	CMP r7,#0x8
	BEQ incspeed
	BNE return1
return1	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x20
	AND r7,r6,r4
	CMP r7,#0x2
	BEQ decspeed
	BNE return2
return2
	
	B delay 
	
delay 	PUSH{r0,r1,r2,r3,r12}
		;LDR r12,=1200
subin	SUB r12, r12, #1
		LDR r2, =GPIOE_BASE
		LDR r3, [r2, #GPIO_ODR]	
		BIC r3, r3, #(0x1<<10)
		ORR r3,r3,#(0x1<<10)
		STR r3, [r2, #GPIO_ODR]
		CMP r12, #0x0
		BEQ p
		BNE subin
p		POP{r0,r1,r2,r3,r12}
		B st
	
reset	LDR r0, =steps
		B ret3
		
A3Check LDR r4, =GPIOA_BASE 
		 LDR r5,[r4,#GPIO_IDR]
		 LDR r6, =0x28
		 AND r7,r6,r4
		 CMP r7,#0x8
		 BEQ incspeed
		 BNE return1
		 	 
incspeed	LDR r4, =GPIOA_BASE 
			LDR r5,[r4,#GPIO_IDR]
			LDR r6, =0x28
			AND r7,r6,r4
			CMP r7,#0x8
			BEQ subn
			BNE return1
			
subn		CMP r11,r12
			BLT check2
			BGE return1
check2		CMP r12,r10
			BGE go
			BLT return2
go			SUB r12, #500
			B return1
			 	

A5Check LDR r4, =GPIOA_BASE 
		 LDR r5,[r4,#GPIO_IDR]
		 LDR r6, =0x28
		 AND r7,r6,r4
		 CMP r7,#0x2
		 BEQ decspeed
		 BNE return2
		 
		 
		 
decspeed	LDR r4, =GPIOA_BASE 
			LDR r5,[r4,#GPIO_IDR]
			LDR r6, =0x28
			AND r7,r6,r4
			CMP r7,#0x2
			BEQ addn
			BNE st
			
addn		
			CMP r11,r12
			BGE checkcond
			BLT return2
checkcond	CMP r12,r10
			BGE addr
			BLT return2	
addr		ADD r10, #5
			B return2

	ENDP


		
	AREA    myData, DATA, READWRITE
	ALIGN
steps	DCD   0x1<<12, 0x3<<12, 0x1<<13,0x3<<13, 0x1<<14, 0x3<<14, 0x1<<15,0x9<<12
delaymin DCD  0x190 ; sets delay variable to 400
	END