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
	
	BL System_Clock_Init
	BL UART2_Init



;;;;;;;;;;;; YOUR CODE GOES HERE	;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;__INIT__GPIO-C-B-CLOCK__;;;;;;;;;;;;;;;
      LDR   r0, =RCC_BASE ; Configuring the reset and clock of the microcontroller
      LDR   r1, [r0, #RCC_AHB2ENR] ; loading clock into r0
      ORR   r1, r1, #0x00000006 ; Activating clocks B and C
      ;BIC   r1, r1, #0x00000001 ; Setting the desired GPIOs (GPIOB and GPIOC) DNN
      STR   r1, [r0, #RCC_AHB2ENR] ; Storing the value back to clock reg from changed value in r1 0110
      

      LDR   r0, =GPIOB_BASE ; Configuring MODER of GPIOB for INPUTS
      LDR   r1, [r0, #GPIO_MODER] ; Loading MODER of GPIOB onto r1
      MOV   r2, #0x00000CFC ; putting mask into r2 since BIC can't take directly
      BIC   r1, r2  ; clearing pins 5321 to 00 (dig input)
      STR   r1, [r0, #GPIO_MODER] ; storing change back to MODER B
      

      LDR   r0, =GPIOC_BASE ; Configuring MODER OF GPIOC for OUTPUTS
      LDR   r1, [r0, #GPIO_MODER] ; Loading MODER C onto r1
      BIC   r1, r1, #0x000000FF ; clearing pins 0123
      ORR   r1, r1, #0x00000055 ; setting pins 0123 to Digital output
      STR   r1, [r0, #GPIO_MODER] ; storing change back to MODER C

;;;;;;;;;;;;;set_default_reg;;;;;;;;;;;;;;;
;setting columns to 1111 and rows to 0000

;Setting GPIOC to pull down
nothing_pressed_top_of_logic
	  LDR	r0, =GPIOC_BASE
	  LDR	r1, [r0, #GPIO_ODR]; loading in GPIOC ODR into r1
	  BIC	r1, 0x0000000F; clearing pins C0123 for pull down
	  STR	r1, [r0, #GPIO_ODR];sending back to GPIOC ODR
	  
	  BL delay; delaying
	  
	  LDR	r0, =GPIOB_BASE
	  LDR	r1, [r0, #GPIO_IDR]
	  CMP	r1, 0x0000002E; checks if pins 1235 are pressed ie != 1
	  BEQ	nothing_pressed_top_of_logic
	  
	  BL delay;
	  
	  
	  
	

	
displaykey
	STR	r5, [r8]
	LDR	r0, =char1
	;LDR r0, =str   ; First argument
	MOV r1, #1    ; Second argument
	BL USART2_Write
 	
	ENDP		

			
		

delay	PROC
	; Delay for software debouncing
	LDR	r2, =0x9999
delayloop
	SUBS	r2, #1
	BNE	delayloop
	BX LR
	
	ENDP
		
		
		
		
					
	ALIGN			

	AREA myData, DATA, READWRITE
	ALIGN

char1	DCD	43
	END