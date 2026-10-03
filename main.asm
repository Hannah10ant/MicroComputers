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
COUNTER .set    R15

        .text

RESET:
        MOV.W   #0x2000, SP
        MOV.W   #WDTPW+WDTHOLD, &WDTCTL

        ; Configure LED pins as outputs
        MOV.B   #0Fh, &PJDIR       ; LED1-LED4
        MOV.B   #0F0h, &P3DIR      ; LED5-LED8
        ; Configure Switches as inputs
        MOV.B   #00h, &P4DIR       ; S1 and S2
        bis.b   #BIT0+BIT1,&P4REN       ; enable resistors
        bis.b   #BIT0+BIT1,&P4OUT       ; set as pull-up


Mainloop:
        ; LED4 and LED5 on
        MOV.B   #LED4, &PJOUT
        MOV.B   #LED5,  &P3OUT
        CALL    #Wait

        ; LED3 and LED6 on
        MOV.B   #LED3, &PJOUT
        MOV.B   #LED6,  &P3OUT
        CALL    #Wait

        ; LED2 and LED7 on
        MOV.B   #LED2, &PJOUT
        MOV.B   #LED7,  &P3OUT
        CALL    #Wait

        ; LED1 and LED8 on
        MOV.B   #LED1, &PJOUT
        MOV.B   #LED8,  &P3OUT
        CALL    #Wait

        ; LED2 and LED7 on
        MOV.B   #LED2, &PJOUT
        MOV.B   #LED7,  &P3OUT
        CALL    #Wait

        ; LED3 and LED6 on
        MOV.B   #LED3, &PJOUT
        MOV.B   #LED6,  &P3OUT
        CALL    #Wait

        JMP     Mainloop
        NOP
PORT4_ISR:
    add.w   &P4IV,PC        ; reading P4IV clears the highest-priority flag
    reti                    ; 0: nothing pending
    jmp     S1_ISR      ; 2: P4.0 (S1)
    jmp     S2_ISR      ; 4: P4.1 (S2)
    reti                    ; 6 to 14: P4.2 to P4.7, not enabled
    reti                        
    reti
    reti
    reti

; ISR for switch 1
S1_ISR:
    LEDSET1:
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
    JMP LEDSET1

; ISR for switch 2
S2_ISR:

;-----------------------------------------------
; Subroutines
;-----------------------------------------------
; Delay subroutine
Wait1:
        MOV.W   #DELAY, COUNTER

DelayLoop1:
        DEC.W   COUNTER
        JNZ     DelayLoop1

        RET

        .sect   ".reset"
        .short  RESET

        .end

Wait2:
        MOV.W   #DELAY, COUNTER

DelayLoop2:
        DEC.W   COUNTER
        JNZ     DelayLoop2

        RET

        .sect   ".reset"
        .short  RESET

        .end
