;****************************************************************
;* 
;* Robot w/ feelings Mealy FSM
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

OUT EQU 0 ; Index for output
NEXT EQU 1 ; Index for next
NONE EQU 0 ; No pulse
SIT_DOWN EQU $08 ; Pulse on PB3
STAND_UP EQU $04 ; Pulse on PB2
LIE_DOWN EQU $02 ; Pulse on PB1
SIT_UP EQU $01 ; Pulse on PB0      

;---------------------------------------------------- 
; Variable/Data Section
; KEEP THIS!!		
;----------------------------------------------------  
          ORG     DATA
      ;00  ,01      ,10     ,11
STAND:;ok  ,tired   ,curious, anxious
  FCB NONE ,SIT_DOWN,NONE   ,NONE     ;current "emotion"
  FDB STAND,SIT     ,STAND  ,STAND    ;next state
SIT:
  FCB NONE ,LIE_DOWN,NONE   ,STAND_UP ;current "emotion"
  FDB SIT  ,SLEEP   ,SIT    ,STAND    ;next state
SLEEP:
  FCB NONE ,NONE    ,SIT_UP ,SIT_UP   ;current "emotion"
  FDB SLEEP,SLEEP   ,SIT    ,SIT      ;next state   
  
START rmb 2
DELAY fdb 1876 ; 10ms for 187.5khz 
TIME  fdb 1
;---------------------------------------------------- 
; Code Section
; KEEP THIS!!		
;---------------------------------------------------- 
          ORG     PROG

; Insert your code following the label "Entry"          
Entry:                          ; KEEP THIS LABEL!!
  lds #PROG ;stack init
  bsr LED_PB_INIT;init the leds and pbs
  bsr Timer_INIT ;init timer
  ;movb #$FF,DDRB ;PB3-0 are lights
  ;movb #$00,DDRA ;PA1-0 are sensors
  ldx #STAND ;State index
  movb #$04,PORTB
  
FSM: ;read sensors
  ldab PTH 
  comb     ;buttons are negative logic
  andb #$03;just bits 1-0
  ldy #TIME  ;load the time delay into y
  ;bsr T_Wait ;introduce delay for user
  
  ;determine what output
  
  abx        ;base+ionput
  ldaa OUT,X ;fetch output
  
  ;switch
  cmpa #SIT_UP   ;case 1 change to sit from sleep
  bne Case2
  ;data here  
  ldaa #$02;sitting
  bra EndSwitch
Case2:
  cmpa #LIE_DOWN ;case 2 chage to sleep from sit 
  bne Case4  
  ;data here       
  ldaa #$01;sleeping
  bra EndSwitch
Case4:
  cmpa #STAND_UP ;case 4 change to stand from sit
  bne Case8 
  ;data here    
  ldaa #$04;standing
  bra EndSwitch
Case8:
  cmpa #SIT_DOWN ;case 8 change to sit from stand
  bne CaseDefault  
  ;data here       
  ldaa #$02;sitting
  bra EndSwitch
CaseDefault:
  bra DontUpdate
  ;data here
EndSwitch:  ;end case
  staa PORTB ;update output
DontUpdate:  

  pshb
  ;determine next state
  comb ;current spot+= complement of inputs
  andb #$03;just bits 1-0
  abx  ;will set base to the begining of "next state options"  
  ;comb ;will set b to what it was previous  
  ;andb #$03;just bits 1-0
  pulb
  
  lslb ;next add=2*input
  abx  ;next base+=next add
  
  ;move to next state
  ldx NEXT,X
  
  bra FSM ;loop always        
  
  ; Branch to end of program
  BRA     FINISH

;---------------------------------------------------- 
; INIT       
;----------------------------------------------------
LED_PB_INIT:
  bset DDRB,#$ff    ;set port b(0) to output
  bset DDRP,#$0f    ;enable 7 segs
  
  bclr DDRH,#$03    ;set port H pins 0-1 to input

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
