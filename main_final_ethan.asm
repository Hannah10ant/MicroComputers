
;	Interrupt vector table mappings
	.intvec	".int32",	button_ISR
	.intvec	".int41",	timer1_ISR
	.intvec	".int45",	Timer0_ISR
	.intvec	".int44",	timer0_A1_ISR
	.intvec	".int48",	UART_ISR
	.global	current_task
	.data
	.align	1

current_task:
	.bits		0,8
			; current_task @ 0

	.global	normal_suspended
	.data
	.align	1

normal_suspended:
	.bits		0,8
			; normal_suspended @ 0

	.global	normal_timer_mem
	.data
	.align	2

normal_timer_mem:
	.bits		0,16
			; normal_timer_mem @ 0

	.global	S1_LED_state
	.data
	.align	1

S1_LED_state:
	.bits		0,8
			; S1_LED_state @ 0

	.global	sys_timer_overflow
	.data
	.align	2

sys_timer_overflow:
	.bits		0,16
			; sys_timer_overflow @ 0

	.global	time
	.sect	".data:time", RW
	.align	2

time:
	.bits		0x30,8
			; time[0] @ 0
	.bits		0x30,8
			; time[1] @ 8
	.bits		0x30,8
			; time[2] @ 16
	.bits		0x30,8
			; time[3] @ 24
	.bits		0x30,8
			; time[4] @ 32
	.bits		0x30,8
			; time[5] @ 40
	.bits		0x30,8
			; time[6] @ 48
	.bits		0x30,8
			; time[7] @ 56
	.bits		0x30,8
			; time[8] @ 64
	.bits		0x30,8
			; time[9] @ 72
	.bits		0,8
			; time[10] @ 80

	.global	print_idx
	.data
	.align	1

print_idx:
	.bits		0,8
			; print_idx @ 0

	.global	print_str
	.common	print_str,2,2

	.sect	".text:_isr:timer1_ISR"
	.clink
	.global	timer1_ISR

; Timer 1 ISR
timer1_ISR:
        PUSHM.A   #1,r15                ; Sets R15 to 1
        CMP.B     #1,&current_task    ; Checks if current task is NORMAL (1)
        JEQ       Emergency_Running     ; Jumps to required statement

; ----------------
        CMP.B     #2,&current_task    ; Checks if current task is emergency (2) 
        JEQ       Normal_Running        ; [] |513| 
                                        
; ----------------
        NOP                             ; End of if statement
        JMP       End_Running          ;
                                        
; ----------------
Emergency_Running:    
        XOR.B     #240,&PBOUT_L     ; Activates all LEDs
        JMP       End_Running                 
                                        
;* ---------------
Normal_Running:    
        MOV.B     &S1_LED_state,r15   ; Moves LED_State into r15
        TST.W     r15                   ; Checks condition
        JEQ       Case_8           
; ----------------
        SUB.W     #1,r15                ; Decrements
        JEQ       Case_4                ; Checks condition
; ----------------
        SUB.W     #1,r15                ; Decrements
        JEQ       Case_2                ; Checks condition
; ----------------
        SUB.W     #1,r15                ; Decrements
        JEQ       Case_1                ; Checks condition
; Default Condition
        AND.W     #65520,&PJOUT       ; Sets all LEDs off
        MOV.B     #0,&S1_LED_state    ; Sets state to 0
        JMP       End_Running           

Case_8:    
        MOV.W     #8,&PJOUT           ; Activates LED 4 
        MOV.B     #0,&S1_LED_state    ; Increments LED state 
        JMP       End_Running            

Case_4:    
        MOV.W     #4,&PJOUT           ; Activates LED 3 
        ADD.B     #1,&S1_LED_state    ; Increments LED state 
        JMP       End_Running            

Case_2:    
        MOV.W     #2,&PJOUT           ; Activates LED 2
        ADD.B     #1,&S1_LED_state    ; Increments LED state  
        JMP       End_Running            

Case_1:    
        MOV.W     #1,&PJOUT           ; Activates LED 1
        ADD.B     #1,&S1_LED_state    ; Increments LED state 

End_Running:    
        BIC.W     #1,&TA1CCTL0        ; Sets Timer 1 control register to inverse of CCIF6 
        POPM.A    #1,r15                
        RETI      

	.sect	".text:_isr:timer0_A1_ISR"
	.clink
	.global	timer0_A1_ISR
;* --------------------------------------------------------------------------*


; Timer 0 A1 ISR
timer0_A1_ISR:
        BIC.W     #16,0(SP)             ; Clears bits in status register. Exits LPM0
        BIC.W     #1,&TA0CCTL1        ; Sets bit zero to 0
        RETI      

	.sect	".text:printstr"
	.clink
	.global	printstr
;* --------------------------------------------------------------------------*

; Function for printing string to serial terminal through UART
printstr:
        MOV.W     r12,&print_str      ; Set variable print_str equal to string to be printed
        MOV.B     #0,&print_idx       ; Sets print_index to 0 
        ; Moves current character to transmit buffer
        MOV.B     &print_idx,r15      ; Loads current index into memory
        ADD.W     &print_str,r15      ; Loads the address of the character
        MOV.B     @r15,r15              ; Loads the character
        MOV.W     r15,&UCA0TXBUF      ; Writes character to transmit buffer

        ADD.B     #1,&print_idx       ; Increments index
        BIS.W     #2,&UCA0IE          ; Sets transmit enable bit in USCI A0 enable register
                                        ; Raises an interrupt once the buffer is clear and ready

        NOP                     
        BIS.W    #24,SR                 ; Enables global interrupts and enters LPM0
        NOP      
        RETA      

	.sect	".text:initial"
	.clink
	.global	initial
;* --------------------------------------------------------------------------*

; Initial Setup Function
initial:
        MOV.W     #23168,&WDTCTL      ; Pauses WDT
        MOV.W     #0,&TA0CTL          ; Clears Timer A0 control register
        MOV.W     #0,&TA1CTL          ; Clears Timer A1 control register
        MOV.W     #1,&PJDIR           ; Sets LED1 as an output
        MOV.B     #165,&CSCTL0_H    ; Unlocks CS
        BIC.W     #1,&CSCTL4          ; Turns on XT1
        AND.W     #63624,&CSCTL2      ; ANDS clock source select bits to 0
        MOV.W     #51,&CSCTL2         ; ALCK source is XT1CLK ~32769 Hz
        AND.W     #63743,&CSCTL3      ; Alck Input divider /1
        AND.W     #65343,&CSCTL4      ; ANDS to negated XT1DRIVE_3
        AND.W     #65503,&CSCTL4      ; ANDS to negated xts
        BIS.W     #64,&CSCTL5         ; ORs with ENSTFCNT1
;* --------------------------------------------------------------------------*

initial_loop:    
        BIC.W     #1,&CSCTL5          ; Clears using negated XT1OFFG
        BIC.W     #2,&SFRIFG1         ; Clears with negated OFIFG
        XOR.W     #1,&PJOUT           ; Toggles LED1
        BIT.W     #2,&SFRIFG1         ; 
        JNE       initial_loop                 

;* ---------------

        MOV.B     #0,&CSCTL0_H        ; Sets to 0
        MOV.W     #0,&PJOUT           ; Sets LED1-4 off

        ; Timer 0 config
        AND.W     #65487,&TA0CTL      ; Turns off timer to give a stable config
        BIS.W     #256,&TA0CTL      ; ALCK
        BIS.W     #192,&TA0CTL      ; 8 -> 4096 Hz
        BIS.W     #4,&TA0CTL          ; Clears TAOR so it starts from a known
        MOV.W     #15359,&TA0CCR0     ; Timer overflows at 15 sec
        AND.W     #16127,&TA0CCTL0    ; No capture mode
        BIS.W     #16,&TA0CCTL0       ; Enables interrupts
        AND.W     #16127,&TA0CCTL1    ; Turns timers on
        BIS.W     #16,&TA0CTL         ; Sets timer to up mode 

        ; Timer 1 config
        AND.W     #65487,&TA1CTL      ; Turns timer off for stable config
        BIS.W     #256,&TA1CTL      ; ALCK
        BIS.W     #192,&TA1CTL      ; 8 -> 4096 Hz
        BIS.W     #4,&TA1CTL          ; Clears TAOR so it starts from a known
        AND.W     #16127,&TA1CCTL0    ; No capture mode

        ; GPIO configs 
        MOV.W     #15,&PJDIR          ; Sets upper nibble of PJ as output
        MOV.B     #240,&PBDIR_L     ; Sets lower nibble fo P3 (PB_L) as output
        MOV.B     #0,&PBDIR_H         ; Sets P4 (PB_H) as input

        ; Enables pull up on buttons for active low
        BIS.B     #3,&PBREN_H          
        BIS.B     #3,&PBOUT_H         

        ; Interrupts occurs on high to low
        BIS.B     #3,&PBIES_H         

        ; Clears existing interrupt flags 
        AND.B     #252,&PBIFG_H     

        ; Resets LEDs 1-8 to knowns 
        AND.W     #65520,&PJOUT        
        AND.B     #15,&PBOUT_L        

        ; Sets UART
        ; 9600 baud from 1MHz DCO CLK 
        MOV.B     #3,&PASEL1_H         
        MOV.B     #129,&UCA0CTLW0_L 
        MOV.W     #6,&UCA0BRW         
        MOV.W     #8321,&UCA0MCTLW   
        BIC.B     #1,&UCA0CTLW0_L    

        ; Enables button interrupts 
        BIS.B     #3,&PBIE_H      
        NOP
        BIS.W    #8,SR
        NOP       
        RETA     

	.sect	".text:convert_timer"
	.clink
	.global	convert_timer
;* --------------------------------------------------------------------------*

; Function to Convert Timer from integer to string
convert_timer:
                                        ; first label converts the overflow + TA0R to a timestamp number
        PUSHM.A   #4,r10                ; push registers r10, r9, r8, r7 to stack
        MOVA      r12,r7                ; move r12 (time string) to r7
        MOV.W     &sys_timer_overflow,r12 ; registers 12 to 15 used as arguments, see SLAA534A section 3.3
        MOV.W     #0,r13                ; upper half of argument "1" i.e. long is 32 bits r13 is upper half r12 is lower half
        MOV.W     #15000,r14            ; lower half of argument "2" i.e. long is 32 bits r14 is lower half r15 is upper half
        MOV.W     #0,r15                ;
        CALLA     #__mspabi_mpyl        ; muliply long by long subroutine

        MOVA      r12,r8                ; return from subroutine stored in R12:13 (unsigned long), see SLAA534A section 3.4
        MOVA      r13,r9                ; saves the result of sys_timer_overflow * 15000 in r8:r9
        MOV.W     &TA0R,r12             ; lower half of argument "1"
        MOV.W     #0,r13                ; upper half of argument "1"
        MOV.W     #1000,r14           ; lower half of argument "2"
        MOV.W     #0,r15                ; upper half of argument "2"
        CALLA     #__mspabi_mpyl        ; multiply long by long subroutine

        CALLA     #__mspabi_srll_12     ; shift long right by 12 subroutine, uses r12 and r13 as arguments

        ADD.W     r12,r8                ; r12 + r8 -> r8, produces a carry
        ADDC.W    r13,r9                ; r13 + r9 + C -> r9, produces upper byte of total_time
        MOV.W     #0,r10                ; Sets index for loop to 0
        CMP.W     #9,r10                ; Checks if index equals 9, r10 - 9 = 0 - 9 = -9 -> N = 1, V = 0
        JGE       conv_timer_end        ; Loops if less than, tests negative (N) and overflow bit (V), if both set or reset then jump

;* ---------------
conv_timer_loop:    
        MOVA      r8,r12                ; total_time (x)
        MOVA      r9,r13                ;
        MOV.W     #10,r14               ; 10 (y)
        MOV.W     #0,r15                ;
        CALLA     #__mspabi_remul       ; x mod y subroutine

        ADD.B     #48,r14               ; ASCII character '0' (not '\0') also note that r14 holds the final mod value
        MOVA      r7,r15                ; move the time string index to r15
        SUB.W     r10,r15               ; time - 0 -> time - 1 -> time - 2 -> ... 
        MOV.B     r14,9(r15)            ; time + 9 -> time + 8 -> time + 7 -> ...
        MOVA      r8,r12                ; total_time
        MOVA      r9,r13                ;
        MOV.W     #10,r14               ; 10
        MOV.W     #0,r15                ;
        CALLA     #__mspabi_divul       ; total_time / 10

        MOVA      r12,r8                ; save lower total time in r8
        MOVA      r13,r9                ; save upper total time in r9
        ADD.B     #1,r10                ; add 1 to the index
        SXT       r10                   ; idx is a signed value, dont want it overflowing
        CMP.W     #9,r10                ; check if index is 9
        JL        conv_timer_loop                 ; jump to loop label if index is less than 9

;* ---------------
conv_timer_end:    
        POPM.A    #4,r10                ; pop r10, r9, r8, r7 from the stack
        RETA                            ; 

	.sect	".text:main"
	.clink
	.global	main
;* --------------------------------------------------------------------------*

; Mainloop
main:
        CALLA     #initial              ; Runs initial
        MOV.W     #string1,r12         ; Prints first bracket
        CALLA     #printstr             ;
                                          
        MOV.W     #time,r12           ; Converts time to string 
        CALLA     #convert_timer        ; 

        MOV.W     #time,r12           ; Prints time
        CALLA     #printstr             ;

        MOV.W     #string2,r12         ; Prints End of string
        CALLA     #printstr             ; 

;* ---------------
Low_Power_Loop:    
        NOP
        BIS.W    #24,SR                 ; Enters LPM0
        NOP      
        JMP       Low_Power_Loop                
        NOP       
;* --------------
	.sect	".text:_isr:button_ISR"
	.clink
	.global	button_ISR
;* --------------------------------------------------------------------------*

; ISR Button
button_ISR:
        PUSHM.A   #5,r15                ; saves registers R15, R14, R13, R12, R11 on the stack
        AND.B     #252,&P4IE          ; port 4 interrupt enable #252 = #0xFC
        MOV.B     &P4IFG,r14            ; remember which interrupt flags were set in P4IFG in R14
        MOV.W     &TA0R,r15             ; remember the start point of TA0R in R15
        ADD.W     #120,r15            ; add 120 to the remembered TA0R as count up to value
        MOV.W     r15,&TA0CCR1          ; move the count to value into TA0CCR1
        CMP.W     &TA0CCR1,&TA0CCR0   ; compare the two registers
        JHS       Debnce_timr_ovrflow   ; jump if higher or same : if (TA0CCR1 < TA0CCR0)

;* ---------------
        MOV.W     &TA0CCR1,r15          ; if TA0CCR1 exceeds the system count up value
        SUB.W     &TA0CCR0,r15          ; subtract the system count up value from TA0CCR1
        SUB.W     #1,r15                ; subtract one for one off error
        MOV.W     r15,&TA0CCR1          ; move the new value into TA0CCR1
;* ---------------
Debnce_timr_ovrflow      
        BIS.W     #16,&TA0CCTL1         ; enable TA0CCR1 interrupts, #16 = #0x0010
        NOP                             ; recommended NOP before EINT
        EINT                            ; enable interrupts
        NOP                             ; instruction immediately after EINT is always run
        NOP
        BIS.W    #16,SR                 ; CPU OFF and GIE bits, was 24 changed to 16 because EINT already turns on GIE, waiting for timer interrupt
        NOP                             ; which techincally means you could remove the __enable_interrupt() on line 209 if using #24
        DINT                            ; disable interrupts
        NOP                             ; recommended NOP after DINT
        AND.W     #65519,&TA0CCTL1      ; disable interrupts from TA0CCR1, 65519 = 0xFFEF

;* --------------
        BIT.B     #2,r14                ; R14 holds the P4IFG flags, check if it has S2
        JNE       S2_event                ; jump not equal -> if S2 switch jump to S2_event, JNE checks Z flag, if #2 = r14 then Z = 0 so not equal
                                        ; in essence the if statement, any logic past this has no emergency
;* ---------------
        BIT.B     #1,r14                ; R14 holds the P4IFG flags, check if it has S1
        JEQ       end_of_button_ISR                ; if R14 doesnt hold S1 then jump to end of ISR
                                        ; in essence the else if statement, any logic past this has S1 but not S2
;* ---------------
        MOV.B     &current_task,r15     ; move the current_task to R15
        TST.W     r15                   ; compare the R15 register with 0, i.e. test if current_task == 0
        JEQ       idle_to_normal                ; jump to idle_to_normal if current task = IDLE && S1 event

;* ---------------
        SUB.W     #1,r15                ; test if R15 is 1 (NORMAL)
        JEQ       exit_normal                ; jump if R15 is current task = NORMAL
                                        ; note that R15 now holds 1 if case is emergency (2 - 1 = 1)
                                        ; holds 0 if case was normal
;* ---------------
        SUB.W     #1,r15                ; test if R15 == 1, i.e. if it has an emergency case
        JNE       end_of_S1_case                ; if R15 != 0 then current task was neither 0, 1, or 2; jump to end of ISR
                                        ; if R15 == 0 then current task was EMERGENCY and fall through to below

;* normal button press : emergency active
        NOP                             ; recommended NOP before EINT
        EINT                            ; enable interrupts
        NOP                             ; recommended NOP after EINT
        MOV.W     #string1,r12          ; move string to be printed for beginning of logging "[ "
        CALLA     #printstr             ; call printstr function, R12 is the register used for printing

        MOV.W     #time,r12             ; move time string into R12
        CALLA     #convert_timer        ; call convert timer function to fetch the latest timestamp

        MOV.W     #time,r12             ; move time string into R12 (redundant i think)
        CALLA     #printstr             ; call printstr function, prints the timestamp

        MOV.W     #string3,r12          ; move string to be printed for normal button during emergency
        CALLA     #printstr             ; call printstr function, prints the normal button during emergency string

        NOP                             ; recommended NOP before DINT
        DINT                            ; disable interrupts
        NOP                             ; recommended NOP after DINT
        JMP       end_of_S1_case                ; jump to end of S1 case

;* normal button press : normal active
exit_normal:
        AND.W     #65487,&TA1CTL        ; turn off TA1, 65487 = ~MC_3
        AND.W     #65519,&TA1CCTL0      ; turn off TA1CCR0 interrupts, 65519 = ~CCIE
        BIS.W     #4,&TA1CTL            ; reset TA1R
        MOV.B     #0,&current_task      ; set current task to IDLE
        MOV.W     #0,&TA1CCR0           ; reset TA1CCR0 to a known state
        AND.W     #65520,&PJOUT         ; turn off all LEDs on port J lower bits
        NOP                             ; recommended NOP before EINT
        EINT                            ; enable interrupts
        NOP                             ; recommended NOP after EINT
        MOV.W     #string1,r12          ; move string to be printed for beginning of logging "[ "
        CALLA     #printstr             ; call printstr function, R12 is the register used for printing

        MOV.W     #time,r12             ; move time string into R12
        CALLA     #convert_timer        ; call convert timer function to fetch the latest timestamp

        MOV.W     #time,r12             ; move time string into R12
        CALLA     #printstr             ; call printstr function, prints the timestamp

        MOV.W     #string4,r12          ; move string to be printed for normal button during normal
        CALLA     #printstr             ; call printstr function, prints the normal button during normal string

        NOP                             ; recommended NOP before DINT
        DINT                            ; disable interrupts
        NOP                             ; recommended NOP after DINT
        JMP       end_of_S1_case                ; jump to end of S1 case

;* normal button press : sitting in idle
idle_to_normal:
        AND.W     #65487,&TA1CTL        ; turn off TA1, 65487 = ~MC_3
        AND.W     #65519,&TA1CCTL0      ; disable TA1CCR0 interrupts, 65519 = ~CCIE
        BIS.W     #4,&TA1CTL            ; reset TA1R
        MOV.B     #1,&current_task      ; set the current task to normal
        MOV.W     #614,&TA1CCR0       ; load normal interrupt time into capture/compare [IMPORTANT CHANGE TO 2458 ON WORKING XT1]
        BIC.W     #1,&TA1CCTL0          ; clear any pending interrupt flag
        BIS.W     #16,&TA1CCTL0         ; enable TA1CCR0 interrupts
        BIS.W     #16,&TA1CTL           ; turn on TA1
        MOV.W     #1,&PJOUT             ; turn on LED1
        MOV.B     #1,&S1_LED_state      ; set the LED state to 1, state 1 is with LED1 on
        NOP                             ; recommended NOP before EINT
        EINT                            ; enable interrupt
        NOP                             ; recommended NOP after EINT
        MOV.W     #string1,r12          ; move string to be printed for beginning of logging "[ "
        CALLA     #printstr             ; call printstr function, R12 is the register used for printing

        MOV.W     #time,r12             ; move time string into R12
        CALLA     #convert_timer        ; call convert timer function to fetch the latest timestamp

        MOV.W     #time,r12             ; move time string into R12
        CALLA     #printstr             ; call printstr function, prints the timestamp

        MOV.W     #string5,r12          ; move string to be printed for normal button during idle
        CALLA     #printstr             ; call printstr function, prints the normal button during idle string

        NOP                             ; recommended NOP before DINT
        DINT                            ; disable interrupts
        NOP                             ; recommended NOP after disable interrupts

;* end of S1 case
end_of_S1_case:
        BIC.B     #1,&P4IFG             ; clear any S1 interrupt flag
        JMP       end_of_button_ISR                ; jump to end of ISR

;* emergency (S2) case
S2_event:
        MOV.B     &current_task,r15     ;
        TST.W     r15                   ; test to see if current task == 0
        JEQ       idle_to_emerg                ; if in IDLE jump to idle_to_emerg; idle -> emergency

;* ---------------
        SUB.W     #1,r15                ; subtract 1 from R15, if in normal now R15 = 0
        JEQ       normal_to_emerg                ; if in normal op jump to normal_to_emerg; normal -> emergency

;* ---------------
        SUB.W     #1,r15                ; subtract 1 from R15, if in emergency now R15 = 0
        JNE       end_of_S2_case                ; if not in emergency jump to end of emergency case

;* emergency button press : emergency active
        TST.B     &normal_suspended     ; check if a normal suspend holds value of 0
        JNE       emerg_normal_sus                ; if normal suspend == 1 then jump to emerg_normal_sus

;* emergency button press : emergency active ; normal call not suspended
        AND.W     #65487,&TA1CTL        ; turn off TA1, 65487 = ~MC_3
        AND.W     #65519,&TA1CCTL0      ; disable TA1CCR0 interrupts, 65519 = ~CCIE
        BIS.W     #4,&TA1CTL            ; reset TA1R
        MOV.B     #0,&current_task      ; set current task to IDLE
        MOV.W     #0,&TA1CCR0           ; reset TA1CCR0 to a known value
        AND.B     #15,&P3OUT            ; turn of port 3 LEDs
        NOP                             ; recommended NOP before EINT
        EINT                            ; enable interrupts
        NOP                             ; recommended NOP after EINT
        MOV.W     #string1,r12          ; move string to be printed for beginning of logging "[ "
        CALLA     #printstr             ; call printstr function, R12 is the register used for printing

        MOV.W     #time,r12             ; move time string into R12
        CALLA     #convert_timer        ; call convert timer function to fetch the latest timestamp

        MOV.W     #time,r12             ; move time string into R12
        CALLA     #printstr             ; call printstr function, prints the timestamp

        MOV.W     #string6,r12          ; move string to be printed for emergency button during emergency and normal not suspended
        CALLA     #printstr             ; call printstr function, prints the emergency button during emergency and normal not suspended

        NOP                             ; recommended NOP before DINT
        DINT                            ; disable interrupts 
        NOP                             ; recommended NOP after DINT
        JMP       end_of_S2_case                ; jump to end of S2 case

;* emergency button press : emergency active ; normal call suspended
emerg_normal_sus:    
        AND.W     #65487,&TA1CTL                ; turn off TA1, 65487 = ~MC_3
        AND.W     #65519,&TA1CCTL0              ; disable TA1CCR0 interrupts, 65519 = ~CCIE
        BIS.W     #4,&TA1CTL                    ; reset TA1R
        MOV.B     #1,&current_task              ; change current task to NORMAL
        MOV.B     #0,&normal_suspended          ; clear the normal suspended variable
        MOV.W     #614,&TA1CCR0               ; load normal count up into TA1CCR0 [IMPORTANT CHANGE TO 2458 ON WORKING XT1]
        MOV.W     &normal_timer_mem,&TA1R       ; load the stored remembered count up time into TA1R
        BIC.W     #1,&TA1CCTL0                  ; reset any pending interrupt flags from TA1CCR0
        BIS.W     #16,&TA1CCTL0                 ; turn on TA1CCR0 interrupts
        BIS.W     #16,&TA1CTL                   ; turn on TA1
        AND.B     #15,&P3OUT                    ; turn of emergency LEDs 15 = 0x0F
        NOP                                     ; recommended NOP before EINT
        EINT                                    ; enable interrupts
        NOP                                     ; recommended NOP after EINT
        MOV.W     #string1,r12                  ; move string to be printed for beginning of logging "[ "
        CALLA     #printstr                     ; call printstr function, R12 is the register used for printing

        MOV.W     #time,r12                     ; move time string into R12
        CALLA     #convert_timer                ; call convert timer function to fetch the latest timestamp

        MOV.W     #time,r12                     ; move time string into R12
        CALLA     #printstr                     ; call printstr function, prints the timestamp

        MOV.W     #string7,r12                  ; move string to be printed for emergency button during emergency and normal suspended
        CALLA     #printstr                     ; call printstr function, prints the emergency button during emergency and normal suspended

        NOP                                     ; recommended NOP before DINT
        DINT                                    ; disable interrupts
        NOP                                     ; recommended NOP after DINT
        JMP       end_of_S2_case                        ; jump to end of S2 case

;* emergency button press : normal active
normal_to_emerg:
        AND.W     #65487,&TA1CTL                ; turn off TA1, 65487 = ~MC_3
        MOV.W     &TA1R,&normal_timer_mem       ; record the stopped normal timer value
        AND.W     #65519,&TA1CCTL0              ; disable TA1CCR0 interrupts, 65519 = ~CCIE
        BIS.W     #4,&TA1CTL                    ; reset TA1R
        MOV.B     #1,&normal_suspended          ; set the normal suspended variable
        MOV.B     #2,&current_task              ; set the current task to EMERGENCY
        MOV.W     #153,&TA1CCR0               ; load emergency interrupt time into capture/compare [IMPORTANT CHANGE TO 615 ON WORKING XT1]
        BIC.W     #1,&TA1CCTL0                  ; clear pending TA1CCR0 interrupts
        BIS.W     #16,&TA1CCTL0                 ; enable TA1CCR0 interrupts
        BIS.W     #16,&TA1CTL                   ; turn on TA1
        BIS.B     #240,&P3OUT                 ; turn on emergency LEDs
        NOP                                     ; recommended NOP before EINT
        EINT                                    ; enable interrupts
        NOP                                     ; recommended NOP after EINT
        MOV.W     #string1,r12                  ; move string to be printed for beginning of logging "[ "
        CALLA     #printstr                     ; call printstr function, R12 is the register used for printing

        MOV.W     #time,r12                     ; move time string into R12
        CALLA     #convert_timer                ; call convert timer function to fetch the latest timestamp

        MOV.W     #time,r12                     ; move time string into R12
        CALLA     #printstr                     ; call printstr function, prints the timestamp

        MOV.W     #string8,r12                  ; move string to be printed for emergency button during normal
        CALLA     #printstr                     ; call printstr function, prints the emergency button during normal

        NOP                                     ; recommended NOP before DINT
        DINT                                    ; disable interrupts
        NOP                                     ; recommended NOP after DINT
        JMP       end_of_S2_case                        ; jump to end of S2 case

;* emergency button press : sitting in idle
idle_to_emerg:    
        AND.W     #65487,&TA1CTL        ; turn off TA1, 65487 = ~MC_3
        AND.W     #65519,&TA1CCTL0      ; disable TA1CCR0 interrupts, 65519 = ~CCIE
        BIS.W     #4,&TA1CTL            ; reset TA1R
        MOV.B     #2,&current_task      ; set the current task to EMERGENCY
        MOV.W     #153,&TA1CCR0       ; load emergency interrupt time into capture/compare [IMPORTANT CHANGE TO 615 ON WORKING XT1]
        BIC.W     #1,&TA1CCTL0          ; clear pending TA1CCR0 interrupts
        BIS.W     #16,&TA1CCTL0         ; enable TA1CCR0 interrupts
        BIS.W     #16,&TA1CTL           ; turn on TA1
        BIS.B     #240,&P3OUT         ; toggle LEDs to on
        NOP                             ; recommended NOP before EINT
        EINT                            ; enable interrupts
        NOP                             ; recommended NOP after EINT
        MOV.W     #string1,r12          ; move string to be printed for beginning of logging "[ "
        CALLA     #printstr             ; call printstr function, R12 is the register used for printing

        MOV.W     #time,r12             ; move time string into R12
        CALLA     #convert_timer        ; call convert timer function to fetch the latest timestamp

        MOV.W     #time,r12             ; move time string into R12
        CALLA     #printstr             ; call printstr function, prints the timestamp

        MOV.W     #string9,r12          ; move string to be printed for emergency button during idle
        CALLA     #printstr             ; call printstr function, prints the emergency button during idle

        NOP                             ; recommended NOP before DINT
        DINT                            ; disable interrupts
        NOP                             ; recommended NOP after DINT

;* end of S2 case
end_of_S2_case:    
        AND.B     #252,&P4IFG         ; clear S1 and S2 pending interrupt flags

;* end of button ISR
end_of_button_ISR:    
        BIS.B     #3,&P4IE              ; enable button interrupts
        POPM.A    #5,r15                ; retrieve the saved register values from the stack
        RETI                            ; return from interrupt

	.sect	".text:_isr:UART_ISR"
	.clink
	.global	UART_ISR
;* --------------------------------------------------------------------------*

; ISR for UART
UART_ISR:
        PUSHM.A   #1,r15                ; Saves r15 onto stack
        MOV.B     &print_idx,r15      ; Sets print index
        ADD.W     &print_str,r15      ; Sets address of character
        TST.B     0(r15)                ; Compares character to null terminaotr 
        JNE       Print_Iter                
;* ---------------
        BIC.W     #2,&UCA0IE          ; Stops Tx interrupts
        BIC.W     #16,4(SP)             ; Exits LPM0
        JMP       Print_End             
                                        
Print_Iter:    
        MOV.B     &print_idx,r15      ; Reloads current index
        ADD.W     &print_str,r15      ; Sets address of character
        MOV.B     @r15,r15              ; Loads the character itself
        MOV.W     r15,&UCA0TXBUF      ; Writes character to Tx buffer
        ADD.B     #1,&print_idx       ; Increments index

Print_End:    
        POPM.A    #1,r15                ; Restores r15
        RETI

	.sect	".text:_isr:Timer0_ISR"
	.clink
	.global	Timer0_ISR
;* --------------------------------------------------------------------------*

; Timer 0 ISR
Timer0_ISR:
        ADD.W     #1,&sys_timer_overflow ; Increments system timer overflows
        BIC.W     #1,&TA0CCTL0        ; Clears CCIFG flag for channel 0
        RETI      

;* --------------------------------------------------------------------------*

; Declaring Strings
	.sect	".const:.string"
	.align	2
string1:	.string	"[ ",0
	.align	2
string2:	.string	" ms ] EXITING STARTUP -> ENTERING IDLE",10,13,0
	.align	2
string3:	.string	" ms ] S1 -> NORMAL CALL IGNORED : EMERGENCY CALL ACTIVE",10
	.string	13,0
	.align	2
string4:	.string	" ms ] S1 -> NORMAL CALL COMPLETE",10,13,0
	.align	2
string5:	.string	" ms ] S1 -> NORMAL CALL : EXIT IDLE",10,13,0
	.align	2
string6:	.string	" ms ] S2 -> EMERGENCY CALL COMPLETE",10,13,0
	.align	2
string7:	.string	" ms ] S2 -> EXIT EMERGENCY CALL : RESUME NORMAL CALL",10,13
	.string	0
	.align	2
string8:	.string	" ms ] S2 -> EMERGENCY CALL : SUSPEND NORMAL CALL",10,13,0
	.align	2
string9:	.string	" ms ] S2 -> EMERGENCY CALL : EXIT IDLE",10,13,0
;* --------------------------------------------------------------------------*


;*****************************************************************************
;* UNDEFINED EXTERNAL REFERENCES                                             *
;*****************************************************************************
	.global	CSCTL0_H
	.global	CSCTL2
	.global	CSCTL3
	.global	CSCTL4
	.global	CSCTL5
	.global	PASEL1_H
	.global	PBOUT_L
	.global	PBOUT_H
	.global	PBDIR_L
	.global	PBDIR_H
	.global	PBREN_H
	.global	PBIES_H
	.global	PBIE_H
	.global	PBIFG_H
	.global	PJOUT
	.global	PJDIR
	.global	SFRIFG1
	.global	TA0CTL
	.global	TA0CCTL0
	.global	TA0CCTL1
	.global	TA0R
	.global	TA0CCR0
	.global	TA0CCR1
	.global	TA1CTL
	.global	TA1CCTL0
	.global	TA1R
	.global	TA1CCR0
	.global	UCA0CTLW0_L
	.global	UCA0BRW
	.global	UCA0MCTLW
	.global	UCA0TXBUF
	.global	UCA0IE
	.global	WDTCTL
	.global	__mspabi_mpyl
	.global	__mspabi_srll_12
	.global	__mspabi_remul
	.global	__mspabi_divul