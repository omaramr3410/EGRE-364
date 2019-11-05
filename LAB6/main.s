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
	
	
	
	
	
start	
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	STR r3, [r2, #GPIO_ODR]
	LDR r9, = 50000
	B delaya
	
checkcols	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xF
	AND r7,r6,r5
	CMP r7,#(0xF)
	BEQ start
	BL delaya ; button pressed 
	
delaya CMP r9, #0
	   SUB r9,r9,#1
	   BNE delaya
	   B checkcols
test1110
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0xE<<12)
	STR r3, [r2, #GPIO_ODR]
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xE
	AND r7,r6,r5
	CMP r7,#(0xE)
	BEQ cols1  ;pressed button in row 1
	BNE test1101 

test1101 
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0xD<<12)
	STR r3, [r2, #GPIO_ODR]
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xD
	AND r7,r6,r5
	CMP r7,#(0xD)
	BEQ cols2  ;pressed button in row 2
	BNE test1011 

test1011 
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0xB<<12)
	STR r3, [r2, #GPIO_ODR]
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xB
	AND r7,r6,r5
	CMP r7,#(0xB)
	BEQ cols3  ;pressed button in row 3
	BNE test0111

test0111 
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x7<<12)
	STR r3, [r2, #GPIO_ODR]
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x7
	AND r7,r6,r5
	CMP r7,#(0x7)
	BEQ cols4  ;pressed button in row 4
	BNE start ; restart since not read as pressed 

	
cols1 
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	STR r3, [r2, #GPIO_ODR]
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xE
	AND r7,r6,r5
	CMP r7,#(0xE)
	BEQ.W pressedA ; button A pressed
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xD
	AND r7,r6,r5
	CMP r7,#(0xD)
	BEQ.W pressed3 ; button 3 pressed
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xB
	AND r7,r6,r5
	CMP r7,#(0xB)
	BEQ.W pressed2 ; button 2 pressed

	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x7
	AND r7,r6,r5
	CMP r7,#(0x7)
	BEQ.W pressed1 ; button 1 pressed



cols2
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	STR r3, [r2, #GPIO_ODR]
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xE
	AND r7,r6,r5
	CMP r7,#(0xE)
	BEQ pressedB ; button B pressed
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xD
	AND r7,r6,r5
	CMP r7,#(0xD)
	BEQ pressed6 ; button 6 pressed
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xB
	AND r7,r6,r5
	CMP r7,#(0xB)
	BEQ pressed5 ; button 5 pressed

	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x7
	AND r7,r6,r5
	CMP r7,#(0x7)
	BEQ pressed4 ; button 4 pressed
	


cols3
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	STR r3, [r2, #GPIO_ODR]
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xE
	AND r7,r6,r5
	CMP r7,#(0xE)
	BEQ pressedC ; button A pressed
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xD
	AND r7,r6,r5
	CMP r7,#(0xD)
	BEQ pressed9 ; button 9 pressed
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xB
	AND r7,r6,r5
	CMP r7,#(0xB)
	BEQ pressed8 ; button 8 pressed

	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x7
	AND r7,r6,r5
	CMP r7,#(0x7)
	BEQ pressed7 ; button 7 pressed



cols4
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	STR r3, [r2, #GPIO_ODR]
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xE
	AND r7,r6,r5
	CMP r7,#(0xE)
	BEQ pressedD ; button D pressed
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xD
	AND r7,r6,r5
	CMP r7,#(0xD)
	BEQ pressedhash ; button # pressed
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0xB
	AND r7,r6,r5
	CMP r7,#(0xB)
	BEQ pressed0 ; button 0 pressed

	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x7
	AND r7,r6,r5
	CMP r7,#(0x7)
	BEQ pressedstar ; button * pressed
pressedB
	LDR r12, =0x42
	B write
write	LDR r0, = USART2_BASE
		LDR r1, [r0, #USART_ISR]
		AND r1, r1, #USART_ISR_TXE
		CMP r1, #0
		BEQ setTDR
		BNE write
setTDR	LDR r0, = USART2_BASE
		STR r12, [r0, #USART_TDR]
		B start


pressedA
	LDR r12, =0x41
;	BL write
	B write

pressed3
	LDR r12, =0x3

	B write
	
pressed2 
	LDR r12, =0x2

	B write
	
pressed1
	LDR r12, =0x1

	B write
	

pressed6
	LDR r12, =0x6

	B write

pressed5 
	LDR r12, =0x5

	B write

pressed4	
	LDR r12, =0x4

	B write

pressedC
	LDR r12, =0x43

	B write
	
pressed9
	LDR r12, =0x9

	B write

pressed8 
	LDR r12, =0x8

	B write

pressed7
	LDR r12, =0x7

	B write

pressedD
	LDR r12, =0x44

	B write

pressedhash
	LDR r12, =0x23

	B write

pressed0
	LDR r12, =0x0

	B write

pressedstar
	LDR r12, =0x2A
	
	B write
	

	
		
	
	
	
	
	
stop 	B 		stop     		; dead loop & program hangs here

	ENDP
					
	ALIGN			

	AREA    myData, DATA, READWRITE
	ALIGN
;array	DCD   1, 2, 3, 4
;mask    DCD   0x3F,0x6,0x1B,0x,0x,0x,0x,0x,0x ;array of masks for port E
	END
