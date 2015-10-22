;****************************************************************
;* 
;* Lab 4
;*
;****************************************************************

;---------------------------------------------------- 
; Export Symbols
; KEEP THIS!!
;---------------------------------------------------- 
          XDEF      Entry       ; export 'Entry' symbol
          ABSENTRY  Entry       ; for absolute assembly: mark this as application entry point

;---------------------------------------------------- 
; Derivative-Specific Definitions
; KEEP THIS!!
;----------------------------------------------------
          INCLUDE   'derivative.inc' 

;---------------------------------------------------- 
; Constants Section
; KEEP THIS!!,,
;---------------------------------------------------- 
ROM       EQU     $0400
DATA      EQU     $1000
PROG      EQU     $2000

;---------------------------------------------------- 
; Variable/Data Section
; KEEP THIS!!
;----------------------------------------------------  
          ORG     DATA    
Period    RMB     2 ;units, i have no idea (1/24Mhz)?
First     RMB     2 ;tcnt for subtraction 
interv    fcb     $03  
;---------------------------------------------------- 
; Code Section
; KEEP THIS!!
;---------------------------------------------------- 
          ORG     PROG

; Insert your code following the label "Entry"          
Entry:                          ; KEEP THIS LABEL!!
  ;ldy #$0003 ;to have the interupt happen Y times.
          LDS     #PROG         ; Init stack
          BSR     PWM_INIT      ; Init PWM
          BSR     IC_INIT       ; Input Capture Init
          
MAIN:        
          ; Main loop - DO NOT REMOVE THIS LOOP
  ldaa interv ;compair a to 0
  cmpa #$00 
  beq DONE   ;branch if a is less than 0 
          BRA     MAIN
          
		  ; Branch to the following NOP when the period is calculated
          ; Place BP on NOP to see period of signal
DONE:     
          NOP
          BRA     DONE   

;---------------------------------------------------- 
; TO DO: IC Init Subroutine      
;----------------------------------------------------       
IC_INIT:
  SEI;ATOMIC
  ;set up ports
  bclr TIOS,#$02  ;PT1 is input capture
  bclr DDRT,#$02  ;PT1 is input
  movb #$80, TSCR1 ;enable TCNT
  bclr TCTL4,#$08 ;EDG1BA=01
  bset TCTL4,#$04 ;on rise of IC1
  ;divide the clock
  bclr TSCR2,#$07 ;24M/(2^0)=24M
  ;enable the interupt
  bset TIE,#$02   ;Arm the flag for pt1
  movb #$02,TFLG1 ;clear the flag for pt1
  CLI;end ATOMIC
  rts;return     
       
;---------------------------------------------------- 
; TO DO: IC ISR
;---------------------------------------------------- 
IC_ISR: ;[20]
  ;ACK
  MOVB #$02,TFLG1 ;ack c1f          [4]
  ;Do things      
  ldd TC1         ;load cnt         [3]
  subd First      ;sub previous cnt [3]
  std Period      ;store new period [3]
  movw TC1,First  ;store new cnt    [6]
  dec interv;interv=interv-1 to have an endcase [1]
 
  RTI;return        

;---------------------------------------------------- 
; TO DO: PWM Init Subroutine
;---------------------------------------------------- 
PWM_INIT:
  SEI ;ATOMIC
  ;set up ports
  bset MODRR, #$20    ;SET THE 5TH PTP 5 W/ PWM
  bset DDRP, #$20     ;set PTP5 to output
  bset PWMPOL, #$20   ;set high then low
  bclr PWMCLK, #$20   ;set use clock A
  bset PWMCTL, #$40   ;set concat 4 and 5
  ;divide the clock
  bset PWMPRCLK, #$07 ;24M/(2^7)=24M/128=187.5K 
  ;movw #$0001,PWMSCLB   ;187.5K/(2*1)=187.5K
  ;set the duty cycle
  movw #$0112,PWMPER45 ;the period ((684hz)^-1)*187.5khz)= 274.12
  movw #$0089,PWMDTY45 ;the duty (50%) 274/2 = 137
  ;enable the PMW
  bset PWME, #$20 ;enable the 5th channel
  
	CLI                 ;done with ATOMIC	  
	RTS	                ;return  
          
;---------------------------------------------------- 
; TO DO: PWM Subroutine
;---------------------------------------------------- 
PWM:      
  std PWMDTY45  ;regD is new duty cycle
  ;must be less than $0112        
  rts
   
;---------------------------------------------------- 
; TO DO: Interrupt Vector Table
;---------------------------------------------------- 		
  ;ffec,ffed - c180 =  3e6c
  ORG $3e6c
  fdb IC_ISR
