
;	Interrupt vector table mappings
	.intvec	".int32",	button_ISR
	.intvec	".int41",	timer1_ISR
	.intvec	".int45",	Timer0_ISR
	.intvec	".int44",	timer0_A1_ISR
	.intvec	".int48",	UART_ISR
	.global	current_task
	.data
	.align	1
	.elfsym	current_task,SYM_SIZE(1)

current_task:
	.bits		0,8
			; current_task @ 0

	.global	normal_suspended
	.data
	.align	1
	.elfsym	normal_suspended,SYM_SIZE(1)

normal_suspended:
	.bits		0,8
			; normal_suspended @ 0

	.global	normal_timer_mem
	.data
	.align	2
	.elfsym	normal_timer_mem,SYM_SIZE(2)

normal_timer_mem:
	.bits		0,16
			; normal_timer_mem @ 0

	.global	S1_LED_state
	.data
	.align	1
	.elfsym	S1_LED_state,SYM_SIZE(1)

S1_LED_state:
	.bits		0,8
			; S1_LED_state @ 0

	.global	sys_timer_overflow
	.data
	.align	2
	.elfsym	sys_timer_overflow,SYM_SIZE(2)

sys_timer_overflow:
	.bits		0,16
			; sys_timer_overflow @ 0

	.global	time
	.sect	".data:time", RW
	.align	2
	.elfsym	time,SYM_SIZE(12)

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
	.elfsym	print_idx,SYM_SIZE(1)

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
        CMP.B     #1,&current_task+0    ; Checks if current task is NORMAL (1)
        JEQ       Emergency_Running     ; Jumps to required statement

; ----------------
        CMP.B     #2,&current_task+0    ; Checks if current task is emergency (2) 
        JEQ       Normal_Running        ; [] |513| 
                                        
; ----------------
        NOP                             ; End of if statement
        JMP       End_Running          ;
                                        
; ----------------
Emergency_Running:    
        XOR.B     #240,&PBOUT_L+0     ; Activates all LEDs
        JMP       End_Running                 
                                        
;* ---------------
Normal_Running:    
        MOV.B     &S1_LED_state+0,r15   ; Moves LED_State into r15
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
        AND.W     #65520,&PJOUT+0       ; Sets all LEDs off
        MOV.B     #0,&S1_LED_state+0    ; Sets state to 0
        JMP       End_Running           

Case_8:    
        MOV.W     #8,&PJOUT+0           ; Activates LED 4 
        MOV.B     #0,&S1_LED_state+0    ; Increments LED state 
        JMP       End_Running            

Case_4:    
        MOV.W     #4,&PJOUT+0           ; Activates LED 3 
        ADD.B     #1,&S1_LED_state+0    ; Increments LED state 
        JMP       End_Running            

Case_2:    
        MOV.W     #2,&PJOUT+0           ; Activates LED 2
        ADD.B     #1,&S1_LED_state+0    ; Increments LED state  
        JMP       End_Running            

Case_1:    
        MOV.W     #1,&PJOUT+0           ; Activates LED 1
        ADD.B     #1,&S1_LED_state+0    ; Increments LED state 

End_Running:    
        BIC.W     #1,&TA1CCTL0+0        ; Sets Timer 1 control register to inverse of CCIF6 
        POPM.A    #1,r15                
        RETI      

	.sect	".text:_isr:timer0_A1_ISR"
	.clink
	.global	timer0_A1_ISR
;* --------------------------------------------------------------------------*


; Timer 0 A1 ISR
timer0_A1_ISR:
        BIC.W     #16,0(SP)             ; Clears bits in status register. Exits LPM0
        BIC.W     #1,&TA0CCTL1+0        ; Sets bit zero to 0
        RETI      

	.sect	".text:printstr"
	.clink
	.global	printstr
;* --------------------------------------------------------------------------*

; Function for printing string to serial terminal through UART
printstr:
        MOV.W     r12,&print_str+0      ; Set variable print_str equal to string to be printed
        MOV.B     #0,&print_idx+0       ; Sets print_index to 0 
        ; Moves current character to transmit buffer
        MOV.B     &print_idx+0,r15      ; Loads current index into memory
        ADD.W     &print_str+0,r15      ; Loads the address of the character
        MOV.B     @r15,r15              ; Loads the character
        MOV.W     r15,&UCA0TXBUF+0      ; Writes character to transmit buffer

        ADD.B     #1,&print_idx+0       ; Increments index
        OR.W      #2,&UCA0IE+0          ; Sets transmit enable bit in USCI A0 enable register
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
        MOV.W     #23168,&WDTCTL+0      ; Pauses WDT
        MOV.W     #0,&TA0CTL+0          ; Clears Timer A0 control register
        MOV.W     #0,&TA1CTL+0          ; Clears Timer A1 control register
        MOV.W     #1,&PJDIR+0           ; Sets LED1 as an output
        MOV.B     #165,&CSCTL0_H+0    ; Unlocks CS
        BIC.W     #1,&CSCTL4+0          ; Turns on XT1
        AND.W     #63624,&CSCTL2+0      ; ANDS clock source select bits to 0
        MOV.W     #51,&CSCTL2+0         ; ALCK source is XT1CLK ~32769 Hz
        AND.W     #63743,&CSCTL3+0      ; Alck Input divider /1
        AND.W     #65343,&CSCTL4+0      ; ANDS to negated XT1DRIVE_3
        AND.W     #65503,&CSCTL4+0      ; ANDS to negated xts
        OR.W      #64,&CSCTL5+0         ; ORs with ENSTFCNT1
;* --------------------------------------------------------------------------*

initial_loop:    
        BIC.W     #1,&CSCTL5+0          ; Clears using negated XT1OFFG
        BIC.W     #2,&SFRIFG1+0         ; Clears with negated OFIFG
        XOR.W     #1,&PJOUT+0           ; Toggles LED1
        BIT.W     #2,&SFRIFG1+0         ; 
        JNE       initial_loop                 

;* ---------------

        MOV.B     #0,&CSCTL0_H+0        ; Sets to 0
        MOV.W     #0,&PJOUT+0           ; Sets LED1-4 off

        ; Timer 0 config
        AND.W     #65487,&TA0CTL+0      ; Turns off timer to give a stable config
        OR.W      #256,&TA0CTL+0      ; ALCK
        OR.W      #192,&TA0CTL+0      ; 8 -> 4096 Hz
        OR.W      #4,&TA0CTL+0          ; Clears TAOR so it starts from a known
        MOV.W     #15359,&TA0CCR0+0     ; Timer overflows at 15 sec
        AND.W     #16127,&TA0CCTL0+0    ; No capture mode
        OR.W      #16,&TA0CCTL0+0       ; Enables interrupts
        AND.W     #16127,&TA0CCTL1+0    ; Turns timers on
        OR.W      #16,&TA0CTL+0         ; Sets timer to up mode 

        ; Timer 1 config
        AND.W     #65487,&TA1CTL+0      ; Turns timer off for stable config
        OR.W      #256,&TA1CTL+0      ; ALCK
        OR.W      #192,&TA1CTL+0      ; 8 -> 4096 Hz
        OR.W      #4,&TA1CTL+0          ; Clears TAOR so it starts from a known
        AND.W     #16127,&TA1CCTL0+0    ; No capture mode

        ; GPIO configs 
        MOV.W     #15,&PJDIR+0          ; Sets upper nibble of PJ as output
        MOV.B     #240,&PBDIR_L+0     ; Sets lower nibble fo P3 (PB_L) as output
        MOV.B     #0,&PBDIR_H+0         ; Sets P4 (PB_H) as input

        ; Enables pull up on buttons for active low
        OR.B      #3,&PBREN_H+0          
        OR.B      #3,&PBOUT_H+0         

        ; Interrupts occurs on high to low
        OR.B      #3,&PBIES_H+0         

        ; Clears existing interrupt flags 
        AND.B     #252,&PBIFG_H+0     

        ; Resets LEDs 1-8 to knowns 
        AND.W     #65520,&PJOUT+0        
        AND.B     #15,&PBOUT_L+0        

        ; Sets UART
        ; 9600 baud from 1MHz DCO CLK 
        MOV.B     #3,&PASEL1_H+0         
        MOV.B     #129,&UCA0CTLW0_L+0 
        MOV.W     #6,&UCA0BRW+0         
        MOV.W     #8321,&UCA0MCTLW+0   
        BIC.B     #1,&UCA0CTLW0_L+0    

        ; Enables button interrupts 
        OR.B      #3,&PBIE_H+0      
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
        
        PUSHM.A   #4,r10                ; [] 
        MOVA      r12,r7                ; [] |70| 
        MOV.W     &sys_timer_overflow+0,r12 ; [] |73| 
        MOV.W     #0,r13                ; [] |73| 
        MOV.W     #15000,r14            ; [] |73| 
        MOV.W     #0,r15                ; [] |73| 
        CALLA     #__mspabi_mpyl        ; [] |73| 
                                          ; [] |73| 
        MOVA      r12,r8                ; [] |73| 
        MOVA      r13,r9                ; [] |73| 
        MOV.W     &TA0R+0,r12           ; [] |73| 
        MOV.W     #0,r13                ; [] |73| 
        MOV.W     #1000,r14             ; [] |73| 
        MOV.W     #0,r15                ; [] |73| 
        CALLA     #__mspabi_mpyl        ; [] |73| 
                                          ; [] |73| 
        CALLA     #__mspabi_srll_12     ; [] |73| 
                                          ; [] |73| 
        ADD.W     r12,r8                ; [] |73| 
        ADDC.W    r13,r9                ; [] |73| 
        MOV.W     #0,r10                ; Sets index for loop to 0
        CMP.W     #9,r10                ; Checks if index equals 9
        JGE       conv_timer_end       ; Loops if less than

;* ---------------
conv_timer_loop:    
        MOVA      r8,r12                ; [] |79| 
        MOVA      r9,r13                ; [] |79| 
        MOV.W     #10,r14               ; [] |79| 
        MOV.W     #0,r15                ; [] |79| 
        CALLA     #__mspabi_remul       ; [] |79| 
                                          ; [] |79| 
        ADD.B     #48,r14               ; [] |79| 
        MOVA      r7,r15                ; [] |79| 
        SUB.W     r10,r15               ; [] |79| 
        MOV.B     r14,9(r15)            ; [] |79| 
        MOVA      r8,r12                ; [] |80| 
        MOVA      r9,r13                ; [] |80| 
        MOV.W     #10,r14               ; [] |80| 
        MOV.W     #0,r15                ; [] |80| 
        CALLA     #__mspabi_divul       ; [] |80| 
                                          ; [] |80| 
        MOVA      r12,r8                ; [] |80| 
        MOVA      r13,r9                ; [] |80| 
        ADD.B     #1,r10                ; [] |77| 
        SXT       r10                   ; [] |77| 
        CMP.W     #9,r10                ; [] |77| 
        JL        conv_timer_loop                 ; [] |77| 
                                          ; [] |77| 
;* ---------------
conv_timer_end:    
        POPM.A    #4,r10                ; [] 
        RETA      

	.sect	".text:main"
	.clink
	.global	main
;* --------------------------------------------------------------------------*

; Mainloop
main:
        CALLA     #initial              ; Runs initial
        MOV.W     #string1+0,r12         ; Prints first bracket
        CALLA     #printstr             ;
                                          
        MOV.W     #time+0,r12           ; Converts time to string 
        CALLA     #convert_timer        ; 

        MOV.W     #time+0,r12           ; Prints time
        CALLA     #printstr             ;

        MOV.W     #string2+0,r12         ; Prints End of string
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
        PUSHM.A   #5,r15                ; [] 
        AND.B     #252,&PBIE_H+0        ; [] |189| 
        MOV.B     &PBIFG_H+0,r14        ; [] |192| 
        MOV.W     &TA0R+0,r15           ; [] |202| 
        ADD.W     #120,r15              ; [] |203| 
        MOV.W     r15,&TA0CCR1+0        ; [] |203| 
        CMP.W     &TA0CCR1+0,&TA0CCR0+0 ; [] |204| 
        JHS       Button_Debounce_Done  ; if (TA0CCR1 < TA0CCR0)

;* ---------------
        MOV.W     &TA0CCR1+0,r15        ; [] |206| 
        SUB.W     &TA0CCR0+0,r15        ; [] |206| 
        SUB.W     #1,r15                ; [] |206| 
        MOV.W     r15,&TA0CCR1+0        ; [] |206| 
;* ---------------
Button_Debounce_Done:    
        OR.W      #16,&TA0CCTL1+0       ; [] |208| 
        NOP
        EINT
        NOP      ; [] |209| 
        NOP
        BIS.W    #24,SR
        NOP      ; [] |210| 
        DINT
        NOP      ; [] |211| 
        AND.W     #65519,&TA0CCTL1+0    ; [] |212| 

;* --------------
        BIT.B     #2,r14                ; [] |220| 
        JNE       Current_Task                ; [] |220| 
                                          ; [] |220| 
;* ---------------
        BIT.B     #1,r14                ; [] |385| 
        JEQ       $C$L21                ; [] |385| 
                                          ; [] |385| 
;* ---------------
        MOV.B     &current_task+0,r15   ; [] |385| 
        TST.W     r15                   ; [] |385| 
        JEQ       $C$L14                ; [] |385| 
                                          ; [] |385| 
;* ---------------
        SUB.W     #1,r15                ; [] |385| 
        JEQ       $C$L13                ; [] |385| 
                                          ; [] |385| 
;* ---------------
        SUB.W     #1,r15                ; [] |385| 
        JNE       $C$L15                ; [] |385| 
                                          ; [] |385| 
;* ---------------
        NOP       ; [] |455| 
        NOP
        EINT
        NOP      ; [] |461| 
        MOV.W     #string1+0,r12         ; [] |462| 
        CALLA     #printstr             ; [] |462| 
                                          ; [] |462| 
        MOV.W     #time+0,r12           ; [] |463| 
        CALLA     #convert_timer        ; [] |463| 
                                          ; [] |463| 
        MOV.W     #time+0,r12           ; [] |464| 
        CALLA     #printstr             ; [] |464| 
                                          ; [] |464| 
        MOV.W     #string3+0,r12         ; [] |465| 
        CALLA     #printstr             ; [] |465| 
                                          ; [] |465| 
        DINT
        NOP      ; [] |466| 
        JMP       $C$L15                ; [] |468| 
                                          ; [] |468| 
;* --------------
$C$L13:    
        AND.W     #65487,&TA1CTL+0      ; [] |427| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |430| 
        OR.W      #4,&TA1CTL+0          ; [] |433| 
        MOV.B     #0,&current_task+0    ; [] |436| 
        MOV.W     #0,&TA1CCR0+0         ; [] |439| 
        AND.W     #65520,&PJOUT+0       ; [] |442| 
        NOP
        EINT
        NOP      ; [] |445| 
        MOV.W     #string1+0,r12         ; [] |446| 
        CALLA     #printstr             ; [] |446| 
                                          ; [] |446| 
        MOV.W     #time+0,r12           ; [] |447| 
        CALLA     #convert_timer        ; [] |447| 
                                          ; [] |447| 
        MOV.W     #time+0,r12           ; [] |448| 
        CALLA     #printstr             ; [] |448| 
                                          ; [] |448| 
        MOV.W     #string4+0,r12         ; [] |449| 
        CALLA     #printstr             ; [] |449| 
                                          ; [] |449| 
        DINT
        NOP      ; [] |450| 
        JMP       $C$L15                ; [] |452| 
                                          ; [] |452| 
;* --------------
$C$L14:    
        AND.W     #65487,&TA1CTL+0      ; [] |390| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |393| 
        OR.W      #4,&TA1CTL+0          ; [] |396| 
        MOV.B     #1,&current_task+0    ; [] |399| 
        MOV.W     #614,&TA1CCR0+0       ; [] |402| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |405| 
        OR.W      #16,&TA1CCTL0+0       ; [] |406| 
        OR.W      #16,&TA1CTL+0         ; [] |409| 
        MOV.W     #1,&PJOUT+0           ; [] |412| 
        MOV.B     #1,&S1_LED_state+0    ; [] |413| 
        NOP
        EINT
        NOP      ; [] |416| 
        MOV.W     #string1+0,r12         ; [] |417| 
        CALLA     #printstr             ; [] |417| 
                                          ; [] |417| 
        MOV.W     #time+0,r12           ; [] |418| 
        CALLA     #convert_timer        ; [] |418| 
                                          ; [] |418| 
        MOV.W     #time+0,r12           ; [] |419| 
        CALLA     #printstr             ; [] |419| 
                                          ; [] |419| 
        MOV.W     #string5+0,r12         ; [] |420| 
        CALLA     #printstr             ; [] |420| 
                                          ; [] |420| 
        DINT
        NOP      ; [] |421| 
;* ---------------
$C$L15:    
        BIC.B     #1,&PBIFG_H+0         ; [] |474| 
        JMP       $C$L21                ; [] |474| 
                                          ; [] |474| 
;* ---------------
Current_Task:    
        MOV.B     &current_task+0,r15   ; [] |220| 
        TST.W     r15                   ; [] |220| 
        JEQ       Normal_Idle                ; [] |220| 
                                          ; [] |220| 
;* ---------------
        SUB.W     #1,r15                ; [] |220| 
        JEQ       Normal                ; [] |220| 
                                          ; [] |220| 
;* ---------------
        SUB.W     #1,r15                ; [] |220| 
        JNE       $C$L20                ; [] |220| 
                                          ; [] |220| 
;* ---------------
        TST.B     &normal_suspended+0   ; [] |262| 
        JNE       Emegency_Normal_Suspended                ; [] |262| 
                                          ; [] |262| 
;* ---------------
        AND.W     #65487,&TA1CTL+0      ; [] |306| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |309| 
        OR.W      #4,&TA1CTL+0          ; [] |312| 
        MOV.B     #0,&current_task+0    ; [] |315| 
        MOV.W     #0,&TA1CCR0+0         ; [] |317| 
        AND.B     #15,&PBOUT_L+0        ; [] |320| 
        NOP
        EINT
        NOP      ; [] |323| 
        MOV.W     #string1+0,r12         ; [] |324| 
        CALLA     #printstr             ; [] |324| 
                                          ; [] |324| 
        MOV.W     #time+0,r12           ; [] |325| 
        CALLA     #convert_timer        ; [] |325| 
                                          ; [] |325| 
        MOV.W     #time+0,r12           ; [] |326| 
        CALLA     #printstr             ; [] |326| 
                                          ; [] |326| 
        MOV.W     #string6+0,r12         ; [] |327| 
        CALLA     #printstr             ; [] |327| 
                                          ; [] |327| 
        DINT
        NOP      ; [] |328| 
        JMP       $C$L20                ; [] |328| 
                                          ; [] |328| 
;* --------------
Emegency_Normal_Suspended:    
        AND.W     #65487,&TA1CTL+0      ; [] |265| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |268| 
        OR.W      #4,&TA1CTL+0          ; [] |271| 
        MOV.B     #1,&current_task+0    ; [] |274| 
        MOV.B     #0,&normal_suspended+0 ; [] |276| 
        MOV.W     #614,&TA1CCR0+0       ; [] |279| 
        MOV.W     &normal_timer_mem+0,&TA1R+0 ; [] |282| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |285| 
        OR.W      #16,&TA1CCTL0+0       ; [] |286| 
        OR.W      #16,&TA1CTL+0         ; [] |289| 
        AND.B     #15,&PBOUT_L+0        ; [] |292| 
        NOP
        EINT
        NOP      ; [] |295| 
        MOV.W     #string1+0,r12         ; [] |296| 
        CALLA     #printstr             ; [] |296| 
                                          ; [] |296| 
        MOV.W     #time+0,r12           ; [] |297| 
        CALLA     #convert_timer        ; [] |297| 
                                          ; [] |297| 
        MOV.W     #time+0,r12           ; [] |298| 
        CALLA     #printstr             ; [] |298| 
                                          ; [] |298| 
        MOV.W     #string7+0,r12         ; [] |299| 
        CALLA     #printstr             ; [] |299| 
                                          ; [] |299| 
        DINT
        NOP      ; [] |300| 
        JMP       $C$L20                ; [] 
                                          ; [] 
;* --------------
Normal:    
        AND.W     #65487,&TA1CTL+0      ; [] |336| 
        MOV.W     &TA1R+0,&normal_timer_mem+0 ; [] |339| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |342| 
        OR.W      #4,&TA1CTL+0          ; [] |345| 
        MOV.B     #1,&normal_suspended+0 ; [] |348| 
        MOV.B     #2,&current_task+0    ; [] |349| 
        MOV.W     #153,&TA1CCR0+0       ; [] |352| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |355| 
        OR.W      #16,&TA1CCTL0+0       ; [] |356| 
        OR.W      #16,&TA1CTL+0         ; [] |359| 
        OR.B      #240,&PBOUT_L+0       ; [] |362| 
        NOP
        EINT
        NOP      ; [] |365| 
        MOV.W     #string1+0,r12         ; [] |366| 
        CALLA     #printstr             ; [] |366| 
                                          ; [] |366| 
        MOV.W     #time+0,r12           ; [] |367| 
        CALLA     #convert_timer        ; [] |367| 
                                          ; [] |367| 
        MOV.W     #time+0,r12           ; [] |368| 
        CALLA     #printstr             ; [] |368| 
                                          ; [] |368| 
        MOV.W     #string8+0,r12         ; [] |369| 
        CALLA     #printstr             ; [] |369| 
                                          ; [] |369| 
        DINT
        NOP      ; [] |370| 
        JMP       $C$L20                ; [] |372| 
                                          ; [] |372| 
;* --------------
Normal_Idle:    
        AND.W     #65487,&TA1CTL+0      ; [] |225| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |228| 
        OR.W      #4,&TA1CTL+0          ; [] |231| 
        MOV.B     #2,&current_task+0    ; [] |234| 
        MOV.W     #153,&TA1CCR0+0       ; [] |237| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |241| 
        OR.W      #16,&TA1CCTL0+0       ; [] |242| 
        OR.W      #16,&TA1CTL+0         ; [] |245| 
        OR.B      #240,&PBOUT_L+0       ; [] |248| 
        NOP
        EINT
        NOP      ; [] |251| 
        MOV.W     #string1+0,r12         ; [] |252| 
        CALLA     #printstr             ; [] |252| 
                                          ; [] |252| 
        MOV.W     #time+0,r12           ; [] |253| 
        CALLA     #convert_timer        ; [] |253| 
                                          ; [] |253| 
        MOV.W     #time+0,r12           ; [] |254| 
        CALLA     #printstr             ; [] |254| 
                                          ; [] |254| 
        MOV.W     #string9+0,r12         ; [] |255| 
        CALLA     #printstr             ; [] |255| 
                                          ; [] |255| 
        DINT
        NOP      ; [] |256| 
;* ---------------
$C$L20:    
        AND.B     #252,&PBIFG_H+0       ; [] |379| 
;* ---------------
$C$L21:    
        OR.B      #3,&PBIE_H+0          ; [] |479| 
        POPM.A    #5,r15                ; [] 
        RETI      ; [] 
        ; [] 
	.sect	".text:_isr:UART_ISR"
	.clink
	.global	UART_ISR
;* --------------------------------------------------------------------------*

; ISR for UART
UART_ISR:
        PUSHM.A   #1,r15                ; Saves r15 onto stack
        MOV.B     &print_idx+0,r15      ; Sets print index
        ADD.W     &print_str+0,r15      ; Sets address of character
        TST.B     0(r15)                ; Compares character to null terminaotr 
        JNE       Print_Iter                
;* ---------------
        BIC.W     #2,&UCA0IE+0          ; Stops Tx interrupts
        BIC.W     #16,4(SP)             ; Exits LPM0
        JMP       Print_End             
                                        
Print_Iter:    
        MOV.B     &print_idx+0,r15      ; Reloads current index
        ADD.W     &print_str+0,r15      ; Sets address of character
        MOV.B     @r15,r15              ; Loads the character itself
        MOV.W     r15,&UCA0TXBUF+0      ; Writes character to Tx buffer
        ADD.B     #1,&print_idx+0       ; Increments index

Print_End:    
        POPM.A    #1,r15                ; Restores r15
        RETI      

	.sect	".text:_isr:Timer0_ISR"
	.clink
	.global	Timer0_ISR
;* --------------------------------------------------------------------------*

; Timer 0 ISR
Timer0_ISR:
        ADD.W     #1,&sys_timer_overflow+0 ; Increments system timer overflows
        BIC.W     #1,&TA0CCTL0+0        ; Clears CCIFG flag for channel 0
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