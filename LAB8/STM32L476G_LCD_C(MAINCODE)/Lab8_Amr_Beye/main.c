#include "stm32l476xx.h"
#include "lcd.h"
//#include "LCD.c"
#include "SysClock.h"
#include "ADC.h"
#include "SysTimer.h"
#include <stdio.h> 
#include <string.h>

//*************************************  32L476GDISCOVERY ***************************************************************************
// STM32L4:  STM32L476VGT6 MCU = ARM Cortex-M4 + FPU + DSP, 
//           LQFP100, 1 MB of Flash, 128 KB of SRAM
//           Instruction cache = 32 lines of 4x64 bits (1KB)
//           Data cache = 8 lines of 4x64 bits (256 B)
//
// Joystick (MT-008A): 
//   Right = PA2        Up   = PA3         Center = PA0
//   Left  = PA1        Down = PA5
//
// User LEDs: 
//   LD4 Red   = PB2    LD5 Green = PE8
//   
// CS43L22 Audio DAC Stereo (I2C address 0x94):  
//   SAI1_MCK = PE2     SAI1_SD  = PE6    I2C1_SDA = PB7    Audio_RST = PE3    
//   SAI1_SCK = PE5     SAI1_FS  = PE4    I2C1_SCL = PB6                                           
//
// MP34DT01 Digital MEMS microphone 
//    Audio_CLK = PE9   Audio_DIN = PE7
//
// LSM303C eCompass (a 3D accelerometer and 3D magnetometer module): 
//   MEMS_SCK  = PD1    MAG_DRDY = PC2    XL_CS  = PE0             
//   MEMS_MOSI = PD4    MAG_CS  = PC0     XL_INT = PE1       
//                      MAG_INT = PC1 
//
// L3GD20 Gyro (three-axis digital output): 
//   MEMS_SCK  = PD1    GYRO_CS   = PD7
//   MEMS_MOSI = PD4    GYRO_INT1 = PD2
//   MEMS_MISO = PD3    GYRO_INT2 = PB8
//
// ST-Link V2 (Virtual com port, Mass Storage, Debug port): 
//   USART_TX = PD5     SWCLK = PA14      MFX_USART3_TX   MCO
//   USART_RX = PD6     SWDIO = PA13      MFX_USART3_RX   NRST
//   PB3 = 3V3_REG_ON   SWO = PB5      
//
// Quad SPI Flash Memory (128 Mbit)
//   QSPI_CS  = PE11    QSPI_D0 = PE12    QSPI_D2 = PE14
//   QSPI_CLK = PE10    QSPI_D1 = PE13    QSPI_D3 = PE15
//
// LCD (24 segments, 4 commons, multiplexed 1/4 duty, 1/3 bias) on DIP28 connector
//   VLCD = PC3
//   COM0 = PA8     COM1  = PA9      COM2  = PA10    COM3  = PB9
//   SEG0 = PA7     SEG6  = PD11     SEG12 = PB5     SEG18 = PD8
//   SEG1 = PC5     SEG7  = PD13     SEG13 = PC8     SEG19 = PB14
//   SEG2 = PB1     SEG8  = PD15     SEG14 = PC6     SEG20 = PB12
//   SEG3 = PB13    SEG9  = PC7      SEG15 = PD14    SEG21 = PB0
//   SEG4 = PB15    SEG10 = PA15     SEG16 = PD12    SEG22 = PC4
//   SEG5 = PD9     SEG11 = PB4      SEG17 = PD10    SEG23 = PA6
// 
// USB OTG
//   OTG_FS_PowerSwitchOn = PC9    OTG_FS_VBUS = PC11    OTG_FS_DM = PA11  
//   OTG_FS_OverCurrent   = PC10   OTG_FS_ID   = PC12    OTG_FS_DP = PA12  
//
// PC14 = OSC32_IN      PC15 = OSC32_OUT
// PH0  = OSC_IN        PH1  = OSC_OUT 
// 
// PA4  = DAC1_OUT1 (NLMFX0 WAKEUP)   PA5 = DAC1_OUT2 (Joy Down)
// PA3  = OPAMP1_VOUT (Joy Up)        PB0 = OPAMP2_VOUT (LCD SEG21)
//
//****************************************************************************************************************
uint8_t th_bar[2] = {0x00,0x00};

#define BAR0_ON  th_bar[1] |= 8
#define BAR0_OFF th_bar[1] &= ~8
#define BAR1_ON  th_bar[0] |= 8
#define BAR1_OFF th_bar[0] &= ~8
#define BAR2_ON  th_bar[1] |= 2
#define BAR2_OFF th_bar[1] &= ~2
#define BAR3_ON  th_bar[0] |= 2 
#define BAR3_OFF th_bar[0] &= ~2 

int thecount = 0;
int calculateddistance = 0;
void PE_Init(void);
void System_Clock_Init(void);
void Bars();
void random(void);
void readReflectance();
void readDistance();

int main(void){

	int32_t result = 0;
	int result2, factor, tens = 0;
	float deci = 0;
	float voltage =0;
	int distance = 0;
	
	System_Clock_Init();
	SysTick_Init();
	PE_Init();
	ADC_Init();
	LCD_Initialization();
	LCD_Clear();
	LCD_bar();
	
	while(1){
	
	readReflectance(); // reads in two sensors
	readDistance(); // read distance sensors, set global distance for Bars
	Bars(); // set bars based on distance
	delay(600); // delay for 600 ms
	}
}

void readDistance(){
	
	int32_t result = 0;
	int result2, factor = 0;
	float deci = 0;
	int tens =0;
	float voltage =0;
	int distance = 0;	
	
	ADC1->CR |= ADC_CR_ADSTART;			
	while ( (ADC123_COMMON->CSR | ADC_CSR_EOC_MST) == 0);
	result = ADC1->DR;
	deci = result;deci = deci/4096; deci = deci *5;
	voltage = deci;
	
	voltage = 38.765/(voltage + 0.0547);
	calculateddistance = voltage - 2;
	
	if(voltage > 50) voltage = 50;
	char resultr[50]; 
	int num = voltage-2; 
	sprintf(resultr, "%d", num); 
	
	LCD_DisplayString((uint8_t*)resultr);
}

void readReflectance(void){

	int32_t counter=0;
	int32_t counter2=0;
	int32_t threshold = (0x2000)/0.5 ;// basically 0x4000
	
			
		GPIOE->MODER |= 1U<<(2*15);      //  Output(01)	
		GPIOE->MODER |= 1U<<(2*14);      //  Output(01)	
	
	
		GPIOE->ODR &= ~(1U<<15); // set output for PE15 to 1
		GPIOE->ODR |=1U<<15;
		
		delay(100);// wait 100ms to charge capacitor
				
		GPIOE->MODER &= ~(3U<<(2*15)); //pe15 as input
	
		while (GPIOE->IDR & 0x8000) counter++; // count while capacitor is discharging, higher than threshold means Black otherwise White
		
		if (counter>threshold)
			LCD_WriteChar((uint8_t*)"B",0,0,3);// displays sensor #2, when above threshold and low reflectance
		else
			LCD_WriteChar((uint8_t*)"W",0,0,3);// displays sensor #2, when below threshold
	
		
		GPIOE->ODR &= ~(1U<<14); // output 1 to PE14
		GPIOE->ODR |=1U<<14;
		
		delay(100);
				
		GPIOE->MODER &= ~(3U<<(2*14)); //pe14 as input
		
		while (GPIOE->IDR & 0x4000) counter2++;
		
		if ((counter2)>threshold)
			LCD_WriteChar((uint8_t*)"B",0,0,2);
		else
			LCD_WriteChar((uint8_t*)"W",0,0,2);
		
		counter =0;
		counter2 =0;

}

void Bars(){
		
		// TO wait LCD Ready *
  while ((LCD->SR & LCD_SR_UDR) != 0); // Wait for Update Display Request Bit
	// Bar 0: COM3, LCD_SEG11 -> MCU_LCD_SEG8
	// Bar 1: COM2, LCD_SEG11 -> MCU_LCD_SEG8
	// Bar 2: COM3, LCD_SEG9 -> MCU_LCD_SEG25
	// Bar 3: COM2, LCD_SEG9 -> MCU_LCD_SEG25
	
  LCD->RAM[4] &= ~(1U << 8 | 1U << 25);
  LCD->RAM[6] &= ~(1U << 8 | 1U << 25);
	
  /* bar1 bar3 */
  if ((BAR0_ON) && calculateddistance > 13)
		LCD->RAM[6] |= 1U << 8;
  
  if ((BAR1_ON) && calculateddistance > 19)
		LCD->RAM[4] |= 1U << 8;
 
	if ((BAR2_ON) && calculateddistance > 25)
		LCD->RAM[6] |= 1U << 25;
  
  if ((BAR3_ON)){
		if(calculateddistance > 35)
			LCD->RAM[4] |= 1U << 25;
	}
	LCD->SR |= LCD_SR_UDR; 

}

void PE_Init(void){
/* Enable GPIOs clock */ 	
	RCC->AHB2ENR |=   RCC_AHB2ENR_GPIOEEN;
	
	//////////////////////////////////////////////////////////////////////////////////////////
	// PE8 and PE15
	//////////////////////////////////////////////////////////////////////////////////////////
	// GPIO Mode: Input(00, reset), Output(01), AlterFunc(10), Analog(11, reset)
	GPIOE->MODER &= ~(3U<<(2*15));  
	GPIOE->MODER |= 1U<<(2*15);      //  Output(01)

	GPIOE->MODER &= ~(3U<<(2*8));  
	GPIOE->MODER |= 1U<<(2*8);      //  Output(01)

	
	// GPIO Speed: Low speed (00), Medium speed (01), Fast speed (10), High speed (11)
	GPIOE->OSPEEDR &= ~(3U<<(2*15));
	GPIOE->OSPEEDR |=   3U<<(2*15);  // High speed

	GPIOE->OSPEEDR &= ~(3U<<(2*8));
	GPIOE->OSPEEDR |=   3U<<(2*8);  // High speed

	
	// GPIO Output Type: Output push-pull (0, reset), Output open drain (1) 
	GPIOE->OTYPER &= ~(1U<<15);       // Push-pull
	GPIOE->OTYPER &= ~(1U<<8);       // Push-pull

	// GPIO Push-Pull: No pull-up, pull-down (00), Pull-up (01), Pull-down (10), Reserved (11)
	GPIOE->PUPDR   &= ~(3U<<(2*15));  // No pull-up, no pull-down
	GPIOE->PUPDR   &= ~(3U<<(2*8));  // No pull-up, no pull-down
}

void randomDisplay(void){

		thecount = (thecount > 59) ? thecount = 0 : thecount++;
		thecount++;
		char result[50]; 
		float num = thecount; 
		sprintf(result, "%f", num); 
		
		char part1[] = "HH:MM:";
		char sectens[] = "0";
		if(thecount<10)strcat(part1,sectens);
		strcat(part1,result);
		
		LCD_DisplayString((uint8_t*)part1);
		delay(8000);
}
