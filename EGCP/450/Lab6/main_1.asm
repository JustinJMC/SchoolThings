;****************************************************************
;* 
;* Traffic Controller Moore FSM
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

OUT   equ 0 ;offset for output
WAIT  equ 1 ;offset for time
NEXT  equ 3 ;offset for next state            
;---------------------------------------------------- 
; Variable/Data Section
; KEEP THIS!!		
;----------------------------------------------------  
          ORG     DATA
goN:
  fcb $21 ;North green, East red
  fdb 300 ;3sec ;fast for testing increase time for production
  fdb goN,waitN,goN,waitN
waitN: 
  fcb $22 ;North yellow, East red
  fdb 100 ;1sec ;fast for testing increase time for production
  fdb goE,goE,goE,goE
goE: 
  fcb $0C ;North red, East green
  fdb 300 ;3 sec ;fast for testing increase time for production
  fdb goE,goE,waitE,waitE
waitE: 
  fcb $14 ;North red, East yellow
  fdb 100 ;1sec ;fast for testing increase time for production
  fdb goN,goN,goN,goN        
  
START rmb 2
DELAY fdb 1876 ; 10ms for 187.5khz 
;---------------------------------------------------- 
; Code Section
; KEEP THIS!!		
;---------------------------------------------------- 
          ORG     PROG

; Insert your code following the label "Entry"          
Entry:                          ; KEEP THIS LABEL!!
  lds #PROG ;stack init
  bsr Timer_INIT ;enable TCNT
  bsr LED_PB_INIT;init the leds and pbs
  ;movb #$FF,DDRB ;PB5-0 are lights
  ;movb #$00,DDRA ;PA1-0 are sensors
  ldx #goN ;State index
FSM: 
  ldab OUT,x ;load output from state
  stab PORTB ;output from state
  ldy WAIT,x ;time delay
  bsr T_Wait
  ldab PTH ;read inputs
  comb       ;inputs are negative logic
  ANDB #$03  ;only bits 1,0
  lslb       ;shift bits left to * by 2
  abx        ;add 0,2,4, or 6 depending
  ldx NEXT,X ;go to the next state pointer addr
  bra FSM         
  
  ; Branch to end of program
  BRA     FINISH

;---------------------------------------------------- 
; INIT       
;----------------------------------------------------
LED_PB_INIT:
  bset DDRB,#$ff    ;set port b(0) to output
  bset DDRP,#$0f    ;enable 7 segs
  
  bclr DDRH,#$02    ;set port H pins 0-1 to input

  rts
     
Timer_INIT:
  movb #$80,TSCR1 ;enable tcnt
  movb #$07,TSCR2 ;divide the clock 24M/128=187.5K
  rts 
  
;---------------------------------------------------- 
; Subroutines    
;----------------------------------------------------
  
T_Wait: ;wait for y*10ms
  bsr T_Wait_10ms
  dey
  cpy #0
  bne T_Wait
  rts
  
T_Wait_10ms:
  movw TCNT,START;figure out tcnt
WLoop:
  ldd TCNT     ;now
  subd START   ;so far = tcnt-start
  CPD DELAY
  BLO WLoop    ;loop if sofar<delay
  rts
;---------------------------------------------------- 
; End program
; KEEP THIS!!	       
;----------------------------------------------------           
FINISH:
          END
