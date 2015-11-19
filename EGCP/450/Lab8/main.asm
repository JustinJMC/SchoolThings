;****************************************************************
;*
;* Lab 8 ADC potentiometer, photodiode reader.
;*
;* Given code is in caps, code entered by myself (justin) is in lower.
;*
;* This code causes a timer overflow every 175ms, and checks the ADC value 
;* and displays it to the LCD.
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

RS        EQU     $01           ; Register Select pin for LCD module  
EN        EQU     $02           ; Enable pin for LCD module
RW        EQU     $80           ; Read/Write for LCD module

;---------------------------------------------------- 
; Insert constants here	
;----------------------------------------------------
;---------------------------------------------------- 
; Variable/Data Section
; KEEP THIS!!		
;----------------------------------------------------  
          ORG     DATA

Time rmb 2

          ; Vars for ADC
ADC_IN     FDB     0             ; ADC conversion (16-bit)
ADC_IN_VI  FCB     0             ; ADC conversion in volts, integer part (8-bit)
ADC_IN_VF  FCB     0             ; ADC conversion in volts, fractional part (8-bit)
ASCII_OUT  FCB     0,0,0         ; ADC conversion in ASCII
          
;---------------------------------------------------- 
; Code Section
; KEEP THIS!!		
;---------------------------------------------------- 
          ORG     PROG

; Insert your code following the label "Entry"          
Entry:                          ; KEEP THIS LABEL!!
          
          LDS     #PROG         ; Init. Stack
          BSR     ADC_INIT      ; ADC Init
          BSR     TOF_INIT      ; TOF Init
          BSR     LCD_INIT      ; LCD Init
         
          ; Main Loop 
INF_LOOP:
          BRA     INF_LOOP
          
;---------------------------------------------------- 
; ADC Init Module 
; 
; To Do:
;   1. Create an ADC init module named ADC_INIT
;   2. Indicate all phases.  
;----------------------------------------------------
;********* Binding       *********; 
;********* Allocation    *********;   
ADC_INIT: 
  sei
;********* Access        *********; 
  movb #$80, ATD0CTL2 ;power up ADC
  movb #$08, ATD0CTL3 ;1 sample
  movb #$EB, ATD0CTL4 ;8bit reso., 16clock ticks for 2nd phase.
                      ;prescaler of 24 for conversion freq. = 1MHz
;Potentiometer is connected to channel 7  
  ;movb #$A7, ATD0CTL5 ;right justified, continious conversions, ADC0 channel 7    
;Photodiode is connected to channel 4                
  movb #$A4, ATD0CTL5 ;right justified, continious conversions, ADC0 channel 4
;********* Deallocation  *********;  
  cli
  rts

;---------------------------------------------------- 
; TOF Init Module 
; 
; To Do:
;   1. Create a TOF init module named TOF_INIT
;   2. Indicate all phases.  
;----------------------------------------------------
;********* Binding       *********; 
;********* Allocation    *********;   
TOF_INIT: 
  sei
;********* Access        *********; 
  movb #$80, TSCR1 ;enable TCNT
  movb #$86, TSCR2 ;arm TOI, 24MHz / 64 = 375KHz = 2.67us cycle, = 175ms overflow.
  movw #0, Time
;********* Deallocation  *********;  
  cli
  rts
          
;---------------------------------------------------- 
; LCD Init Module   
;----------------------------------------------------
;********* Allocation    *********;    
LCD_INIT:
          PSHA                      ; Save old A

;********* Access        *********;
          BSET    DDRK,$FF          ; Set Port K to Output
          LDAA    #$28              ; Function Set: 4-bit, 2 Line, 5x7 Dots
          JSR     COM_WRT
          JSR     LCD_CLEAR         ; Clear LCD
          LDAA    #$06              ; Entry Mode
          JSR     COM_WRT
                   
;********* Deallocation  *********;
          PULA                      ; Restore A
          RTS         
         
;---------------------------------------------------- 
; LCD Display Modules    
;---------------------------------------------------- 
;********* Allocation    *********;           
LCD_D:
          PSHD                        ; Save D
  
;********* Access        *********;                    
          ; Set cursor back to beg
          LDAA    #$80
          JSR     COM_WRT
          
          ; Convert ADC input from 16-bit digital to ASCII
          LDD     ADC_IN
          JSR     B2A
          LDAA    ASCII_OUT
          JSR     DATA_WRT
          LDAA    ASCII_OUT+1
          JSR     DATA_WRT
          LDAA    ASCII_OUT+2
          JSR     DATA_WRT
          
          ; Set cursor to 2nd line
          LDAA    #$C0
          JSR     COM_WRT
          
          LDAA    #$00
          LDAB    ADC_IN_VI
          JSR     B2A
          LDAA    ASCII_OUT+2
          JSR     DATA_WRT
          LDAA    #'.'
          JSR     DATA_WRT
          
          LDAA    #$00
          LDAB    ADC_IN_VF
          JSR     B2A
          LDAA    ASCII_OUT+1
          JSR     DATA_WRT
          LDAA    ASCII_OUT+2
          JSR     DATA_WRT
          LDAA    #'V'
          JSR     DATA_WRT
          
;********* Deallocation  *********;
          PULD                        ; Restore D
          RTS    

;---------------------------------------------------- 
; Clear LCD Module   
;---------------------------------------------------- 
;********* Allocation    *********;   
LCD_CLEAR:
          PSHA                        ; Save old A
          
;********* Access        *********;                    
          LDAA    #$01                ; Clear Display (also clear DDRAM content)
          BSR     COM_WRT
          
;********* Deallocation  *********;
          PULA                        ; Restore A
          RTS     
           
;---------------------------------------------------- 
; Command Write Module 
;
; Input: CMD=RegA  
;----------------------------------------------------
;********* Binding       *********; 
CMD       SET     0                   ; Command (8-bit)

;********* Allocation    *********;
COM_WRT:
          PSHX                        ; Save old X
          PSHA                        ; Save old A
          PSHA                        ; Allocate CMD
          TSX
          
;********* Access        *********;          
          ; Write upper nibble only
          ANDA    #$F0                ; Get upper nibble only
          LSRA                        ; Shift right to align DB pins of LCD w/ Port K pins
          LSRA
          STAA    PORTK               ; Output to Port K
          BCLR    PORTK,RS            ; Set register select for an instruction
          BCLR    PORTK,RW            ; Writing
          ; Pulse High/Low
          BSET    PORTK,EN            ; Enable high
          NOP
          NOP
          NOP
          BCLR    PORTK,EN            ; Enable low

          ; Write lower nibble only
          LDAA    CMD,X               ; Reload Reg A w/ CMD
          ANDA    #$0F                ; Get lower nibble only
          LSLA                        ; Shift left to align DB pins of LCD w/ Port K pins
          LSLA
          STAA    PORTK               ; Output to Port K
          BCLR    PORTK,RS            ; Set register select for an instruction
          BCLR    PORTK,RW            ; Writing
          ; Pulse High/Low
          BSET    PORTK,EN            ; Enable high
          NOP
          NOP
          NOP
          BCLR    PORTK,EN            ; Enable low
          
          LDY     #750
          BSR     TIMER_D             ; Delay ~0.1ms for LCD to finish processing

;********* Deallocation  *********;
          LEAS    1,SP                ; Deallocation
          PULA                        ; Restore A
          PULX                        ; Restore X
          RTS  
          
;---------------------------------------------------- 
; Data Write Module 
;
; Input: CMD=RegA  
;---------------------------------------------------- 
;********* Binding       *********; 
CMD       SET     0                   ; Command (8-bit)

;********* Allocation    *********;
DATA_WRT:
          PSHX                        ; Save old X
          PSHA                        ; Save old A
          PSHA                        ; Allocate CMD
          TSX
          
;********* Access        *********; 
          ; Write upper nibble only
          ANDA    #$F0                ; Get upper nibble only
          LSRA                        ; Shift right to align DB pins of LCD w/ Port K pins
          LSRA
          STAA    PORTK               ; Output to Port K
          BSET    PORTK,RS            ; Set register select for data
          BCLR    PORTK,RW            ; Writing
          ; Pulse High/Low
          BSET    PORTK,EN            ; Enable high
          NOP
          NOP
          NOP
          BCLR    PORTK,EN            ; Enable low
          

          ; Write lower nibble only
          LDAA    CMD,X               ; Reload Reg A w/ CMD
          ANDA    #$0F                ; Get lower nibble only
          LSLA                        ; Shift left to align DB pins of LCD w/ Port K pins
          LSLA
          STAA    PORTK               ; Output to Port K
          BSET    PORTK,RS            ; Set register select for data
          BCLR    PORTK,RW            ; Writing
          ; Pulse High/Low
          BSET    PORTK,EN            ; Enable high
          NOP
          NOP
          NOP
          BCLR    PORTK,EN            ; Enable low
          
          LDY     #750                 
          BSR     TIMER_D             ; Delay ~0.1ms for LCD to finish processing

;********* Deallocation  *********;
          LEAS    1,SP                ; Deallocation
          PULA                        ; Restore A
          PULX                        ; Restore X
          RTS                    
          
;---------------------------------------------------- 
; Timer Delay Module
; 
; Input: RegY   
;----------------------------------------------------
;********* Binding       *********; 
START     SET     0                   ; TCNT Start (16-bit)
DELAYC    SET     2                   ; Delay Count (16-bit)

;********* Allocation    *********;   
TIMER_D: 
          PSHX                        ; Save old X
          PSHY                        ; Save old Y
          PSHD                        ; Save old D
          PSHY                        ; Allocate DELAYC=Y
          PSHY                        ; Allocate START
          TSX
          
;********* Access        *********;    
          MOVW    TCNT,START,X        ; START=TCNT          
          
TIMER_LOOP:         
          LDD     TCNT
          SUBD    START,X
          CPD     DELAYC,X
          BLO     TIMER_LOOP

;********* Deallocation  *********;
          LEAS    4,SP                ; Deallocation
          PULD                        ; Restore D
          PULY                        ; Restore Y
          PULX                        ; Restore X
          RTS
          
;---------------------------------------------------- 
; Convert Binary to ASCII Module     
; 
; Returns upper ASCII value (Reg B) and lower ASCII 
; value (Reg B) of ASCII equivalent of a 8-bit binary
; value in reg B. This is acomplished with BCD.
;
; Example:
;   53 decimal will return ASCII code
;   These ASCII values can be used to display on LCD
;   A = $35
;   B = $33    
;
; Code Example:
;   LDAB  #53
;   JSR   B2A
;
;---------------------------------------------------- 

;********* Binding       *********;  
IN_T2A      SET       0               ; 8-Bit

;********* Allocation    *********;
B2A:
          PSHY                        ; Save Y
          PSHX                        ; Save X
          PSHB                        ; IN_T2A = B 
          TSY                         ; SP->Y

;********* Access        *********;
          LDAB    IN_T2A,Y
          
          ; Right Most
          LDX     #10
          IDIV
          ADDB    #$30
          STAB    ASCII_OUT+2
                    
          ; Middle
          TFR     X,D
          LDX     #10
          IDIV
          ADDB    #$30
          STAB    ASCII_OUT+1
          
          ; Left Most
          TFR     X,D
          LDX     #10
          IDIV
          ADDB    #$30
          STAB    ASCII_OUT
          
          
;********* Deallocation  *********;
          PULB                        ; Restore B
          PULX                        ; Restore X
          PULY                        ; Restore Y
          RTS          

;---------------------------------------------------- 
; TOF ISR 
; 
; To Do: Create a TOF ISR named TOF_ISR 
;----------------------------------------------------
TOF_ISR: 
  sei
  
  ;make sure ADC is finished
H1
  brclr ATD0STAT0,$80,H1
  
  ;get ADC_IN from ad7; DR7 is 8bits
  ;ldd ATD0DR7
  ldd ATD0DR0  ; ********** single conv stored in DR0 **********
  std ADC_IN
  
  ;convert to voltage ; equ is ADCValue*5v/((2^8)-1)
  ldy #$0005 ;5
  ldx #$00ff ;255
  emul ;D*Y, answer in Y:D, max is 1024*5, will be only in D; can ignore Y
  idiv ;D/X, answer in X, remainder in D  
  pshd
  
  ;ADC_IN_VI is integer part 
  tfr X,B  ;clip X to 8bit
  stab ADC_IN_VI ;x is integer answer
  
  puld
  
  ;ADC_IN_VF is fraction part this answer was mod 256, 
  ;now must be mapped to decimal for readability
  ldy #$0064 ;100
  ldx #$0100 ;256
  emul ;D*Y=Y:D, Y is ignored, D is ADC_IN_VF*100
  idiv ;D/X=X, R=D, D is ignored, X is ADC_IN_VF*100/255
  tfr X,B  ;clip x to 8bit
  stab ADC_IN_VF
  
  ;call lcd_d
  ;jmp LCD_D  ; ********** jump instead of jsr **********
  jsr LCD_D
  
  cli
  rti   

;---------------------------------------------------- 
; Interrupt Vector(s) 
; 
; To Do: Create the appropriate interrupt vector(s)
;----------------------------------------------------
;org $FFDE ;timer overflow 
    ;doesnt compile
  org $3E5E ;timer overflow ;dragon12 off-set by c180
  fdb TOF_ISR
