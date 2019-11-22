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
	
SysTick_Initalize PROC  ; initalize SysTick to count every 1 ms 
  EXPORT SysTick_Initalize
	  
	  LDR r0, =SysTick_BASE
	  
	  MOV r1, #0
	  STR r1, [r0, #SysTick_CTRL]
	
	  LDR r2, =999
	  STR r2, [r0, #SysTick_LOAD]
	
	  MOV r1, #0
	  STR r1, [r0, #SysTick_VAL]	
	
	  LDR r2, =SCB_BASE 
	  ADD r2, r2, #SCB_SHP 
	  MOV r3, #(1<<4)
	  STRB r3, [r2, #11]
	  
	  LDR r1, [r0, #SysTick_CTRL]
	  ORR r1, r1, #3
	  STR r1, [r0, #SysTick_CTRL]
	  
	  BX LR; exit 
	
	ENDP

SysTick_Handler PROC
  EXPORT SysTick_Handler
	 
	ADD r11, #1 ; increments r11 variable for every 1 ms 	
	
	BX LR
	
	ENDP
		
Delay PROC ; delays for 1000ms
	
	;PUSH{r0,r1}
	LDR r2, =1000 ;amount of time you want elapsed (variable)
	MOV r0, r11 ; current time
Check
	SUB r1, r11, r0 ; time elapsed 
	CMP r1, r2
	BLT Check
	
	LDR r11, =0 ;set System timer to 0 
	;POP{r0,r1}
	BX LR
	ENDP 

PortInit PROC
	
	; Enable the clock to GPIO Port E, B
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIOEEN
	STR r1, [r0, #RCC_AHB2ENR]
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIOBEN
	STR r1, [r0, #RCC_AHB2ENR]

	
	; MODE: 00: Input mode, 01: General purpose output mode
    ;       10: Alternate function mode, 11: Analog mode (reset state)
	
	; Setup MODE register of both Ports
	LDR r0, =GPIOB_BASE
	LDR r1, [r0, #GPIO_MODER] ;1 01 01 01 01 01 00 00 00 00 00 00 00 00 00 00
	LDR r3, =(0x3<<4)
	LDR r4, =(1<<4)
	BIC r1, r1,  r3 ; clear bit 4 and bit 5
	ORR r1, r1,  r4 ; set bit 4
	STR r1, [r0, #GPIO_MODER]
	
	
	LDR r0, =GPIOE_BASE
	LDR r1, [r0, #GPIO_MODER] ;1 01 01 01 01 01 00 00 00 00 00 00 00 00 00 00
	LDR r2,=(0x3<<16)
	LDR r3,=(0x1<<16)
	BIC r1, r1, r2
	ORR r1, r1, r3
	STR r1, [r0, #GPIO_MODER]
	
	
	; Initalize both LEDs as high
	LDR r2, =GPIOB_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0x4)
	ORR r3, r3, #(0x4) 
	STR r3, [r2, #GPIO_ODR]
	
	LDR r2, =GPIOE_BASE     
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0x80)
	ORR r3, r3, #(0x80) 
	STR r3, [r2, #GPIO_ODR]
	
	BX LR
	
	ENDP


PortInit2 PROC ; initalize GPO port A 
	
	LDR r0, =RCC_BASE
	LDR r1, [r0, #RCC_AHB2ENR]
	ORR r1, r1, #RCC_AHB2ENR_GPIOAEN
	STR r1, [r0, #RCC_AHB2ENR]
	
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_MODER] ;1 01 01 01 01 01 00 00 00 00 00 00 00 00 00 00
	LDR r2,=(0x3)
	BIC r1, r1, r2
	STR r1, [r0, #GPIO_MODER]
	
	LDR r0, =GPIOA_BASE
	LDR r1, [r0, #GPIO_MODER] ;1 01 01 01 01 01 00 00 00 00 00 00 00 00 00 00
	LDR r2,=(0x3)
	BIC r1, r1, r2
	STR r1, [r0, #GPIO_MODER]
	
	BX LR
	ENDP 
	
__main	PROC
	
	BL SysTick_Initalize
	BL PortInit
	BL PortInit2

;while(1)
branchl
	LDR r2, =GPIOB_BASE     ; turn on LED
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0x4)
	ORR r3, r3, #(0x4) 
	STR r3, [r2, #GPIO_ODR]
	
	;BL Delay 
	BL delay 
	
	LDR r2, =GPIOB_BASE     ; turn off LED
	LDR r3, [r2, #GPIO_ODR]
	BIC r3, r3, #(0x4) 
	STR r3, [r2, #GPIO_ODR]
	
	;BL Delay
BL delay
	
	B branchl
	
delay  LDR r8, =1000000
delaya CMP r8, #0
	   SUB r8,r8,#1
	   BNE delaya
	   BX LR	
	   
	ENDP

EXTI_Init PROC
	
	
	
	ENDP


EXTI0_IRQHandler PROC
	
	
	
	
	
	ENDP
		
	AREA    myData, DATA, READWRITE
	ALIGN
steps	DCD   0x1<<12, 0x3<<12, 0x1<<13,0x3<<13, 0x1<<14, 0x3<<14, 0x1<<15,0x9<<12
delaymin DCD  0x190 ; sets delay variable to 400
	END	