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
	LDR r12, =10000 ; base delay var
	LDR r11, =30000 ; delay max
	LDR r10, =2000  ; delay min
	
	B full

; post lab - acheived by implementing reverse order of steps for full and half step process and branch back and forth


full
	LDR r2, =GPIOE_BASE
	LDR r3, [r2, #GPIO_ODR]; step 1
	BIC r3, r3, #(0xF<<12) ; clear 4 bits 
	ORR r3, r3, #(0x1<<12) ; Set PE12
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE      ; step 2
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12) ; clear 4 bits 
	ORR r3, r3, #(0x1<<13)  ; Set PE13
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	 
	LDR r2, =GPIOE_BASE    ; step 3
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)  ; clear 4 bits 
	ORR r3, r3, #(0x1<<14)  ; Set PE14
	STR r3, [r2, #GPIO_ODR]
	BL delay 
		
	LDR r2, =GPIOE_BASE      ; step 4
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12) ; clear 4 bits 
	ORR r3, r3, #(0x1<<15)  ; Set PE15
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	BL checkA12  ; checks if left or right button is pressed, switch between full or half subroutine 
	BL checkA35  ; checks if up or down button pressed and manipulates the speed
	
	BL fullreverse

half
	LDR r2, =GPIOE_BASE     ; step 1 
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)  
	ORR r3, r3, #(0x1<<12)  ; sets PE12
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 2
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x3<<12) ; sets PE12,13
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 3
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x1<<13)  ; sets PE13
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 4
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x3<<13) ; sets PE13,14
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 5
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x1<<14)  ; sets PE14
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE		; step 6
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x3<<14) ; sets PE14,15
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 7 
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x1<<15) ; sets PE15
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 8 
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x9<<12) ; sets PE12, 15
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	BL checkA12
	BL checkA35
	
	BL halfreverse
 
 ;reversed order of steps of full step
fullreverse
	LDR r2, =GPIOE_BASE
	LDR r3, [r2, #GPIO_ODR]; step 1
	BIC r3, r3, #(0xF<<12) ; clear 4 bits 
	ORR r3, r3, #(0x1<<15)  ; Set PE15 
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE      ; step 2
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12) ; clear 4 bits 
	ORR r3, r3, #(0x1<<14)  ; Set PE14  
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	 
	LDR r2, =GPIOE_BASE    ; step 3
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)  ; clear 4 bits 
	ORR r3, r3, #(0x1<<13)  ; Set PE13
	STR r3, [r2, #GPIO_ODR]
	BL delay 
		
	LDR r2, =GPIOE_BASE      ; step 4
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12) ; clear 4 bits 
	ORR r3, r3, #(0x1<<12) ; Set PE12
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	BL checkA12  ; checks if left or right button is pressed, switch between full or half subroutine 
	BL checkA35  ; checks if up or down button pressed and manipulates the speed
	
	BL full


;reversed order of steps of half step
halfreverse
	LDR r2, =GPIOE_BASE     ; step 1 
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)  
	ORR r3, r3, #(0x9<<12) ; sets PE12,15
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 2
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x1<<15) ; sets PE15
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 3
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x3<<14)  ; sets PE14,15
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 4
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x1<<14) ; sets PE14
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 5
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x3<<13) ; sets PE13,14
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE		; step 6
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x1<<13) ; sets PE13
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 7 
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x3<<12)  ; sets PE12,13
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	LDR r2, =GPIOE_BASE     ; step 8 
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0xF<<12)
	ORR r3, r3, #(0x1<<12)  ; sets PE12
	STR r3, [r2, #GPIO_ODR]
	BL delay 
	
	BL checkA12
	BL checkA35
	
	BL half



checkA35	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x8
	AND r7,r6,r5
	CMP r7,r6
	BEQ incspeed
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x20
	AND r7,r6,r5
	CMP r7,r6
	BEQ decspeed

checkA12
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x2
	
	AND r7,r6,r5
	CMP r7,r6
	BEQ half
	
	LDR r4, =GPIOA_BASE 
	LDR r5,[r4,#GPIO_IDR]
	LDR r6, =0x4
	AND r7,r6,r5
	CMP r7,r6
	BEQ full
	

	
delay  MOV r9,r12
delaya CMP r9, #0
	   SUB r9,r9,#1
	   BNE delaya
	   BX LR	
	
incspeed 
		SUB r12,#100
		CMP r12,r10
		BGE delay
		MOV r12,r10
		B delay
		 

decspeed 
		ADD r12,#100
		CMP r12,r11
		BLE delay
		MOV r12,r11
		B delay
		 
ENDP


		
	AREA    myData, DATA, READWRITE
	ALIGN
steps	DCD   0x1<<12, 0x3<<12, 0x1<<13,0x3<<13, 0x1<<14, 0x3<<14, 0x1<<15,0x9<<12
delaymin DCD  0x190 ; sets delay variable to 400
	END	