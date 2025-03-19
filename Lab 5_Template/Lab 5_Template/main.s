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

	IMPORT 	System_Clock_Init
	IMPORT 	UART2_Init
	IMPORT	USART2_Write
	
	AREA    main, CODE, READONLY
	EXPORT	__main				; make __main visible to linker
	ENTRY			
				
__main	PROC
	
	;	Enable clocks for GPIOC, GPIOB//;	Enable clocks for GPIOA, GPIOB
	;;;;;;; INITIALIZATION ;;;;;;;;;;

		;ENABLES CLOCKS C AND B
_Cnfig LDR r0,=RCC_BASE; The base address of the reset and clock control
       LDR r1,[r0,#RCC_AHB2ENR];  stores base address of clock control to Reg 1
       ORR r1,#0x00000006; This is masking to enable clock B(out) and C(in)
       STR r1,[r0,#RCC_AHB2ENR]; storeing clock control to Reg 1
        
       ;GPIO C Config (input button)
       LDR r5,=GPIOC_BASE; The base address for GPIOC controls
       LDR r2,[r5,#GPIO_MODER];offseting to the MODER controls
       AND r2,#0xF3FFFFFF; seting pin 13 via bits 27 and 26 to zero (input mode for button)
       STR r2,[r5,#GPIO_MODER]; storinng back the new value to original reg
        
       ;GPIO B config  (for output pins)            
       LDR r0,=GPIOB_BASE
       LDR r3,[r0,#GPIO_MODER];offseting to the MODER controls
       ORR r3,#0xFFFFFFFF; clearing pins of moder for GPIOB
	   AND r3,#0xFFFF0FFF; clearing pins of moder for GPIOB
       EOR r3,#0xF0;0xFFFF0F0F
       ORR r3,#0x00005000; seting mode of external pins to output ()
       ORR r3, #0x50;0xFFFF5F5F
       STR r3,[r0,#GPIO_MODER]; storinng new value to original reg
		
	; Set GPIOC pin 13 (blue button) as an input pin//; Set GPIOA pin 0 (center joystick button) as an input pin
	
	;CHECKS IF BUTTON IS PRESSED INDEFINETLY
BLOOP   
	LDR r8, [r5, #GPIO_IDR]; setting r8 to be the value of IDR in GPIOC which contains the button
    AND r8, #0x2000;#1, LSL #13; anding with the the 13th bit which if button is not pressed  will contain a 1
    CMP r8, #0; checks this bit to see if button is pressed and register 8 is not equal to 0 if button is being pressed
    BEQ WinWIPE; DOES ONE WIPE 
    BEQ BLOOP; goes back to TOP TO CHECK IF BUTTON IS PRESSED
			
WinWIPE	
	MOV R2, #0
	MOV R4, #1150; STORES VALUES FOR LATER COMPARISON
WINLOOPF		;LOOPS UNTIL GOES ALL THE WAYS FORWARD
	ADD R2, #1; INCRIMENTS BY ONE SHOULD DO THIS LOOP 0 - 1150
	BLT fowFS; BRANCHES TO DO ONE FULL STEP
RETLOOPF
	CMP R2, R4;NEEDS TO DO 1151 STEPS IN ORDER TO GO 145 DEGREES
	BLT WINLOOPF; GOES BACK TO THE TOP OF LOOP IF NOT FULLY EXTENDED
	
	;WENT FORWARD NOW NEEDS TO GO BACK
	
WINLOOPB		;LOOPS UNTIL GOES ALL THE WAY BACKWARDS
	SUB R2, #1; DECRIMENTS BY ONE
	BGT bacFS;  BRANCHES TO DO ONW FULL STEP BACKWARDS
RETLOOPB		; THIS IS JUST A RETURN POINT TO BACK TO FUNCTION
	CMP R2, #0; GOES BACKWARDS AND UNDOS ALL STEPS
	BGT WINLOOPB; GOES BACK TO THE TOP UNLESS BACK AT STARTING POSITION
	
	BAL BLOOP ; BRANCHES BACK TO BUTTON LOOP NO THAT WIPER HAS RETURNED BACK
	
	
fowFS
	LDR R0, =GPIOB_BASE
	LDR R1, [R0,#GPIO_ODR]; LOADS THE VALUES OF THE PINS
	BIC R1, #0x000000CC; CLEARS PINS 2,3,6,7
	ORR R1, #0x00000048; 7 = 0, 6 = 1, 3 = 1, 2 = 0 STEP SEQ 1
	STR R1, [R0,#GPIO_ODR]; STORES VALUE OF PINS BACK TO GPIOB_ODR
	B delay
	BIC R1, #0x000000CC; CLEARS PINS 2,3,6,7
	ORR R1, #0x00000088; 7 = 1, 6 = 0, 3 = 1, 2 = 0 STEP SEQ 2
	STR R1, [R0,#GPIO_ODR]; STORES VALUE OF PINS BACK TO GPIOB_ODR
	B delay
	BIC R1, #0x000000CC; CLEARS PINS 2,3,6,7
	ORR R1, #0x00000084; 7 = 1, 6 = 0, 3 = 0, 2 = 1 STEP SEQ 3
	STR R1, [R0,#GPIO_ODR]; STORES VALUE OF PINS BACK TO GPIOB_ODR
	B delay
	BIC R1, #0x000000CC; CLEARS PINS 2,3,6,7
	ORR R1, #0x00000044; 7 = 0, 6 = 1, 3 = 0, 2 = 1 STEP SEQ 4
	STR R1, [R0,#GPIO_ODR]; STORES VALUE OF PINS BACK TO GPIOB_ODR
	B delay
	BAL RETLOOPF; RETURNS AFTER ONE FULL STEP FORWARD
	
bacFS
	BIC R1, #0x000000CC; CLEARS PINS 2,3,6,7
	ORR R1, #0x00000088; 7 = 1, 6 = 0, 3 = 1, 2 = 0 STEP SEQ 1
	STR R1, [R0,#GPIO_ODR]; STORES VALUE OF PINS BACK TO GPIOB_ODR
	B delay
	BIC R1, #0x000000CC; CLEARS PINS 2,3,6,7
	ORR R1, #0x00000048; 7 = 0, 6 = 1, 3 = 1, 2 = 0 STEP SEQ 2
	STR R1, [R0,#GPIO_ODR]; STORES VALUE OF PINS BACK TO GPIOB_ODR
	B delay
	BIC R1, #0x000000CC; CLEARS PINS 2,3,6,7
	ORR R1, #0x00000044; 7 = 0, 6 = 1, 3 = 0, 2 = 1 STEP SEQ 3
	STR R1, [R0,#GPIO_ODR]; STORES VALUE OF PINS BACK TO GPIOB_ODR
	B delay
	BIC R1, #0x000000CC; CLEARS PINS 2,3,6,7
	ORR R1, #0x00000084; 7 = 1, 6 = 0, 3 = 0, 2 = 1 STEP SEQ 4
	STR R1, [R0,#GPIO_ODR]; STORES VALUE OF PINS BACK TO GPIOB_ODR
	B delay
	BAL RETLOOPB; RETURNS AFTER ONE FULL STEP BACK
	
		
	ENDP		
	
	
delay	PROC
	; Delay for motor to move
	LDR	r3, =0x9999
delayloop
	SUBS	r3, #1
	BNE	delayloop
	BX LR
	
	ENDP
	
	ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN
; Replace ECE1770 with your last name
str DCB "ECE1770",0
	END