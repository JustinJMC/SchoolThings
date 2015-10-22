;****************************************************************
;* 
;* Lab 5 Part 1: Freq Meas using OC/IC
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
; KEEP THIS!!		
;---------------------------------------------------- 
ROM       EQU     $0400
DATA      EQU     $1000
PROG      EQU     $2000

;---------------------------------------------------- 
; Variable/Data Section
; KEEP THIS!!		
;----------------------------------------------------  
          ORG     DATA	
Freq  rmb 1
Count rmb 1
Done  rmb	1  
RATE  fdb $5dc0 ;24000 ;1ms on 24Mhz clock		  

;---------------------------------------------------- 
; Code Section
; KEEP THIS!!		
;---------------------------------------------------- 
          ORG     PROG         
Entry:                          ; KEEP THIS LABEL!!
  ;init section
	lds #PROG ; Init stack
	bsr PWM_INIT
	bsr IC_OC_INIT
	;bsr IC_INIT ;also calls OC_INIT
	;end init section	  
MAIN:        
  tst Done
  bne Finished  
  BRA MAIN
		  
Finished:     
  NOP ;is addr 200e
  BRA Finished
		  
;---------------------------------------------------- 
;Init Subroutines
;---------------------------------------------------- 
PWM_INIT:  ;called from INIT SECTION
  SEI ;ATOMIC
  ;set up ports
  bset MODRR, #$20    ;SET THE 5TH PTP 5 W/ PWM
  bset DDRP, #$20     ;set PTP5 to output
  ;configure clock
  bset PWMPOL, #$20   ;set high then low
  bclr PWMCLK, #$20   ;set use clock A
  bset PWMCTL, #$40   ;set concat 4 and 5
  ;divide the clock
  bclr PWMPRCLK, #$06 
  bset PWMPRCLK, #$01 ;24M/(2^1)=24M/2=12M 
  ;set the duty cycle
  movw #$0177,PWMPER45 ;the period ((32khz)^-1)*12Mhz)= 375
  movw #$00bb,PWMDTY45 ;the duty (50%) 375/2 = 187.5 = 187
  ;enable the PMW
  bset PWME, #$20     ;enable the 5th channel
	CLI                 ;done with ATOMIC	  
	RTS	
	
IC_OC_INIT:
  SEI                   ; Disable maskable
  ;set ports
  BSET    TIOS,#$20     ; Enable OC5        
  BCLR    TIOS,#$02     ; Enable IC1
  ;enable
  MOVB    #$80,TSCR1    ; Enable Timer      
  ;divide clock
  MOVB    #$00,TSCR2    ; 24 MHz clk        
  ;arm
  BSET    TIE,#$22      ; Arm OC5 and IC1   
  ;set time interval
  LDD     RATE
  ADDD    TCNT
  STD     TC5
  ;configure clock 
  BCLR    TCTL4,#$08    ; EDG1B/A = 01           
  BSET    TCTL4,#$04    ; On Rise of PT1/IC1
  ;initialize variables
  CLR     Count                             
  CLR     Done
  ;enable interupts
  MOVB    #$22,TFLG1    ; Clear C5F, C1F    
  CLI
  RTS
  
;---------------------------------------------------- 
;ISRs
;---------------------------------------------------- 
IC1_ISR: ;[8]
  movb #$02,TFLG1  ;ack C1F [4]
  inc Count       ;inc EXT [4]
  rti

OC5_ISR: ;[24]
  movb #$20,TFLG1  ;ack C5F [4]
  ;every 1ms
  ldd  RATE       ;wait 1ms[3]
  addd TC5        ;        [3]
  std  TC5        ;        [3]
  ;figuring the period
  movb Count,Freq ;        [4]
  movb #$FF,Done  ;        [4]
  clr  Count      ;        [3]
  rti       
  
;---------------------------------------------------- 
;Interrupt Vectors     
;----------------------------------------------------          
  ;$ffec-c180 = $3e6c
  org $3e6c 
  fdb IC1_ISR
  
  ;$ffe4-c180 = $3e64
  org $3e64
  fdb OC5_ISR
