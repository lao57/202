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



;;;;;;;;;;;; YOUR CODE GOES HERE	;;;;;;;;;;;;;;;;;;; GPIOC does rows with pins C0123, GPIOB does columns with pins B123


;;;;;;;;;;;;;__INIT__GPIO-C-B-CLOCK__;;;;;;;;;;;;;;;
      LDR   r0, =RCC_BASE ; Configuring the reset and clock of the microcontroller
      LDR   r1, [r0, #RCC_AHB2ENR] ; loading clock into r0
      ORR   r1, r1, #0x00000006 ; Activating clocks B and C
      ;BIC   r1, r1, #0x00000001 ; Setting the desired GPIOs (GPIOB and GPIOC) DNN
      STR   r1, [r0, #RCC_AHB2ENR] ; Storing the value back to clock reg from changed value in r1 0110
      

      LDR   r0, =GPIOB_BASE ; Configuring MODER of GPIOB for INPUTS
      LDR   r1, [r0, #GPIO_MODER] ; Loading MODER of GPIOB onto r1
      BIC   r1, #0x000000FC  ; clearing pins 321 to 00 (dig input)
      STR   r1, [r0, #GPIO_MODER] ; storing change back to MODER B
      

      LDR   r0, =GPIOC_BASE ; Configuring MODER OF GPIOC for OUTPUTS
      LDR   r1, [r0, #GPIO_MODER] ; Loading MODER C onto r1
      BIC   r1, r1, #0x000000FF ; clearing pins 0123
      ORR   r1, r1, #0x00000055 ; setting pins 0123 to Digital output
      STR   r1, [r0, #GPIO_MODER] ; storing change back to MODER C

;;;;;;;;;;;;;set_default_reg;;;;;;;;;;;;;;;
;setting columns to 1111 and rows to 0000

;Setting GPIOC to pull down
NPTOL
	  MOV	R4, #0; THIS VALUE HOLDS THE ROW 1-4 STARTS AT 0
	  LDR	r0, =GPIOC_BASE
	  LDR	r1, [r0, #GPIO_ODR]; loading in GPIOC ODR into r1
	  BIC	r1, #0x0000000F; clearing pins C0123 for pull down
	  STR	r1, [r0, #GPIO_ODR];sending back to GPIOC ODR
	  
	  BL delay; delaying
	  
	  LDR	r0, =GPIOB_BASE
	  LDR	r1, [r0, #GPIO_IDR]
	  CMP	r1, #0x0000001E; checks if pins 123 are pressed ie != 1
	  BEQ	NPTOL
	  
	  BL delay;
	  
;Some key was pressed
button_find

	  ;CHECKING ROW 1 TO SEE IF BUTTON WAS PRESSED THERE
      LDR r0, =GPIOC_BASE ; Configuring the ODR resgister in GPIOC for OUTPUTS
      LDR r1, [r0, #GPIO_ODR] ; loading in GPIOC ODR into r1
      BIC r1, #0x0000000F ; Masking the registers that we are interested in
      ORR r1, #0x0000000E ; Setting the first bit to 0 to pull first row low
      STR r1, [r0, #GPIO_ODR] ; sending back to GPIOC ODR
      
      BL delay  ; Branching to delay function as per the flowchart
      

      LDR r0, =GPIOB_BASE ; loading IDR resgister in GPIOB for INPUTS
      LDR r2, [r0, #GPIO_IDR]  ; Loading the current value of IDR into r2
      CMP r2, #0x0000001E ; Comparing the value if nothing is pressed
	  MOVNE R4, #0x00000001; SETTING ROW TO ONE
      BNE key_press ; If not equal, then a key is pressed IN ROW 1 otherwise pull down row 2
	  
	  ;CHECKING ROW 2 TO SEE IF BUTTON WAS PRESSED THERE
      LDR r0, =GPIOC_BASE ; Configuring the ODR resgister in GPIOC for OUTPUTS
      LDR r1, [r0, #GPIO_ODR] ; loading in GPIOC ODR into r1
      BIC r1, #0x0000000F ; Masking the registers that we are interested in
      ORR r1, #0x0000000D ; Setting the SECOND bit to 0 to pull SECOND row low
      STR r1, [r0, #GPIO_ODR] ; sending back to GPIOC ODR
	  
	  BL delay;
	  
	  LDR r0, =GPIOB_BASE ; loading IDR resgister in GPIOB for INPUTS
      LDR r2, [r0, #GPIO_IDR]  ; Loading the current value of IDR into r2
      CMP r2, #0x0000001E ; Comparing the value if nothing is pressed
	  MOVNE R4, #0x00000002; SETTING ROW TO two
      BNE key_press ; If not equal, then a key is pressed IN ROW 2 otherwise pull down row 3
	  
	  ;CHECKING ROW 3 TO SEE IF BUTTON WAS PRESSED THERE
      LDR r0, =GPIOC_BASE ; Configuring the ODR resgister in GPIOC for OUTPUTS
      LDR r1, [r0, #GPIO_ODR] ; loading in GPIOC ODR into r1
      BIC r1, #0x0000000F ; Masking the registers that we are interested in
      ORR r1, #0x0000000B ; Setting the third bit to 0 to pull third row low
      STR r1, [r0, #GPIO_ODR] ; sending back to GPIOC ODR
	  
	  BL delay;
	  
	  LDR r0, =GPIOB_BASE ; loading IDR resgister in GPIOB for INPUTS
      LDR r2, [r0, #GPIO_IDR]  ; Loading the current value of IDR into r2
      CMP r2, #0x0000001E ; Comparing the value if nothing is pressed
	  MOVNE R4, #0x00000003; SETTING ROW TO three
      BNE key_press ; If not equal, then a key is pressed IN ROW 3 otherwise pull down row 4
	  
	  ;CHECKING ROW 4 TO SEE IF BUTTON WAS PRESSED THERE
      LDR r0, =GPIOC_BASE ; Configuring the ODR resgister in GPIOC for OUTPUTS
      LDR r1, [r0, #GPIO_ODR] ; loading in GPIOC ODR into r1
      BIC r1, #0x0000000F ; Masking the registers that we are interested in
      ORR r1, #0x00000007 ; Setting the forth bit to 0 to pull forth row low
      STR r1, [r0, #GPIO_ODR] ; sending back to GPIOC ODR
	  
	  BL delay;
	  
	  LDR r0, =GPIOB_BASE ; loading IDR resgister in GPIOB for INPUTS
      LDR r2, [r0, #GPIO_IDR]  ; Loading the current value of IDR into r2
      CMP r2, #0x0000001E ; Comparing the value if nothing is pressed
	  MOVNE R4, #0x00000004; SETTING ROW TO four
      BNE key_press ; If not equal, then a key is pressed IN ROW 4 otherwise go back to the start
	  
	  B NPTOL
	  

	  
	  
;function for if a key was pressed
key_press; R1 = GPIOC OUTPUT PINS 0123, R2 = GPIOB INPUT PINS 123
	  
	  LDR	r0, =GPIOC_BASE
	  LDR	r1, [r0, #GPIO_ODR]; loading in GPIOC ODR into r1
	  BIC	r1, #0x0000000F; clearing pins C0123 for pull down
	  STR	r1, [r0, #GPIO_ODR];sending back to GPIOC ODR
	  
	  BL delay;
	  
	  LDR r0, =GPIOB_BASE ; loading IDR resgister in GPIOB for INPUTS
      LDR r2, [r0, #GPIO_IDR]  ; Loading the current value of IDR into r2
	  
	  MOV r5, #0;COLUMN HOLDER
	  CMP r2, #0x00000016; nothing pressed 0110 MEANING COLUMN 3
	  MOVEQ R5, #0x00000030;
	  CMP R2, #0x0000001A; 1010 column 2
	  MOVEQ r5, #0x00000020
	  CMP R2, #0x0000001C; just check if not in column 2 or 3
	  MOVEQ r5, #0x00000010; this means column one
	  
	  BL wait_until_not_pressed
waited  
	  ORR r5, r4;
	  
	  ;COMPARES AND LOADS REGISTERS COLUMN ROW
	  CMP r5, #0x00000011;CR
	  BEQ L1
	  CMP r5, #0x00000012;C = 1, R = 2...
	  BEQ L4
	  CMP r5, #0x00000013
	  BEQ L7
	  CMP r5, #0x00000014
	  BEQ La
	  CMP r5, #0x00000021
	  BEQ L2
	  CMP r5, #0x00000022
	  BEQ L5
	  CMP r5, #0x00000023
	  BEQ L8
	  CMP r5, #0x00000024
	  BEQ L0
	  CMP r5, #0x00000031
	  BEQ L3
	  CMP r5, #0x00000032
	  BEQ L6
	  CMP r5, #0x00000033
	  BEQ L9
	  CMP r5, #0x00000034
	  BEQ Lp
	  
compared                         
      BL displaykey
	  BAL NPTOL

	  
;FUNCTIONS FOR LOADING VALUES
;loads value from mem to r7
;assigns ascii value to r6 
;not sure which methoud is needed
L0	LDR r7, =zero
	MOV r6, #048
	BAL compared
L1	LDR r7, =one
	MOV r6, #049
	BAL compared
L2 	LDR r7, =two
	MOV r6, #050
	BAL compared
L3	LDR r7, =three
	MOV r6, #051
	BAL compared
L4	LDR r7, =four
	MOV r6, #052
	BAL compared
L5	LDR r7, =five
	MOV r6, #053
	BAL compared
L6	LDR r7, =six
	MOV r6, #054
	BAL compared
L7	LDR r7, =seven
	MOV r6, #055
	BAL compared
L8	LDR r7, =eight
	MOV r6, #056
	BAL compared
L9	LDR r7, =nine
	MOV r6, #057
	BAL compared
La	LDR r7, =astersik
	MOV r6, #042
	BAL compared
Lp	LDR r7, =Pound
	MOV r6, #035
	BAL compared

	  
	  
	  
wait_until_not_pressed;loop according to diagram
	  LDR	r0, =GPIOC_BASE
	  LDR	r1, [r0, #GPIO_ODR]; loading in GPIOC ODR into r1
	  BIC	r1, #0x0000000F; clearing pins C0123 for pull down
	  STR	r1, [r0, #GPIO_ODR];sending back to GPIOC ODR
	  
	  BL delay; delaying
	  
	  LDR	r0, =GPIOB_BASE
	  LDR	r1, [r0, #GPIO_IDR]
	  CMP	r1, #0x0000001E; checks if pins 123 are pressed ie != 1
	  BNE	wait_until_not_pressed
	  BAL	waited

	
displaykey
	;STR	r6, [r8]
	;MOV	r0, r7
	;LDR r0, =str   ; First argument
	;MOV r1, #1    ; Second argument
	
	STR r6, [r8]  ; Goes onto given display function if the button is not pressed
    MOV r0, r7
    MOV r1, #1   ; Second arugment
	BL USART2_Write
 	BAL NPTOL
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

; Creating memory space for the corresponding ASCII values of 0-9, A-D, *, and #. 
non DCD 48
zero DCD 49
one DCD 50
two DCD 51
three DCD 52
four DCD 53
five DCD 54
six DCD 55
seven DCD 56
eight DCD 57
nine DCD 42
astersik DCD 35
Pound DCD 35
	END