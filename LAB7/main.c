/* Papa Beye 
   Omar Amr
   Fall 2019 
   EGRE 364 Microcomputer System
   Professor Zhao
*/

#include "stm32l476xx.h" // Stm32l476xx header file
#define BLINKRED 0
#define GREENOFF 1
#define GREENON 2

uint32_t msTicks=0; // Unassigned int 32 variable for timer system

int toggle = GREENOFF;
int delay_time = 1000;


//******************************************************************************************
// Initialize SysTick	
//******************************************************************************************	
void SysTick_Init(void){
	
	//  SysTick Control and Status Register
	SysTick->CTRL = 0;										// Disable SysTick IRQ and SysTick Counter
	
	// SysTick Reload Value Register
	SysTick->LOAD = 1000 - 1;    // 1ms, Default clock
	
	// SysTick Current Value Register
	SysTick->VAL = 0;

	NVIC_SetPriority(SysTick_IRQn, 1);		// Set Priority to 1
	NVIC_EnableIRQ(SysTick_IRQn);					// Enable EXTI0_1 interrupt in NVIC

	// Enables SysTick exception request
	// 1 = counting down to zero asserts the SysTick exception request
	// 0 = counting down to zero does not assert the SysTick exception request
	SysTick->CTRL |= SysTick_CTRL_TICKINT_Msk;
	
	// Select processor clock
	// If CLKSOURCE = 0, the external clock is used. The frequency of SysTick clock is the frequency of the AHB clock divided by 8.
	// If CLKSOURCE = 1, the processor clock is used.
	SysTick->CTRL &= ~SysTick_CTRL_CLKSOURCE_Msk;		
	
	// Enable SysTick IRQ and SysTick Timer
	SysTick->CTRL |= SysTick_CTRL_ENABLE_Msk;  
}



void SysTick_Handler(void) {
	msTicks++; // Increment msTicks Var
}

void Delay (uint32_t dlyTicks) {   // delay function for time delay between GPIO outputs
	uint32_t curTicks;     // Local variable unassigned integer 32 for current system time
	curTicks = msTicks;    // set current time to system time
	while ((msTicks - curTicks) < dlyTicks); // wait until dlyticks elapse

	msTicks = 0;
}

void GPIOInit (){
	
	// Enable High Speed Internal Clock (HSI = 16 MHz)
  RCC->CR |= ((uint32_t)RCC_CR_HSION);
	
  // wait until HSI is ready
  while ( (RCC->CR & (uint32_t) RCC_CR_HSIRDY) == 0 ) {;}
	
  // Select HSI as system clock source 
  RCC->CFGR &= (uint32_t)((uint32_t)~(RCC_CFGR_SW));
  RCC->CFGR |= (uint32_t)RCC_CFGR_SW_HSI;  //01: HSI16 oscillator used as system clock

  // Wait till HSI is used as system clock source 
  while ((RCC->CFGR & (uint32_t)RCC_CFGR_SWS) == 0 ) {;}
  
  // Enable the clock to GPIO Port B	
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOBEN; 
  // Enable the clock to GPIO Port E
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOEEN;
  // Enable the clock to GPIO Port A
  RCC->AHB2ENR |= RCC_AHB2ENR_GPIOAEN;
			
  // MODE: 00: Input mode, 
  //       01: General purpose output mode
  //       10: Alternate function mode, 
  //       11: Analog mode (reset state)
  GPIOB->MODER &= ~(0x03<<(2*2)) ;   // Clear bit 4 and bit 5 on GPIO Mode Register 
  GPIOB->MODER |= (1<<4);      // sets bit 4 and bit 5 on GPIO Mode Register to 01(General purpose output mode). This is mode bits for GPIOB port 2
	GPIOE->MODER &= ~(0x03<<16); // Clear bit 16 and bit 17 on GPIO Mode Register 
	GPIOE->MODER |= (0x1<<16);  // sets bit 16 and bit 17 on GPIO Mode Register to 01(General purpose output mode). This is mode bits for GPIOE port 8

	GPIOA->MODER &= ~(0xCFF); // sets pin 0,1,2,3,5 as input 
	GPIOA->PUPDR &= ~(0xCFF); // clear bits
	GPIOA->PUPDR |= (0x8AA);	// sets pins as pull down
		
		
  //Initialize GIPO to output high
  GPIOB->ODR |= GPIO_ODR_ODR_2; // sets GPIOB port 2 ODR register to 1
		
}

void InterruptInit(){
	
	//Enable Interrupts
	NVIC_EnableIRQ(EXTI0_IRQn);
	NVIC_EnableIRQ(EXTI1_IRQn);
	NVIC_EnableIRQ(EXTI2_IRQn);
	NVIC_EnableIRQ(EXTI3_IRQn);
	//NVIC_EnableIRQ(EXTI9_5_IRQn);
	
	
	//Set SYSCFG external interrupt config
	RCC->APB2ENR |= RCC_APB2ENR_SYSCFGEN;
	SYSCFG->EXTICR[0] &= ~SYSCFG_EXTICR1_EXTI0;
	SYSCFG->EXTICR[0] |= SYSCFG_EXTICR1_EXTI0_PA;
	SYSCFG->EXTICR[0] &= ~SYSCFG_EXTICR1_EXTI1;
	SYSCFG->EXTICR[0] |= SYSCFG_EXTICR1_EXTI1_PA;
	SYSCFG->EXTICR[0] &= ~SYSCFG_EXTICR1_EXTI2;
	SYSCFG->EXTICR[0] |= SYSCFG_EXTICR1_EXTI2_PA;
	SYSCFG->EXTICR[0] &= ~SYSCFG_EXTICR1_EXTI3;
	SYSCFG->EXTICR[0] |= SYSCFG_EXTICR1_EXTI3_PA;
	
	
	//rising edge selection
	EXTI->RTSR1 |= EXTI_RTSR1_RT0;
	EXTI->RTSR1 |= EXTI_RTSR1_RT1;
	EXTI->RTSR1 |= EXTI_RTSR1_RT2;
	EXTI->RTSR1 |= EXTI_RTSR1_RT3;
	
	//Interrupt Mask Register
	// 0 = masked, 1 = not masked (enabled)
	EXTI->IMR1 |= EXTI_IMR1_IM0;
	EXTI->IMR1 |= EXTI_IMR1_IM1;
	EXTI->IMR1 |= EXTI_IMR1_IM2;
	EXTI->IMR1 |= EXTI_IMR1_IM3;
}


void EXTI0_IRQHandler(){
	if((EXTI->PR1 & EXTI_PR1_PIF0) != 0){
			
		GPIOE->ODR ^= GPIO_ODR_ODR_8;
		//clear interrupt pending flag by writing 1 
		EXTI->PR1 |= EXTI_PR1_PIF0;
	}
}

void EXTI1_IRQHandler(){
		if((EXTI->PR1 & EXTI_PR1_PIF1) != 0){
		
			delay_time -= 50;
		
		//clear interrupt pending flag by writing 1 
		EXTI->PR1 |= EXTI_PR1_PIF1;
	}
}


void EXTI2_IRQHandler(){
		if((EXTI->PR1 & EXTI_PR1_PIF2) != 0){
		
			delay_time += 50;
		
		//clear interrupt pending flag by writing 1 
		EXTI->PR1 |= EXTI_PR1_PIF2;
	}
}


int main(){
	
	
	GPIOInit();
	InterruptInit();
	SysTick_Init();

	while(1){// forever loop
			
		GPIOB->ODR |= GPIO_ODR_ODR_2; // sets GPIOB port 2 ODR register to 1
		Delay(delay_time); // Delay by counting to 2000000
		GPIOB->ODR &= ~GPIO_ODR_ODR_2; // sets GPIOB port 2 ODR register to 0
		Delay(delay_time); // Delay by counting to 1000000
	}
}
