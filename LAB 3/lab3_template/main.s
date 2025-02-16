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


      INCLUDE core_cm4_constants.s        ; Load Constant Definitions
      INCLUDE stm32l476xx_constants.s      

      IMPORT      System_Clock_Init
      IMPORT      UART2_Init
      IMPORT      USART2_Write
      
      AREA    main, CODE, READONLY
      EXPORT      __main                        ; make __main visible to linker
      ENTRY             
                        
__main      PROC
      
;;;;;;; INITIALIZATION ;;;;;;;;;;

		;ENABLES CLOCKS C AND B
_Cnfig LDR r0,=RCC_BASE; The base address of the reset and clock control
       LDR r1,[r0,#RCC_AHB2ENR];  stores base address of clock control to Reg 1
         ORR r1,#0x00000006; This is masking to enable clock B(out) and C(in)
         STR r1,[r0,#RCC_AHB2ENR]; storeing clock control to Reg 1
        
         ;GPIO C Config (input button)
         LDR r5,=GPIOC_BASE; The base address for GPIOC controls
         LDR r2,[r5,#GPIO_MODER];offseting to the MODER controls
         AND r2,#0xF3FFFFFF; seting pins 27 and 26 to zero (input mode for button)
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


        
__CONT
        
;;;;;;; LOGIC ;;;;;;;;;;
            MOV r4, #0;sets reg4 to 0
			
			
			
		;FIRST PART OF THE LOOP
loop    ;MAP THE CURRENT SAVED COUNT TO THE PINS
            MOV r6,#12; setting back to ...0001100
            MOV r7, #3; setting bacck to ...0000011
            AND r6, r4; setting r6 to the 2 MSB of our count
            AND r7, r4; setting r7 to our 2 LSB of our count
            MOV r10, #0; clearing r10
            ORR r10, r6, LSL #4; setting pin 6 and 7 to the values of the 2 MSB of our count which is currently contained in r6 in bits 2 and 3
            ORR r10, r7, LSL #2; setting pin 2 and 3 to the values of the 2 LSB of out count which is currently contained in r7 in bits 0 and 1
            STR r10,[r0,#GPIO_ODR]; setting the value of the pins
            
            
            
            B wait;SENDS TO WAIT FUNCTION
            
			
		;SECOND PART OF THE LOOP
		;CHECKS IF BUTTON IS PRESSED OR NUMBER IS 9 OTHERWISE ITERATES AS USUAL
waitnd      LDR r8, [r5, #GPIO_IDR]; setting r8 to be the value of IDR in GPIOC which contains the button
            AND r8, #0x2000;#1, LSL #13; anding with the the 13th bit which if button is not pressed  will contain a 1
            CMP r8, #0; checks this bit to see if button is pressed and register 8 is not equal to 0 if button is being pressed
            MOVEQ r4, #0; if button is pressed reg4 = 0 resets count
            BEQ loop; goes back to the top after button is pressed
            CMP r4, #9
            BLT elsif
            BAL loop    ; go back to the top

		;THIS IS THE R4++ FUNCTION
elsif   ADD r4, #1; incriments by one
            BAL loop    ; go back to the top
            
		;THIS IS THE WAIT FUNCTION
wait  MOV r9, #0x000F0000; creating a big number
wait1        SUB r9, #1; subtracting 1
            CMP r9, #0; compare to zero
            BNE wait1; goes back to the top of function if not one
            B waitnd; go back to where it was
      
      
stop  B           stop              ; dead loop & program hangs here

      ENDP
                                                

      AREA myData, DATA, READWRITE
      ALIGN

      END
