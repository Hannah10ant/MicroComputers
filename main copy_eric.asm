;******************************************************************************
;* MSP430 G3 C/C++ Codegen                                              PC v21.6.2.LTS *
;* Date/Time created: Fri Oct  9 12:09:33 2026                                *
;******************************************************************************
	.compiler_opts --abi=eabi --diag_wrap=off --hll_source=on --mem_model:code=large --mem_model:data=small --object_format=elf --silicon_errata=CPU21 --silicon_errata=CPU22 --silicon_errata=CPU40 --silicon_version=mspx --symdebug:none 
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
;	E:\TICCS\ccs\tools\compiler\ti-cgt-msp430_21.6.2.LTS\bin\opt430.exe C:\\Users\\Erik\\AppData\\Local\\Temp\\{02131B0D-4991-42E9-817D-B8D4A3743C2B} C:\\Users\\Erik\\AppData\\Local\\Temp\\{991AB37A-A410-463C-9F1F-B46EA581428A} 
	.sect	".text:_isr:timer1_ISR"
	.clink
	.global	timer1_ISR

;*****************************************************************************
;* FUNCTION NAME: timer1_ISR                                                 *
;*                                                                           *
;*   Regs Modified     : SP,SR,r15                                           *
;*   Regs Used         : SP,SR,r15                                           *
;*   Local Frame Size  : 0 Args + 0 Auto + 4 Save = 4 byte                   *
;*****************************************************************************
timer1_ISR:
;* --------------------------------------------------------------------------*
        PUSHM.A   #1,r15                ; [] 
        CMP.B     #1,&current_task+0    ; [] |497| 
        JEQ       $C$L2                 ; [] |497| 
                                          ; [] |497| 
;* --------------------------------------------------------------------------*
        CMP.B     #2,&current_task+0    ; [] |521| 
        JEQ       $C$L1                 ; [] |521| 
                                          ; [] |521| 
;* --------------------------------------------------------------------------*
        NOP       ; [] |527| 
        JMP       $C$L7                 ; [] |527| 
                                          ; [] |527| 
;* --------------------------------------------------------------------------*
$C$L1:    
        XOR.B     #240,&PBOUT_L+0       ; [] |523| 
        JMP       $C$L7                 ; [] 
                                          ; [] 
;* --------------------------------------------------------------------------*
$C$L2:    
        MOV.B     &S1_LED_state+0,r15   ; [] |497| 
        TST.W     r15                   ; [] |497| 
        JEQ       $C$L6                 ; [] |497| 
                                          ; [] |497| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |497| 
        JEQ       $C$L5                 ; [] |497| 
                                          ; [] |497| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |497| 
        JEQ       $C$L4                 ; [] |497| 
                                          ; [] |497| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |497| 
        JEQ       $C$L3                 ; [] |497| 
                                          ; [] |497| 
;* --------------------------------------------------------------------------*
        AND.W     #65520,&PJOUT+0       ; [] |516| 
        MOV.B     #0,&S1_LED_state+0    ; [] |517| 
        JMP       $C$L7                 ; [] |518| 
                                          ; [] |518| 
;* --------------------------------------------------------------------------*
$C$L3:    
        MOV.W     #8,&PJOUT+0           ; [] |512| 
        MOV.B     #0,&S1_LED_state+0    ; [] |513| 
        JMP       $C$L7                 ; [] |514| 
                                          ; [] |514| 
;* --------------------------------------------------------------------------*
$C$L4:    
        MOV.W     #4,&PJOUT+0           ; [] |508| 
        ADD.B     #1,&S1_LED_state+0    ; [] |509| 
        JMP       $C$L7                 ; [] |510| 
                                          ; [] |510| 
;* --------------------------------------------------------------------------*
$C$L5:    
        MOV.W     #2,&PJOUT+0           ; [] |504| 
        ADD.B     #1,&S1_LED_state+0    ; [] |505| 
        JMP       $C$L7                 ; [] |506| 
                                          ; [] |506| 
;* --------------------------------------------------------------------------*
$C$L6:    
        MOV.W     #1,&PJOUT+0           ; [] |500| 
        ADD.B     #1,&S1_LED_state+0    ; [] |501| 
;* --------------------------------------------------------------------------*
$C$L7:    
        BIC.W     #1,&TA1CCTL0+0        ; [] |530| 
        POPM.A    #1,r15                ; [] 
        RETI      ; [] 
        ; [] 
	.sect	".text:_isr:timer0_A1_ISR"
	.clink
	.global	timer0_A1_ISR

;*****************************************************************************
;* FUNCTION NAME: timer0_A1_ISR                                              *
;*                                                                           *
;*   Regs Modified     : SP                                                  *
;*   Regs Used         : SP                                                  *
;*   Local Frame Size  : 0 Args + 0 Auto + 0 Save = 0 byte                   *
;*****************************************************************************
timer0_A1_ISR:
;* --------------------------------------------------------------------------*
        BIC.W     #16,0(SP)             ; [] |545| 
        BIC.W     #1,&TA0CCTL1+0        ; [] |547| 
        RETI      ; [] 
        ; [] 
	.sect	".text:printstr"
	.clink
	.global	printstr

;*****************************************************************************
;* FUNCTION NAME: printstr                                                   *
;*                                                                           *
;*   Regs Modified     : SP,SR,r15                                           *
;*   Regs Used         : SP,SR,r12,r15                                       *
;*   Local Frame Size  : 0 Args + 0 Auto + 0 Save = 0 byte                   *
;*****************************************************************************
printstr:
;* --------------------------------------------------------------------------*
        MOV.W     r12,&print_str+0      ; [] |58| 
        MOV.B     #0,&print_idx+0       ; [] |59| 
        MOV.B     &print_idx+0,r15      ; [] |61| 
        ADD.W     &print_str+0,r15      ; [] |61| 
        MOV.B     @r15,r15              ; [] |61| 
        MOV.W     r15,&UCA0TXBUF+0      ; [] |61| 
        ADD.B     #1,&print_idx+0       ; [] |62| 
        OR.W      #2,&UCA0IE+0          ; [] |64| 
        NOP
        BIS.W    #24,SR
        NOP      ; [] |66| 
        RETA      ; [] 
        ; [] 
	.sect	".text:initial"
	.clink
	.global	initial

;*****************************************************************************
;* FUNCTION NAME: initial                                                    *
;*                                                                           *
;*   Regs Modified     : SP,SR                                               *
;*   Regs Used         : SP,SR                                               *
;*   Local Frame Size  : 0 Args + 0 Auto + 0 Save = 0 byte                   *
;*****************************************************************************
initial:
;* --------------------------------------------------------------------------*
        MOV.W     #23168,&WDTCTL+0      ; [] |95| 
        MOV.W     #0,&TA0CTL+0          ; [] |97| 
        MOV.W     #0,&TA1CTL+0          ; [] |98| 
        MOV.W     #1,&PJDIR+0           ; [] |100| 
        MOV.B     #165,&CSCTL0_H+0      ; [] |102| 
        BIC.W     #1,&CSCTL4+0          ; [] |103| 
        AND.W     #63624,&CSCTL2+0      ; [] |104| 
        MOV.W     #51,&CSCTL2+0         ; [] |105| 
        AND.W     #63743,&CSCTL3+0      ; [] |106| 
        AND.W     #65343,&CSCTL4+0      ; [] |107| 
        AND.W     #65503,&CSCTL4+0      ; [] |108| 
        OR.W      #64,&CSCTL5+0         ; [] |110| 
;* --------------------------------------------------------------------------*
;*   BEGIN LOOP $C$L8
;*
;*   Loop source line                : 111
;*   Loop closing brace source line  : 116
;*   Known Minimum Trip Count        : 1
;*   Known Maximum Trip Count        : 4294967295
;*   Known Max Trip Count Factor     : 1
;* --------------------------------------------------------------------------*
$C$L8:    
        BIC.W     #1,&CSCTL5+0          ; [] |113| 
        BIC.W     #2,&SFRIFG1+0         ; [] |114| 
        XOR.W     #1,&PJOUT+0           ; [] |115| 
        BIT.W     #2,&SFRIFG1+0         ; [] |116| 
        JNE       $C$L8                 ; [] |116| 
                                          ; [] |116| 
;* --------------------------------------------------------------------------*
        MOV.B     #0,&CSCTL0_H+0        ; [] |117| 
        MOV.W     #0,&PJOUT+0           ; [] |118| 
        AND.W     #65487,&TA0CTL+0      ; [] |121| 
        OR.W      #256,&TA0CTL+0        ; [] |122| 
        OR.W      #192,&TA0CTL+0        ; [] |123| 
        OR.W      #4,&TA0CTL+0          ; [] |124| 
        MOV.W     #15359,&TA0CCR0+0     ; [] |127| 
        AND.W     #16127,&TA0CCTL0+0    ; [] |128| 
        OR.W      #16,&TA0CCTL0+0       ; [] |129| 
        AND.W     #16127,&TA0CCTL1+0    ; [] |131| 
        OR.W      #16,&TA0CTL+0         ; [] |134| 
        AND.W     #65487,&TA1CTL+0      ; [] |137| 
        OR.W      #256,&TA1CTL+0        ; [] |138| 
        OR.W      #192,&TA1CTL+0        ; [] |139| 
        OR.W      #4,&TA1CTL+0          ; [] |140| 
        AND.W     #16127,&TA1CCTL0+0    ; [] |142| 
        MOV.W     #15,&PJDIR+0          ; [] |145| 
        MOV.B     #240,&PBDIR_L+0       ; [] |146| 
        MOV.B     #0,&PBDIR_H+0         ; [] |147| 
        OR.B      #3,&PBREN_H+0         ; [] |150| 
        OR.B      #3,&PBOUT_H+0         ; [] |151| 
        OR.B      #3,&PBIES_H+0         ; [] |154| 
        AND.B     #252,&PBIFG_H+0       ; [] |157| 
        AND.W     #65520,&PJOUT+0       ; [] |160| 
        AND.B     #15,&PBOUT_L+0        ; [] |161| 
        MOV.B     #3,&PASEL1_H+0        ; [] |164| 
        MOV.B     #129,&UCA0CTLW0_L+0   ; [] |165| 
        MOV.W     #6,&UCA0BRW+0         ; [] |166| 
        MOV.W     #8321,&UCA0MCTLW+0    ; [] |167| 
        BIC.B     #1,&UCA0CTLW0_L+0     ; [] |168| 
        OR.B      #3,&PBIE_H+0          ; [] |171| 
        NOP
        BIS.W    #8,SR
        NOP      ; [] |173| 
        RETA      ; [] 
        ; [] 
	.sect	".text:convert_timer"
	.clink
	.global	convert_timer

;*****************************************************************************
;* FUNCTION NAME: convert_timer                                              *
;*                                                                           *
;*   Regs Modified     : SP,SR,r7,r8,r9,r10,r11,r12,r13,r14,r15              *
;*   Regs Used         : SP,SR,r7,r8,r9,r10,r11,r12,r13,r14,r15              *
;*   Local Frame Size  : 0 Args + 0 Auto + 16 Save = 16 byte                 *
;*****************************************************************************
convert_timer:
;* --------------------------------------------------------------------------*
        PUSHM.A   #4,r10                ; [] 
        MOVA      r12,r7                ; [] |78| 
        MOV.W     &sys_timer_overflow+0,r12 ; [] |81| 
        MOV.W     #0,r13                ; [] |81| 
        MOV.W     #15000,r14            ; [] |81| 
        MOV.W     #0,r15                ; [] |81| 
        CALLA     #__mspabi_mpyl        ; [] |81| 
                                          ; [] |81| 
        MOVA      r12,r8                ; [] |81| 
        MOVA      r13,r9                ; [] |81| 
        MOV.W     &TA0R+0,r12           ; [] |81| 
        MOV.W     #0,r13                ; [] |81| 
        MOV.W     #1000,r14             ; [] |81| 
        MOV.W     #0,r15                ; [] |81| 
        CALLA     #__mspabi_mpyl        ; [] |81| 
                                          ; [] |81| 
        CALLA     #__mspabi_srll_12     ; [] |81| 
                                          ; [] |81| 
        ADD.W     r12,r8                ; [] |81| 
        ADDC.W    r13,r9                ; [] |81| 
        MOV.W     #0,r10                ; [] |85| 
        CMP.W     #9,r10                ; [] |85| 
        JGE       $C$L10                ; [] |85| 
                                          ; [] |85| 
;* --------------------------------------------------------------------------*
;*   BEGIN LOOP $C$L9
;*
;*   Loop source line                : 85
;*   Loop closing brace source line  : 89
;*   Known Minimum Trip Count        : 1
;*   Known Maximum Trip Count        : 4294967295
;*   Known Max Trip Count Factor     : 1
;* --------------------------------------------------------------------------*
$C$L9:    
        MOVA      r8,r12                ; [] |87| 
        MOVA      r9,r13                ; [] |87| 
        MOV.W     #10,r14               ; [] |87| 
        MOV.W     #0,r15                ; [] |87| 
        CALLA     #__mspabi_remul       ; [] |87| 
                                          ; [] |87| 
        ADD.B     #48,r14               ; [] |87| 
        MOVA      r7,r15                ; [] |87| 
        SUB.W     r10,r15               ; [] |87| 
        MOV.B     r14,9(r15)            ; [] |87| 
        MOVA      r8,r12                ; [] |88| 
        MOVA      r9,r13                ; [] |88| 
        MOV.W     #10,r14               ; [] |88| 
        MOV.W     #0,r15                ; [] |88| 
        CALLA     #__mspabi_divul       ; [] |88| 
                                          ; [] |88| 
        MOVA      r12,r8                ; [] |88| 
        MOVA      r13,r9                ; [] |88| 
        ADD.B     #1,r10                ; [] |85| 
        SXT       r10                   ; [] |85| 
        CMP.W     #9,r10                ; [] |85| 
        JL        $C$L9                 ; [] |85| 
                                          ; [] |85| 
;* --------------------------------------------------------------------------*
$C$L10:    
        POPM.A    #4,r10                ; [] 
        RETA      ; [] 
        ; [] 
	.sect	".text:main"
	.clink
	.global	main

;*****************************************************************************
;* FUNCTION NAME: main                                                       *
;*                                                                           *
;*   Regs Modified     : SR,r11,r12,r13,r14,r15                              *
;*   Regs Used         : SR,r11,r12,r13,r14,r15                              *
;*   Local Frame Size  : 0 Args + 0 Auto + 0 Save = 0 byte                   *
;*****************************************************************************
main:
;* --------------------------------------------------------------------------*
        CALLA     #initial              ; [] |180| 
                                          ; [] |180| 
        MOV.W     #$C$SL1+0,r12         ; [] |182| 
        CALLA     #printstr             ; [] |182| 
                                          ; [] |182| 
        MOV.W     #time+0,r12           ; [] |183| 
        CALLA     #convert_timer        ; [] |183| 
                                          ; [] |183| 
        MOV.W     #time+0,r12           ; [] |184| 
        CALLA     #printstr             ; [] |184| 
                                          ; [] |184| 
        MOV.W     #$C$SL2+0,r12         ; [] |185| 
        CALLA     #printstr             ; [] |185| 
                                          ; [] |185| 
;* --------------------------------------------------------------------------*
;*   BEGIN LOOP $C$L11
;*
;*   Loop source line                : 187
;*   Loop closing brace source line  : 190
;*   Known Minimum Trip Count        : 1
;*   Known Maximum Trip Count        : 4294967295
;*   Known Max Trip Count Factor     : 1
;* --------------------------------------------------------------------------*
$C$L11:    
        NOP
        BIS.W    #24,SR
        NOP      ; [] |189| 
        JMP       $C$L11                ; [] |187| 
                                          ; [] |187| 
        NOP       ; [] 
;* --------------------------------------------------------------------------*
	.sect	".text:_isr:button_ISR"
	.clink
	.global	button_ISR

;*****************************************************************************
;* FUNCTION NAME: button_ISR                                                 *
;*                                                                           *
;*   Regs Modified     : SP,SR,r11,r12,r13,r14,r15                           *
;*   Regs Used         : SP,SR,r11,r12,r13,r14,r15                           *
;*   Local Frame Size  : 0 Args + 0 Auto + 20 Save = 20 byte                 *
;*****************************************************************************
button_ISR:
;* --------------------------------------------------------------------------*
        PUSHM.A   #5,r15                ; [] 
        AND.B     #252,&PBIE_H+0        ; [] |197| 
        MOV.B     &PBIFG_H+0,r14        ; [] |200| 
        MOV.W     &TA0R+0,r15           ; [] |210| 
        ADD.W     #120,r15              ; [] |211| 
        MOV.W     r15,&TA0CCR1+0        ; [] |211| 
        CMP.W     &TA0CCR1+0,&TA0CCR0+0 ; [] |212| 
        JHS       $C$L12                ; [] |212| 
                                          ; [] |212| 
;* --------------------------------------------------------------------------*
        MOV.W     &TA0CCR1+0,r15        ; [] |214| 
        SUB.W     &TA0CCR0+0,r15        ; [] |214| 
        SUB.W     #1,r15                ; [] |214| 
        MOV.W     r15,&TA0CCR1+0        ; [] |214| 
;* --------------------------------------------------------------------------*
$C$L12:    
        OR.W      #16,&TA0CCTL1+0       ; [] |216| 
        NOP
        EINT
        NOP      ; [] |217| 
        NOP
        BIS.W    #24,SR
        NOP      ; [] |218| 
        DINT
        NOP      ; [] |219| 
        AND.W     #65519,&TA0CCTL1+0    ; [] |220| 
        BIT.B     #2,r14                ; [] |228| 
        JNE       $C$L16                ; [] |228| 
                                          ; [] |228| 
;* --------------------------------------------------------------------------*
        BIT.B     #1,r14                ; [] |393| 
        JEQ       $C$L21                ; [] |393| 
                                          ; [] |393| 
;* --------------------------------------------------------------------------*
        MOV.B     &current_task+0,r15   ; [] |393| 
        TST.W     r15                   ; [] |393| 
        JEQ       $C$L14                ; [] |393| 
                                          ; [] |393| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |393| 
        JEQ       $C$L13                ; [] |393| 
                                          ; [] |393| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |393| 
        JNE       $C$L15                ; [] |393| 
                                          ; [] |393| 
;* --------------------------------------------------------------------------*
        NOP       ; [] |463| 
        NOP
        EINT
        NOP      ; [] |469| 
        MOV.W     #$C$SL1+0,r12         ; [] |470| 
        CALLA     #printstr             ; [] |470| 
                                          ; [] |470| 
        MOV.W     #time+0,r12           ; [] |471| 
        CALLA     #convert_timer        ; [] |471| 
                                          ; [] |471| 
        MOV.W     #time+0,r12           ; [] |472| 
        CALLA     #printstr             ; [] |472| 
                                          ; [] |472| 
        MOV.W     #$C$SL3+0,r12         ; [] |473| 
        CALLA     #printstr             ; [] |473| 
                                          ; [] |473| 
        DINT
        NOP      ; [] |474| 
        JMP       $C$L15                ; [] |476| 
                                          ; [] |476| 
;* --------------------------------------------------------------------------*
$C$L13:    
        AND.W     #65487,&TA1CTL+0      ; [] |435| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |438| 
        OR.W      #4,&TA1CTL+0          ; [] |441| 
        MOV.B     #0,&current_task+0    ; [] |444| 
        MOV.W     #0,&TA1CCR0+0         ; [] |447| 
        AND.W     #65520,&PJOUT+0       ; [] |450| 
        NOP
        EINT
        NOP      ; [] |453| 
        MOV.W     #$C$SL1+0,r12         ; [] |454| 
        CALLA     #printstr             ; [] |454| 
                                          ; [] |454| 
        MOV.W     #time+0,r12           ; [] |455| 
        CALLA     #convert_timer        ; [] |455| 
                                          ; [] |455| 
        MOV.W     #time+0,r12           ; [] |456| 
        CALLA     #printstr             ; [] |456| 
                                          ; [] |456| 
        MOV.W     #$C$SL4+0,r12         ; [] |457| 
        CALLA     #printstr             ; [] |457| 
                                          ; [] |457| 
        DINT
        NOP      ; [] |458| 
        JMP       $C$L15                ; [] |460| 
                                          ; [] |460| 
;* --------------------------------------------------------------------------*
$C$L14:    
        AND.W     #65487,&TA1CTL+0      ; [] |398| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |401| 
        OR.W      #4,&TA1CTL+0          ; [] |404| 
        MOV.B     #1,&current_task+0    ; [] |407| 
        MOV.W     #614,&TA1CCR0+0       ; [] |410| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |413| 
        OR.W      #16,&TA1CCTL0+0       ; [] |414| 
        OR.W      #16,&TA1CTL+0         ; [] |417| 
        MOV.W     #1,&PJOUT+0           ; [] |420| 
        MOV.B     #1,&S1_LED_state+0    ; [] |421| 
        NOP
        EINT
        NOP      ; [] |424| 
        MOV.W     #$C$SL1+0,r12         ; [] |425| 
        CALLA     #printstr             ; [] |425| 
                                          ; [] |425| 
        MOV.W     #time+0,r12           ; [] |426| 
        CALLA     #convert_timer        ; [] |426| 
                                          ; [] |426| 
        MOV.W     #time+0,r12           ; [] |427| 
        CALLA     #printstr             ; [] |427| 
                                          ; [] |427| 
        MOV.W     #$C$SL5+0,r12         ; [] |428| 
        CALLA     #printstr             ; [] |428| 
                                          ; [] |428| 
        DINT
        NOP      ; [] |429| 
;* --------------------------------------------------------------------------*
$C$L15:    
        BIC.B     #1,&PBIFG_H+0         ; [] |482| 
        JMP       $C$L21                ; [] |482| 
                                          ; [] |482| 
;* --------------------------------------------------------------------------*
$C$L16:    
        MOV.B     &current_task+0,r15   ; [] |228| 
        TST.W     r15                   ; [] |228| 
        JEQ       $C$L19                ; [] |228| 
                                          ; [] |228| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |228| 
        JEQ       $C$L18                ; [] |228| 
                                          ; [] |228| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |228| 
        JNE       $C$L20                ; [] |228| 
                                          ; [] |228| 
;* --------------------------------------------------------------------------*
        TST.B     &normal_suspended+0   ; [] |270| 
        JNE       $C$L17                ; [] |270| 
                                          ; [] |270| 
;* --------------------------------------------------------------------------*
        AND.W     #65487,&TA1CTL+0      ; [] |314| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |317| 
        OR.W      #4,&TA1CTL+0          ; [] |320| 
        MOV.B     #0,&current_task+0    ; [] |323| 
        MOV.W     #0,&TA1CCR0+0         ; [] |325| 
        AND.B     #15,&PBOUT_L+0        ; [] |328| 
        NOP
        EINT
        NOP      ; [] |331| 
        MOV.W     #$C$SL1+0,r12         ; [] |332| 
        CALLA     #printstr             ; [] |332| 
                                          ; [] |332| 
        MOV.W     #time+0,r12           ; [] |333| 
        CALLA     #convert_timer        ; [] |333| 
                                          ; [] |333| 
        MOV.W     #time+0,r12           ; [] |334| 
        CALLA     #printstr             ; [] |334| 
                                          ; [] |334| 
        MOV.W     #$C$SL6+0,r12         ; [] |335| 
        CALLA     #printstr             ; [] |335| 
                                          ; [] |335| 
        DINT
        NOP      ; [] |336| 
        JMP       $C$L20                ; [] |336| 
                                          ; [] |336| 
;* --------------------------------------------------------------------------*
$C$L17:    
        AND.W     #65487,&TA1CTL+0      ; [] |273| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |276| 
        OR.W      #4,&TA1CTL+0          ; [] |279| 
        MOV.B     #1,&current_task+0    ; [] |282| 
        MOV.B     #0,&normal_suspended+0 ; [] |284| 
        MOV.W     #614,&TA1CCR0+0       ; [] |287| 
        MOV.W     &normal_timer_mem+0,&TA1R+0 ; [] |290| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |293| 
        OR.W      #16,&TA1CCTL0+0       ; [] |294| 
        OR.W      #16,&TA1CTL+0         ; [] |297| 
        AND.B     #15,&PBOUT_L+0        ; [] |300| 
        NOP
        EINT
        NOP      ; [] |303| 
        MOV.W     #$C$SL1+0,r12         ; [] |304| 
        CALLA     #printstr             ; [] |304| 
                                          ; [] |304| 
        MOV.W     #time+0,r12           ; [] |305| 
        CALLA     #convert_timer        ; [] |305| 
                                          ; [] |305| 
        MOV.W     #time+0,r12           ; [] |306| 
        CALLA     #printstr             ; [] |306| 
                                          ; [] |306| 
        MOV.W     #$C$SL7+0,r12         ; [] |307| 
        CALLA     #printstr             ; [] |307| 
                                          ; [] |307| 
        DINT
        NOP      ; [] |308| 
        JMP       $C$L20                ; [] 
                                          ; [] 
;* --------------------------------------------------------------------------*
$C$L18:    
        AND.W     #65487,&TA1CTL+0      ; [] |344| 
        MOV.W     &TA1R+0,&normal_timer_mem+0 ; [] |347| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |350| 
        OR.W      #4,&TA1CTL+0          ; [] |353| 
        MOV.B     #1,&normal_suspended+0 ; [] |356| 
        MOV.B     #2,&current_task+0    ; [] |357| 
        MOV.W     #153,&TA1CCR0+0       ; [] |360| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |363| 
        OR.W      #16,&TA1CCTL0+0       ; [] |364| 
        OR.W      #16,&TA1CTL+0         ; [] |367| 
        OR.B      #240,&PBOUT_L+0       ; [] |370| 
        NOP
        EINT
        NOP      ; [] |373| 
        MOV.W     #$C$SL1+0,r12         ; [] |374| 
        CALLA     #printstr             ; [] |374| 
                                          ; [] |374| 
        MOV.W     #time+0,r12           ; [] |375| 
        CALLA     #convert_timer        ; [] |375| 
                                          ; [] |375| 
        MOV.W     #time+0,r12           ; [] |376| 
        CALLA     #printstr             ; [] |376| 
                                          ; [] |376| 
        MOV.W     #$C$SL8+0,r12         ; [] |377| 
        CALLA     #printstr             ; [] |377| 
                                          ; [] |377| 
        DINT
        NOP      ; [] |378| 
        JMP       $C$L20                ; [] |380| 
                                          ; [] |380| 
;* --------------------------------------------------------------------------*
$C$L19:    
        AND.W     #65487,&TA1CTL+0      ; [] |233| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |236| 
        OR.W      #4,&TA1CTL+0          ; [] |239| 
        MOV.B     #2,&current_task+0    ; [] |242| 
        MOV.W     #153,&TA1CCR0+0       ; [] |245| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |249| 
        OR.W      #16,&TA1CCTL0+0       ; [] |250| 
        OR.W      #16,&TA1CTL+0         ; [] |253| 
        OR.B      #240,&PBOUT_L+0       ; [] |256| 
        NOP
        EINT
        NOP      ; [] |259| 
        MOV.W     #$C$SL1+0,r12         ; [] |260| 
        CALLA     #printstr             ; [] |260| 
                                          ; [] |260| 
        MOV.W     #time+0,r12           ; [] |261| 
        CALLA     #convert_timer        ; [] |261| 
                                          ; [] |261| 
        MOV.W     #time+0,r12           ; [] |262| 
        CALLA     #printstr             ; [] |262| 
                                          ; [] |262| 
        MOV.W     #$C$SL9+0,r12         ; [] |263| 
        CALLA     #printstr             ; [] |263| 
                                          ; [] |263| 
        DINT
        NOP      ; [] |264| 
;* --------------------------------------------------------------------------*
$C$L20:    
        AND.B     #252,&PBIFG_H+0       ; [] |387| 
;* --------------------------------------------------------------------------*
$C$L21:    
        OR.B      #3,&PBIE_H+0          ; [] |487| 
        POPM.A    #5,r15                ; [] 
        RETI      ; [] 
        ; [] 
	.sect	".text:_isr:UART_ISR"
	.clink
	.global	UART_ISR

;*****************************************************************************
;* FUNCTION NAME: UART_ISR                                                   *
;*                                                                           *
;*   Regs Modified     : SP,SR,r15                                           *
;*   Regs Used         : SP,SR,r15                                           *
;*   Local Frame Size  : 0 Args + 0 Auto + 4 Save = 4 byte                   *
;*****************************************************************************
UART_ISR:
;* --------------------------------------------------------------------------*
        PUSHM.A   #1,r15                ; [] 
        MOV.B     &print_idx+0,r15      ; [] |555| 
        ADD.W     &print_str+0,r15      ; [] |555| 
        TST.B     0(r15)                ; [] |555| 
        JNE       $C$L22                ; [] |555| 
                                          ; [] |555| 
;* --------------------------------------------------------------------------*
        BIC.W     #2,&UCA0IE+0          ; [] |562| 
        BIC.W     #16,4(SP)             ; [] |563| 
        JMP       $C$L23                ; [] |563| 
                                          ; [] |563| 
;* --------------------------------------------------------------------------*
$C$L22:    
        MOV.B     &print_idx+0,r15      ; [] |557| 
        ADD.W     &print_str+0,r15      ; [] |557| 
        MOV.B     @r15,r15              ; [] |557| 
        MOV.W     r15,&UCA0TXBUF+0      ; [] |557| 
        ADD.B     #1,&print_idx+0       ; [] |558| 
;* --------------------------------------------------------------------------*
$C$L23:    
        POPM.A    #1,r15                ; [] 
        RETI      ; [] 
        ; [] 
	.sect	".text:_isr:Timer0_ISR"
	.clink
	.global	Timer0_ISR

;*****************************************************************************
;* FUNCTION NAME: Timer0_ISR                                                 *
;*                                                                           *
;*   Regs Modified     : SP,SR                                               *
;*   Regs Used         : SP,SR                                               *
;*   Local Frame Size  : 0 Args + 0 Auto + 0 Save = 0 byte                   *
;*****************************************************************************
Timer0_ISR:
;* --------------------------------------------------------------------------*
        ADD.W     #1,&sys_timer_overflow+0 ; [] |537| 
        BIC.W     #1,&TA0CCTL0+0        ; [] |539| 
        RETI      ; [] 
        ; [] 
;******************************************************************************
;* STRINGS                                                                    *
;******************************************************************************
	.sect	".const:.string"
	.align	2
$C$SL1:	.string	"[ ",0
	.align	2
$C$SL2:	.string	" ms ] EXITING STARTUP -> ENTERING IDLE",10,13,0
	.align	2
$C$SL3:	.string	" ms ] S1 -> NORMAL CALL IGNORED : EMERGENCY CALL ACTIVE",10
	.string	13,0
	.align	2
$C$SL4:	.string	" ms ] S1 -> NORMAL CALL COMPLETE",10,13,0
	.align	2
$C$SL5:	.string	" ms ] S1 -> NORMAL CALL : EXIT IDLE",10,13,0
	.align	2
$C$SL6:	.string	" ms ] S2 -> EMERGENCY CALL COMPLETE",10,13,0
	.align	2
$C$SL7:	.string	" ms ] S2 -> EXIT EMERGENCY CALL : RESUME NORMAL CALL",10,13
	.string	0
	.align	2
$C$SL8:	.string	" ms ] S2 -> EMERGENCY CALL : SUSPEND NORMAL CALL",10,13,0
	.align	2
$C$SL9:	.string	" ms ] S2 -> EMERGENCY CALL : EXIT IDLE",10,13,0
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

;******************************************************************************
;* BUILD ATTRIBUTES                                                           *
;******************************************************************************
	.battr "TI", Tag_File, 1, Tag_LPM_INFO(2)
	.battr "TI", Tag_File, 1, Tag_PORTS_INIT_INFO("012345678901ABCDEFGHIJ00000000000011000000000000000000000100000000")
	.battr "TI", Tag_File, 1, Tag_LEA_INFO(1)
	.battr "TI", Tag_File, 1, Tag_HW_MPY32_INFO(2)
	.battr "TI", Tag_File, 1, Tag_HW_MPY_ISR_INFO(3)
	.battr "TI", Tag_File, 1, Tag_HW_MPY_INLINE_INFO(1)
	.battr "mspabi", Tag_File, 1, Tag_enum_size(3)
