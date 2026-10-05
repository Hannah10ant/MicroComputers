; Blink LED on MSP430FR5739 development board
; Toggles LED connected to PJ.0 using a software delay loop
; Original code from Lab 1 Part 5
; Converted from IAR to CCS assembler syntax
;-----------------------------------------------------------------------------

        .cdecls C,LIST,"msp430.h"       ; Include MSP430FR5739 device header

        .def    RESET                   ; Export RESET label so linker can find it

; LED Declarations
; LED1 to LED4 - Port J
LED1    .equ    01h
LED2    .equ    02h
LED3    .equ    04h
LED4    .equ    08h
; LED5 to LED8 - Port 3
LED5    .equ    10h
LED6    .equ    20h
LED7    .equ    40h
LED8    .equ    80h
; S1 and S2 - Port 4

DELAY   .equ    50000
; Names R15 counter
COUNTER         .set R15
; Names R4 flagnormal
FLAGNORMAL      .set R4
; Names R5 flagemergency
FLAGEMERGENCY   .set R4

        .text

RESET:
        MOV.W   #0x2000, SP
        MOV.W   #WDTPW+WDTHOLD, &WDTCTL

        ; Configure LED pins as outputs
        MOV.B   #0Fh, &PJDIR            ; LED1-LED4
        MOV.B   #0F0h, &P3DIR           ; LED5-LED8
        ; Configure Switches as inputs
        MOV.B   #00h, &P4DIR            ; S1 and S2
        bis.b   #BIT0+BIT1,&P4REN       ; enable resistors
        bis.b   #BIT0+BIT1,&P4OUT       ; set as pull-up


Mainloop:
        bit.w   #1, R5                  ; Loads value of R5 for jnz term
        jnz     RUN_EMERGENCY            ; Emergency above normal, hence it gets priority
        bit.w   #1, R4                  ; Loads value of R4 for jnz term
        jnz     RUN_NORMAL
        bic.b   #BIT0,&PJOUT            ; make sure LED is off when stopped
        bis.w   #LPM0,SR                ; sleep until a button wakes us

        jmp     Mainloop
        nop

;-----------------------------------------------
; ISR
;-----------------------------------------------

PORT4_ISR:
        mov.w   #20000,R6               ; Debounces switch
Deb:    dec.w   R6
        jnz     Deb

        add.w   &P4IV,PC        ; reading P4IV clears the highest-priority flag
        reti                    ; 0: nothing pending
        jmp     S1_FUNC         ; 2: P4.0 (S1)
        jmp     S2_FUNC         ; 4: P4.1 (S2)
        reti                    ; 6 to 14: P4.2 to P4.7, not enabled
        reti                        
        reti
        reti
        reti



;-----------------------------------------------
; Subroutines
;-----------------------------------------------

; Emergency LED running
RUN_EMERGENCY: 
    ; LED5 on
    MOV.B   #LED5, &P3OUT
    CALL    #Wait1
    ; LED6 on
    MOV.B   #LED6, &P3OUT
    CALL    #Wait1
    ; LED7 on
    MOV.B   #LED7, &P3OUT
    CALL    #Wait1
    ; LED8 on
    MOV.B   #LED8, &P3OUT
    CALL    #Wait1
    reti

; Normal LED running
RUN_NORMAL: 
    ; LED1 on
    MOV.B   #LED1, &PJOUT
    CALL    #Wait1
    ; LED2 on
    MOV.B   #LED2, &PJOUT
    CALL    #Wait1
    ; LED3 on
    MOV.B   #LED3, &PJOUT
    CALL    #Wait1
    ; LED4 on
    MOV.B   #LED4, &PJOUT
    CALL    #Wait1
    ret

; ISR for switch 1
S1_FUNC:
    /*Load flag bit into R4. 1: Run, 0: Don't run*/
    xor.B #1, FLAGNORMAL
    bic.w   #LPM0,0(SP)             ; wake main on return
    ret

; ISR for switch 2
S2_FUNC:
    /*Load flag bit into R5. 1: Run, 0: Don't run*/
    xor.B #1, FLAGEMERGENCY
    bic.w   #LPM0,0(SP)             ; wake main on return
    reti


; Delay subroutine
WaitNormal:
        MOV.W   #DELAY, COUNTER

DelayLoopNormal:
        DEC.W   COUNTER
        JNZ     DelayLoopNormal

        RET

        .sect   ".reset"
        .short  RESET

        .end

WaitEmergency:
        MOV.W   #DELAY, COUNTER

DelayLoopEmergency:
        DEC.W   COUNTER
        JNZ     DelayLoopEmergency

        RET

        .sect   ".reset"
        .short  RESET

        .end
