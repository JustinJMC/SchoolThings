;****************************************************************
;* 
;* Postfix Calculator
;*
;* 1) Single digit integer values
;* 2) Add, subtract, multiply, and divide
;* 3) For multiply/divide only show lower 8-bits
;* 4) Range of results should be 0-255 bounded
;* 5) Should display inputs to LCD screen
;* 6) Keys a, b, c, and d are add, subtract, multiply, and division
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

; ---------------------------------------------------- 
; Constants Section
; KEEP THIS!!		
; ---------------------------------------------------- 
ROM       EQU     $0400
DATA      EQU     $1000
PROG      EQU     $2000

COLS      EQU     PORTA
ROWS      EQU     PORTA
LED       EQU     PORTB
ROW0      EQU     %00010000
ROW1      EQU     %00100000
ROW2      EQU     %01000000
ROW3      EQU     %10000000
COLM      EQU     %00001111
ROWM      EQU     %11110000

RS        EQU     $01           ; Register Select pin for LCD module  
EN        EQU     $02           ; Enable pin for LCD module


; ---------------------------------------------------- 
; Variable/Data Section
; KEEP THIS!!		
; ----------------------------------------------------  
          ORG     DATA

CMD       FDB     $0000

          ; ASCII
KCODE0    FCB     $31,$32,$33,$41   ; "123A"
KCODE1    FCB     $34,$35,$36,$42   ; "456B"
KCODE2    FCB     $37,$38,$39,$43   ; "789C"
KCODE3    FCB     $2A,$30,$23,$44   ; "*0#D"

          ; Timer Vars
START     RMB     2
DELAY     FDB     187                    ; 1ms for E-Clock = 187.5kHz 
WAIT      FDB     10                     ; 10ms  
WAIT10    fdb     100                    ; 100ms
WAIT100   fdb     1000                   ; 1s

;********* Binding       *********; for T2A subroutine  
IN_T2A    SET       0                 ; 8-Bit
ASCII_U   SET       1                 ; 8-Bit


; ---------------------------------------------------- 
; Code Section
; KEEP THIS!!		
; ---------------------------------------------------- 
          ORG     PROG

; Insert your code following the label "Entry"          
Entry:                              ; KEEP THIS LABEL!!
          LDS     #PROG             ; Stack
          JSR     TMR_INIT          ; Init timer for delay
          JSR     INIT              ; Init peripherals
          
          ; Test to make sure no keys pressed
          ; Loop until key released
KP_START:
          LDAA    #ROWM        
          STAA    ROWS              ; Set rows high
          LDY     WAIT10            ; wait 100ms
          JSR     TMR_WAIT          ; Debounce
          LDAA    COLS              ; Capture Port A
          ANDA    #COLM             ; Mask out rows
          CMPA    #$00         
          BEQ     KP_START          ; If columns is zero, then no keys pressed

          ; Start driving rows                
          ; Drive row 0
DRIVE_R0:
          LDAA    #ROW0             ; Make row 0 high and the rest ground
          STAA    ROWS 
          LDY     WAIT10            ; wait 100ms
          JSR     TMR_WAIT          ; Debounce
          LDAA    COLS              ; Read Port A
          ANDA    #COLM             ; Mask out rows
          CMPA    #$00              ; Is input zero?
          BNE     R0                ; If column != 0, then pressed key is in row 0
          
          ; Drive row 1
DRIVE_R1:
          LDAA    #ROW1             ; Make row 1 high and the rest ground
          STAA    ROWS
          LDY     WAIT10            ; wait 100ms
          JSR     TMR_WAIT          ; Debounce              
          LDAA    COLS              ; Read Port A
          ANDA    #COLM             ; Mask out rows
          CMPA    #$00              ; Is input zero?
          BNE     R1                ; If column != 0, then pressed key is in row 1
          
          ; Drive row 2
DRIVE_R2:
          LDAA    #ROW2             ; Make row 2 high and the rest ground
          STAA    ROWS
          LDY     WAIT10            ; wait 100ms
          JSR     TMR_WAIT          ; Debounce              
          LDAA    COLS              ; Read Port A
          ANDA    #COLM             ; Mask out rows
          CMPA    #$00              ; Is input zero?
          BNE     R2                ; If column != 0, then pressed key is in row 2
          
          ; Drive row 3
DRIVE_R3:
          LDAA    #ROW3             ; Make row 3 high and the rest ground
          STAA    ROWS 
          LDY     WAIT10            ; wait 100ms
          JSR     TMR_WAIT          ; Debounce             
          LDAA    COLS              ; Read Port A
          ANDA    #COLM             ; Mask out rows
          CMPA    #$00              ; Is input zero?
          BNE     R3                ; If column != 0, then pressed key is in row 3
          
          ; If row not found, then go back to start
          BRA     KP_START
          
          ; Load ASCII code for pressed key for row 0
R0:                   
          LDX     #KCODE0           ; Load pointer to row 0 array
          BRA     FIND              ; Go find column

          ; Load ASCII code for pressed key for row 1          
R1:                   
          LDX     #KCODE1           ; Load pointer to row 1 array
          BRA     FIND              ; Go find column

          ; Load ASCII code for pressed key for row 2         
R2:                   
          LDX     #KCODE2           ; Load pointer to row 2 array
          BRA     FIND              ; Go find column

          ; Load ASCII code for pressed key for row 3          
R3:                   
          LDX     #KCODE3           ; Load pointer to row 3 array
          BRA     FIND              ; Go find column
          
          ; Find which key is pressed by scanning columns         
FIND:                 
          ANDA    #COLM             ; Mask out rows
          COMA                      ; Invert columns
SHIFT:                
          LSRA                      ; Logical shift right Port A
          BCC     MATCH             ; If carry clear, then column is found
          INX                       ; If carry not clear, then increment row pointer
          BRA     SHIFT             ; Shift right unitl carry is clear
MATCH:                
          LDAA    0,X               ; Load ASCII from row array
          ;STAA    LED               ; Put ASCII to Port B, display on LEDs
          
;make switch for A compare to ascii values
   cmpa #$2A ;'*'
   beq Restart
   cmpa #$23 ;'#'
   beq BackSpace
   cmpa #$41 ;'A'
   beq Addition
   cmpa #$42 ;'B'
   beq Addition
   cmpa #$43 ;'C'
   beq Addition
   cmpa #$44 ;'D'
   beq Addition
   bra Default 
   
Restart:;* is restart? (optional)
   ldx #PROG      ;load origin stack pointer into x
   txs            ;put x into stack pointer
   bra end_switch ;will redisplay an empty stack
   
BackSpace:;# is backspace? (optional)
    tsx ;transfer stack pointer into x
    inx ;there must be atleast 1 value on stack
    cpx #PROG 
    bhi end_switch ;X-1 > #PROG (unsigned), THERE IS NOTHING IN THE STACK
    
    ins ;increment the SP, meaning a value is dropped off the stack.
    bra end_switch 
    
Addition:;A is addition
    tsx ;transfer sp to x
    inx
    inx ;there must be atlest 2 values on stack
    cpx #PROG
    bhi end_switch ;x+2 > #PROG (unsigned), THERE IS NOTHING IN THE STACK  
    
    pula ;A=SP
    pulb ;B=SP+1
    aba  ;B+A
    psha ;push result
    
    bra end_switch ;redisplay
    
Subtraction:;B is subtraction                                       
    tsx ;transfer sp to x
    inx
    inx ;there must be atlest 2 values on stack
    cpx #PROG
    bhi end_switch ;x+2 > #PROG (unsigned), THERE IS NOTHING IN THE STACK
   
    pulb ;B=SP
    pula ;A=SP+1
    sba  ;B-A
    psha ;push result 

    bra end_switch 
   
Multiply:;C is multi                                                           
    tsx ;transfer sp to x
    inx
    inx ;there must be atlest 2 values on stack
    cpx #PROG
    bhi end_switch ;x+2 > #PROG (unsigned), THERE IS NOTHING IN THE STACK  
   
    pula ;a = SP
    pulb ;b = sp+1
    mul  ;D = A*B
    pshb  ;push lower 8bits (reg B)
    
    bra end_switch
   
Divide:;D is divide                                                           
    tsx ;transfer sp to x
    inx
    inx ;there must be atlest 2 values on stack
    cpx #PROG
    bhi end_switch ;x+2 > #PROG (unsigned), THERE IS NOTHING IN THE STACK  
   
    pula ;a = SP  ;put a into x
    tfr A, X
    pulb ;b = sp+1;put b into D (right justified) ;clear A
    ;tfr B, D
    clra
    
    idiv  ;X = D/X put ;put x into D
    tfr X, D
      
    pshb  ;push lower 8bits (reg B)
    
    bra end_switch
   
Default:;default it is a number
    psha ;save a for the next part
    ;ldaa (ascii value) ; value is already in A
    jsr DATA_WRT  ;load ascii value A into display
    ldy #01       ;load 1 into y
    jsr TMR_WAIT  ;wait 1ms

    ;convert ascii to binary
    pula ;load the value of a
    clc  ;clear the carry bit (just in case)
    sbca #$30 ; subtract $30 hex from the ascii value to get the hex true value
    psha ;leave A (the character pressed) on the stack 
  
    jmp KP_START
  
end_switch:

ReDisplay:
  ;loop while there are things in the stack
  ;transfer SP into x
  tsx
  
While_Display:
  ;while x less than #PROG
  cpx #PROG
  bhs While_End
    ;ldaa x
    ldaa X
    ;t2a subroutine a (returns D  (a)upper:(b)lower)
    jsr T2A
    pshD ;put d onto stack 
    ;read sp+1 into a
    ldaa SP      
    ;display a (upper)
    jsr DATA_WRT  ;load ascii value A into display
    ldy #01       ;load 1 into y
    jsr TMR_WAIT  ;wait 1ms
    ;read sp into a
    ldaa 1,SP
    ;display a (lower) 
    jsr DATA_WRT  ;load ascii value A into display
    ldy #01       ;load 1 into y
    jsr TMR_WAIT  ;wait 1ms
    ;deallocate Y off the stack.
    leas 2,SP
    ;incriment x
    inx
    
    BRA While_Display
  ;end while
While_End:    
  ;display digits up to 255, else max 255 min 0
    
  ; Back to start
  ;BRA    KP_START
  jmp KP_START      
; ---------------------------------------------------- 
; Text to ASCII Subroutine     
; ---------------------------------------------------- 
          
;********* Allocation    *********;
T2A:
          PSHY                        ; Save Y
          PSHX                        ; Save X
          LEAS    -1,SP               ; Allocate ASCII_U
          PSHA                        ; IN_T2A = A 
          TSY                         ; SP->Y

;********* Access        *********;
          ; Upper  
          LDAA    IN_T2A,Y
          
          ; BCD
          SEX     A,D                 ; Convert A to 16-bit
          LDX     #10
          IDIV
          
          ; ASCII
          ADDB    #$30
          STAB    ASCII_U,Y
                    
          ; Lower
          ; BCD
          TFR     X,D
          LDX     #10
          IDIV
          
          ; ASCII          
          ADDB    #$30
          TBA
          
          ; Load upper
          LDAB    ASCII_U,Y
          
;********* Deallocation  *********;
          LEAS    2,SP                ; Deallocate
          PULX
          PULY
          RTS          
                           
; ---------------------------------------------------- 
; Init Subroutines      
; ----------------------------------------------------           
INIT:     
          ; Enable discrete LEDs
          ;BSET    DDRB,#$FF         ; Set Port B to output
          ;BSET    DDRJ,#$02         ; Set Port J pin 1 to output
          ;BCLR    PTJ,#$02          ; Enable discrete LEDs
          
          ; Disable 7-segment display
          BSET    DDRP,#$0F         ; Set Port P pins 0-3 to output
          BSET    PTP, #$0F         ; Disable 7-segment display
          
          ; Enable keypad
          LDAA    #$F0
          STAA    DDRA              ; Set Port A pins 7-4 to high, else low
          
          ; Set Port K to Output
          LDAA    #$FF
          STAA    DDRK          	         	
          BSR     CLEAR         ; Clear LCD screen    
          
          RTS 
          
;---------------------------------------------------- 
; Clear LCD Subroutine   
;----------------------------------------------------
; This sequence of instructions initializes the LCD and
; sets the cursor to the beginning of the first line.
; It also will move the cursor to the right, one space,
; when writing a new character. Please note, characters
; don't wrap around.    
CLEAR:
          LDAA    #$33
          BSR     COM_WRT    
          ldy     #$01   ;wait 1ms
          JSR     TMR_WAIT               	

          LDAA    #$32
          BSR     COM_WRT
          ldy     #$01   ;wait 1ms
          JSR     TMR_WAIT         

          LDAA    #$28
          BSR     COM_WRT
          ldy     #$01   ;wait 1ms
          JSR     TMR_WAIT         

          LDAA    #$0E
          BSR     COM_WRT
          ldy     #$01   ;wait 1ms
          JSR     TMR_WAIT         

          LDAA    #$01
          BSR     COM_WRT
          ldy     #$01   ;wait 1ms
          JSR     TMR_WAIT         

          LDAA    #$06
          BSR     COM_WRT
          ldy     #$01   ;wait 1ms
          JSR     TMR_WAIT         

          LDAA    #$80
          BSR     COM_WRT
          ldy     #$01   ;wait 1ms
          JSR     TMR_WAIT           

          RTS     
           
;---------------------------------------------------- 
; Command Write Subroutine   
;---------------------------------------------------- 
COM_WRT:
          STAA	  CMD           ; Save curent command into CMD

          ; Write upper nibble only
          ANDA    #$F0          ; Get upper nibble only
          LSRA                  ; Shift right to align DB pins of LCD w/ Port K pins
          LSRA
          STAA    PORTK         ; Output to Port K
          BCLR    PORTK,RS      ; Set register select for an instruction <----
          BSET    PORTK,EN      ; Enable high
          NOP                   ; Delay 1 cycle
          NOP                   ; Delay 1 cycle
          NOP                   ; Delay 1 cycle
          BCLR    PORTK,EN      ; Enable low

          ; Write lower nibble only
          LDAA    CMD           ; Reload Reg A w/ CMD
          ANDA    #$0F          ; Get lower nibble only
          LSLA                  ; Shift left to align DB pins of LCD w/ Port K pins
          LSLA
          STAA    PORTK         ; Output to Port K
          BCLR    PORTK,RS      ; Set register select for an instruction <----
          BSET    PORTK,EN      ; Enable high
          NOP                   ; Delay 1 cycle
          NOP                   ; Delay 1 cycle
          NOP                   ; Delay 1 cycle
          BCLR    PORTK,EN      ; Enable low

          RTS
          
;---------------------------------------------------- 
; Data Write Subroutine   
;---------------------------------------------------- 
DATA_WRT:
          STAA	  CMD           ; Save curent command into CMD

          ; Write upper nibble only
          ANDA    #$F0          ; Get upper nibble only
          LSRA                  ; Shift right to align DB pins of LCD w/ Port K pins
          LSRA
          STAA    PORTK         ; Output to Port K
          BSET    PORTK,RS      ; Set register select for data <----
          BSET    PORTK,EN      ; Enable high
          NOP                   ; Delay 1 cycle
          NOP                   ; Delay 1 cycle
          NOP                   ; Delay 1 cycle
          BCLR    PORTK,EN      ; Enable low

          ; Write lower nibble only
          LDAA    CMD           ; Reload Reg A w/ CMD 
          ANDA    #$0F          ; Get lower nibble only
          LSLA                  ; Shift left to align DB pins of LCD w/ Port K pins
          LSLA
          STAA    PORTK         ; Output to Port K
          BSET    PORTK,RS      ; Set register select for data <----
          BSET    PORTK,EN      ; Enable high
          NOP                   ; Delay 1 cycle
          NOP                   ; Delay 1 cycle
          NOP                   ; Delay 1 cycle
          BCLR    PORTK,EN      ; Enable low

          RTS


;---------------------------------------------------- 
; Timer/Delay Subroutine     
;---------------------------------------------------- 
TMR_INIT:
          MOVB    #$80,TSCR1              ; Enable TCNT
          MOVB    #$07,TSCR2              ; E = 24MHz/128 = 187.5kHz (5.33us)
          RTS
          
TMR_WAIT:
          BSR     TMR_WAIT_1MS
          DEY
          CPY     #0
          BNE     TMR_WAIT
          RTS       
          
TMR_WAIT_1MS:
          MOVW    TCNT,START              ; TCNT at start
WLOOP:
          LDD     TCNT                    ; Now
          SUBD    START                   ; soFar = TCNT-START
          CPD     DELAY
          BLO     WLOOP                   ; Loop if soFar < DELAY
          RTS     
          
