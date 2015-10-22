;****************************************************************
;* 
;* Lab 5 Part 2: Freq Meas using PA
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
; Vars for delay subroutine
START     RMB     2          
DELAYC    FDB     1875

; TO DO: Add any vars here



;---------------------------------------------------- 
; Code Section
; KEEP THIS!!		
;---------------------------------------------------- 
          ORG     PROG

; Insert your code following the label "Entry"          
Entry:                          ; KEEP THIS LABEL!!

		  LDS     #PROG         ; Init stack
      BSR INIT
      BSR PWM_INIT    
		  ; TO DO: Add any inits here
		  
          
MAIN: 
  ldd #$00       
  bsr Freq
  cpd #$00
  bne DONE
  ; Main loop - DO NOT REMOVE THIS LOOP
  BRA     MAIN
          
		  ; Branch to the following NOP when the freq is calculated
          ; Place BP on NOP to see freq of signal
DONE:     
          NOP  ;is addr 2013
          BRA     DONE
		  
;---------------------------------------------------- 
; TO DO: PA Subroutine
;---------------------------------------------------- 

Freq:
  bclr DDRT, #$80       ;pt7 is input
  movb #$40,PACTL       ;count the falling edges
  movw #0, PACN32       ;clear 16bit counter
  movb #$00,PAFLG       ;clear PAOVF
  bsr DELAY_10ms             ;delay time to measure cycles
  brclr PAFLG,#$02,OK   ;check PAOVF
BAD:                    
  LDD #65535            ;PAOVF = 1 means overflow
  bra OUT
OK:
  LDD PACN32            ;units in Hz (hex)
OUT:
  RTS

; ---------------------------------------------------- 
; Init Subroutine
; ---------------------------------------------------- 
INIT:
          ; Timer Init
          MOVB    #$80,TSCR1        ; Enable counter
          MOVB    #$07,TSCR2        ; Counter increments every 5.33 us
          RTS    
          
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

; ---------------------------------------------------- 
; Delay 10ms Subroutine
; ----------------------------------------------------            
DELAY_10ms:
          MOVW    0,TCNT
          MOVW    TCNT,START          
         
WLOOP:    LDD     TCNT
          SUBD    START
          CPD     DELAYC
          BLO     WLOOP
          RTS
