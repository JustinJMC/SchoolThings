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
O   fcb $5c;#$5c
N   fcb $54;#$54
F   fcb $71;#$71
flag fcb $01 ; 1 is locked (on), 0 is unlocked (off)

;---------------------------------------------------- 
; Code Section
; KEEP THIS!!		
;---------------------------------------------------- 
          ORG     PROG

; Insert your code following the label "Entry"          
Entry:                          ; KEEP THIS LABEL!!
  LDS #PROG  
  
  bsr INIT
  
;Main loop  
top:      
  bsr IN_OUT
  cmpa #$03
  beq unlock
return1:
  cmpa #$0c
  beq lock
return2:
  bsr display
  bra top

;Subroutines
display:
  tst flag  ;locked (on) = 1, unlocked (off) = 0
  beq display_off

;display_on:;locked (2ms delay)
  ldaa O
  ldab #$0b ; digit 1
  staa PORTB ;tell which value to display
  stab PTP   ;tell which digit
  bsr delay ;1ms
  ldaa N
  ldab #$07  ;digit 0
  staa PORTB
  stab PTP
  bsr delay ;1ms
  rts

display_off:;unlocked (2ms delay)
  ldaa O
  ldab #$0d ;digit 2
  staa PORTB
  stab PTP
  bsr delay ;1ms
  ldaa F
  ldab #$03 ;digit 1 and 0
  staa PORTB
  stab PTP
  bsr delay ;1ms
  rts
  
lock:
  ldab #$01 ;1 indicates locked
  stab flag
  bra return2
  
unlock:
  ldab #$00 ;0 indicates led off
  stab flag
  bra return1
  
delay:
  ldy #6000    ;6k*4=24k
loop_1ms:
  dey          ;1cycle
  bne loop_1ms ;3cycles
  rts  
  
IN_OUT:  ; is what a hamburger is all about
  ldaa PTH
  coma
  rts
  
;Initialization      
INIT:
  ;LED init
  bset DDRB,#$ff    ;set port b(0) to output
  bset DDRP,#$0f    ;enable 7 segs
  
  bclr DDRH,#$0f    ;set port H pins 0-3 to input

  rts      
         
FINISH:
