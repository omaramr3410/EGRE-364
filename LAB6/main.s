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
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_APB1ENR1]
	ORR r1, r1, #RCC_APB1ENR1_USART2EN
	STR r1, [r0, #RCC_APB1ENR1]

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

	LDR r1, [r0, #GPIO_OSPEEDR]
	ORR r1, r1, #(0xF<<(2*5))
	STR r1, [r0, #GPIO_OSPEEDR]
	
	LDR r1, [r0, #GPIO_OTYPER]
	BIC r1, r1, #(0x1<<5)
	ORR r1, r1, #(0x1<<6)
	STR r1, [r0, #GPIO_OTYPER]
	
	LDR r1, [r0, #GPIO_PUPDR]
	BIC r1, r1, #(0xF<<(2*5))
	STR r1, [r0, #GPIO_PUPDR]
	
	LDR r0, = USART2_BASE
	LDR r1, [r0, #USART_CR1]
	LDR r2, = USART_CR1_RE
	BIC r1, r1, #USART_CR1_M
	BIC r1, r1, #USART_CR1_OVER8
	ORR r1, r1, #USART_CR1_UE
	ORR r2, r2, #USART_CR1_TE
	ORR r1, r1, r2
	STR r1, [r0, #USART_CR1]
	LDR r1, [r0, #USART_CR2]
	BIC r1, r1, #USART_CR2_STOP
	STR r1, [r0, #USART_CR2]
	LDR r2, = 8000000
	LDR r3, = 9600
	SDIV r1, r2, r3
	STR r1, [r0, #USART_BRR]
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_CR]
	ORR r1, r1, #RCC_CR_MSION
	STR r1, [r0, #RCC_CR]
	LDR r1, [r0, #RCC_CFGR]
	BIC r1, r1, #RCC_CFGR_SW
	STR r1, [r0, #RCC_CFGR]
	LDR r2, [r0, #RCC_CR]
	BIC r2, r2, #RCC_CR_MSIRANGE
	ORR r2, r2, #RCC_CR_MSIRANGE_7
	ORR r2, r2, #RCC_CR_MSIRGSEL
	STR r2, [r0, #RCC_CR]


	
	
	; Enable the clock to GPIO Port E	
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIOEEN
	STR r1, [r0, #RCC_AHB2ENR]

	LDR r0, =GPIOE_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, r1, #(0xFF<<(2*12))
	ORR r1, r1, #(0x55<<(2*12))
	STR r1, [r0, #GPIO_MODER]
	
	LDR r1, [r0, #GPIO_PUPDR]
	BIC r1, r1, #(0xFF<<(2*12))
	STR r1, [r0, #GPIO_PUPDR]
	
	; Enable the clock to GPIO Port A	
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIOAEN
	STR r1, [r0, #RCC_AHB2ENR]

	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_MODER]
	BIC r1, r1, #(0xFF)
	STR r1, [r0, #GPIO_MODER]
	
	LDR r1, [r0, #GPIO_PUPDR]
	BIC r1, r1, #(0xFF)
	STR r1, [r0, #GPIO_PUPDR]
	
st	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	STR r3, [r2, #GPIO_ODR]
	LDR r9, = 500000
	LDR r4, = (0x1<<12)
	B delayst
checkcols	LDR r2, =GPIOA_BASE
			LDR r5,[r2,#GPIO_IDR]
			LDR r6, =0xF
			AND r7,r6,r5
			CMP r7,#(0x0)
			BEQ set
			CMP r7,#(0x1)
			BEQ col1
			CMP r7,#(0x2)
			BEQ col2
			CMP r7,#(0x4)
			BEQ col3
			CMP r7,#(0x8)
			BEQ col4
			B st
	
set	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, r4
	MOV r11, r4
	LSL r4, r4, #1 
	STR r3, [r2, #GPIO_ODR]
	CMP r11, #0
	BEQ st
	LDR r9, = 500000
	B delayst

col1 	CMP r11, #(0x1<<12)
		BEQ pone
		CMP r11, #(0x1<<13)
		BEQ pfour
		CMP r11, #(0x1<<14)
		BEQ psev
		CMP r11, #(0x1<<15)
		BEQ pstar
col2 	CMP r11, #(0x1<<12)
		BEQ ptwo
		CMP r11, #(0x1<<13)
		BEQ pfive
		CMP r11, #(0x1<<14)
		BEQ pate
		CMP r11, #(0x1<<15)
		BEQ pzero
col3 	CMP r11, #(0x1<<12)
		BEQ pthree
		CMP r11, #(0x1<<13)
		BEQ psix
		CMP r11, #(0x1<<14)
		BEQ pnine
		CMP r11, #(0x1<<15)
		BEQ phash
col4 	CMP r11, #(0x1<<12)
		BEQ pA
		CMP r11, #(0x1<<13)
		BEQ pB
		CMP r11, #(0x1<<14)
		BEQ p_C
		CMP r11, #(0x1<<15)
		BEQ pD


	
delayst	SUB r9,r9,#1
		CMP r9, #0
		BNE delayst
		B checkcols
		

pB	LDR r12, =0x42
	B write
pA	LDR r12, =0x41
	B write
pthree	LDR r12, =0x3
	B write
ptwo	LDR r12, =0x2
	B write
pone	LDR r12, =0x1
	B write
psix	LDR r12, =0x6
	B write
pfive	LDR r12, =0x5
	B write
pfour	LDR r12, =0x4
	B write
p_C	LDR r12, =0x43
	B write
pnine	LDR r12, =0x9
	B write
pate	LDR r12, =0x8
	B write
psev	LDR r12, =0x7
	B write
pD	LDR r12, =0x44
	B write
phash	LDR r12, =0x23
	B write
pzero	LDR r12, =0x0
	B write
pstar	LDR r12, =0x2A
	B write	
write	LDR r0, = USART2_BASE
		LDR r1, [r0, #USART_ISR]
		AND r1, r1, #USART_ISR_TXE
		CMP r1, #0
		BEQ setTDR
		BNE write
setTDR	LDR r0, = USART2_BASE
		STR r12, [r0, #USART_TDR]
		B st
	ENDP

	END
