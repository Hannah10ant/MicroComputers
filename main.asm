; Blink LED on MSP430FR5739 development board
; Toggles LED connected to PJ.0 using a software delay loop
; Original code from Lab 1 Part 5
; Converted from IAR to CCS assembler syntax
;-----------------------------------------------------------------------------

        .cdecls C,LIST,"msp430.h"       ; Include MSP430FR5739 device header

        .def    RESET                   ; Export RESET label so linker can find it

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

DELAY   .equ    50000
COUNTER .set    R15

        .text

RESET:
        MOV.W   #0x2000, SP
        MOV.W   #WDTPW+WDTHOLD, &WDTCTL

        ; Configure LED pins as outputs
        MOV.B   #0Fh, &PJDIR       ; LED1-LED4
        MOV.B   #0F0h, &P3DIR      ; LED5-LED8

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

;-----------------------------------------------
; Delay subroutine
;-----------------------------------------------
Wait:
        MOV.W   #DELAY, COUNTER

DelayLoop:
        DEC.W   COUNTER
        JNZ     DelayLoop

        RET

        .sect   ".reset"
        .short  RESET

        .end
