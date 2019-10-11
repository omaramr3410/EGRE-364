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
	LDR r3, =0xFFF00000
	LDR r4, =0x55500000
	BIC r1, r1,  r3
	ORR r1, r1,  r4
	STR r1, [r0, #GPIO_MODER]
	
	LDR r0, =GPIOH_BASE
	LDR r1, [r0, #GPIO_MODER] ;1 01 01 01 01 01 00 00 00 00 00 00 00 00 00 00
	BIC r1, r1,  #(0x3<<0)
	ORR r1, r1,  #(0x1<<0)
	STR r1, [r0, #GPIO_MODER]
	
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_MODER] ;1 01 01 01 01 01 00 00 00 00 00 00 00 00 00 00
	BIC r1, r1,  #(0xcc<<4)
	STR r1, [r0, #GPIO_MODER]
	
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_PUPDR]
	BIC r1, r1,  #(0xcc<<4)
	ORR r1, r1, #(0x88<<4)
	STR r1, [r0, #GPIO_PUPDR]
	
	MOVS          r0,#0x00
	STR           r0,[sp,#0x04] ; Counnt to display 
	MOVW          r0,#0xC350
	STR           r0,[sp,#0x08] ; Threshold Counter 
	B disp
  
	
	
	

stop 	B 		stop     		; dead loop & program hangs here
st	LDR r0, [sp,#0x04]
	CMP r0, #0x10
	BGE.W se0
	CMP r0, #0x0
	BLT.W se15
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_IDR]
	LDR r2, =0x28
	AND r1, r1, r2
	CMP r1,#0x8
	LDR r0,[sp,#0x08]
	BEQ A3bd
	BNE ct5
ct5 LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_IDR]
	LDR r2, =0x28
	AND r1, r1, r2
	CMP r1,#0x20
	LDR r0,[sp,#0x08]
	BEQ A5bd
	BNE st
A5bd  CMP r0, #0x0
	  BEQ A5check
	  BNE A5dbc
A5dbc SUB r0, r0, #0x1
	  B A5bd
A5check LDR r0, =GPIOA_BASE
		LDR r1, [r0, #GPIO_IDR]
		LDR r2, =0x28
		AND r1, r1, r2
		CMP r1,#0x20
		BEQ A5check
		BNE dec
	

A3bd  CMP r0, #0x0
	  BEQ A3check
	  BNE A3dbc
A3dbc SUB r0, r0, #0x1
	  B A3bd
A3check LDR r0, =GPIOA_BASE
		LDR r1, [r0, #GPIO_IDR]
		LDR r2, =0x28
		AND r1, r1, r2
		CMP r1,#0x8  
		BEQ A3check
		BNE inc
inc LDR r0,[sp,#0x04]
	ADD r0, r0 ,#0x1
	STR r0, [sp,#0x04]
	B disp
	
dec LDR r0,[sp,#0x04]
	SUB r0, r0 ,#0x1
	STR r0, [sp,#0x04]
	B disp
	
disp	LDR r0, [sp,#0x04]
		CMP r0, #0x0
		BEQ case_0
		CMP r0, #0x1
		BEQ case_1
		CMP r0, #0x2
		BEQ case_2
		CMP r0, #0x3
		BEQ case_3
		CMP r0, #0x4
		BEQ case_4
		CMP r0, #0x5
		BEQ case_5
		CMP r0, #0x6
		BEQ case_6
		CMP r0, #0x7
		BEQ case_7
		CMP r0, #0x8
		BEQ case_8
		CMP r0, #0x9
		BEQ case_9
		CMP r0, #0xA
		BEQ case_10
		CMP r0, #0xB
		BEQ case_11
		CMP r0, #0xC
		BEQ case_12
		CMP r0, #0xD
		BEQ case_13
		CMP r0, #0xE
		BEQ case_14
		CMP r0, #0xF
		BEQ case_15
case_0  MOVS r8, #0x3f
		B switchSet
case_1	MOVS r8, #0x06
		B switchSet
case_2	MOVS r8, #0x5b
		B switchSet
case_3	MOVS r8, #0x4f
		B switchSet
case_4	MOVS r8, #0x66
		B switchSet
case_5	MOVS r8, #0x6d
		B switchSet
case_6	MOVS r8, #0x7d
		B switchSet
case_7	MOVS r8, #0x07
		B switchSet
case_8	MOVS r8, #0x7f
		B switchSet
case_9	MOVS r8, #0x6f
		B switchSet
case_10	MOVS r8, #0x77
		B switchSet
case_11	MOVS r8, #0x7c
		B switchSet
case_12	MOVS r8, #0x39
		B switchSet
case_13	MOVS r8, #0x5e
		B switchSet
case_14	MOVS r8, #0x79
		B switchSet
case_15	MOVS r8, #0x71
		B switchSet

se0  MOVS r0, #0x0
		STR r0,[sp,#0x04]
		B disp
se15	MOVS r0, #0xf
		STR r0,[sp,#0x04]
		B disp
switchSet 	MOVS r1,#0x01
			MOVS r2,#0x02
			MOVS r3,#0x04
			MOVS r4,#0x08
			MOVS r5,#0x10
			MOVS r6,#0x20
			MOVS r7,#0x40
			AND r9, r8,r1
			CMP r9,r1
			BEQ gpe10
			BNE gpe10_0
sw11		AND r9, r8,r2
			CMP r9,r2
			BEQ gpe11
			BNE gpe11_0
sw12		AND r9, r8,r3
			CMP r9,r3
			BEQ gpe12
			BNE gpe12_0
sw13		AND r9, r8,r4
			CMP r9,r4
			BEQ gpe13
			BNE gpe13_0
sw14		AND r9, r8,r5
			CMP r9,r5
			BEQ gpe14
			BNE gpe14_0
sw15		AND r9, r8,r6
			CMP r9,r6
			BEQ gpe15
			BNE gpe15_0
sw16		AND r9, r8,r7
			CMP r9,r7
			BEQ gph0
			BNE gph0_0
			B st
	
gpe10 	LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		ORR r10, r10,  #(0x1<<10)
		STR r10, [r0, #GPIO_ODR]
		B sw11
		
gpe10_0 LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		BIC r10, r10,  #(0x1<<10)
		STR r10, [r0, #GPIO_ODR]
		B sw11

gpe11 	LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		ORR r10, r10,  #(0x1<<11)
		STR r10, [r0, #GPIO_ODR]
		B sw12
		
gpe11_0 LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		BIC r10, r10,  #(0x1<<11)
		STR r10, [r0, #GPIO_ODR]
		B sw12
		
gpe12 	LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		ORR r10, r10,  #(0x1<<12)
		STR r10, [r0, #GPIO_ODR]
		B sw13
		
gpe12_0 LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		BIC r10, r10,  #(0x1<<12)
		STR r10, [r0, #GPIO_ODR]
		B sw13

gpe13 	LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		ORR r10, r10,  #(0x1<<13)
		STR r10, [r0, #GPIO_ODR]
		B sw14
		
gpe13_0 LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		BIC r10, r10,  #(0x1<<13)
		STR r10, [r0, #GPIO_ODR]
		B sw14
		
gpe14 	LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		ORR r10, r10,  #(0x1<<14)
		STR r10, [r0, #GPIO_ODR]
		B sw15
		
gpe14_0 LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		BIC r10, r10,  #(0x1<<14)
		STR r10, [r0, #GPIO_ODR]
		B sw15
		
gpe15 	LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		ORR r10, r10,  #(0x1<<15)
		STR r10, [r0, #GPIO_ODR]
		B sw16
		
gpe15_0 LDR r0, =GPIOE_BASE
		LDR r10, [r0, #GPIO_ODR]
		BIC r10, r10,  #(0x1<<15)
		STR r10, [r0, #GPIO_ODR]
		B sw16

gph0 	LDR r0, =GPIOH_BASE
		LDR r10, [r0, #GPIO_ODR]
		ORR r10, r10,  #(0x1<<0)
		STR r10, [r0, #GPIO_ODR]
		B st
		
gph0_0  LDR r0, =GPIOH_BASE
		LDR r10, [r0, #GPIO_ODR]
		BIC r10, r10,  #(0x1<<0)
		STR r10, [r0, #GPIO_ODR]
		B st
	ENDP
	END