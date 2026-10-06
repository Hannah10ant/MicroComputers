;******************************************************************************
;* MSP430 G3 C/C++ Codegen                                              PC v21.6.2.LTS *
;* Date/Time created: Tue Oct  6 17:42:52 2026                                *
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
;	E:\TICCS\ccs\tools\compiler\ti-cgt-msp430_21.6.2.LTS\bin\opt430.exe C:\\Users\\Erik\\AppData\\Local\\Temp\\{84EAD028-94A9-4EA6-997E-97046D4A56DC} C:\\Users\\Erik\\AppData\\Local\\Temp\\{A429973D-7DD7-450B-97B7-4A7C639AB109} 
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
        CMP.B     #1,&current_task+0    ; [] |480| 
        JEQ       $C$L2                 ; [] |480| 
                                          ; [] |480| 
;* --------------------------------------------------------------------------*
        CMP.B     #2,&current_task+0    ; [] |504| 
        JEQ       $C$L1                 ; [] |504| 
                                          ; [] |504| 
;* --------------------------------------------------------------------------*
        NOP       ; [] |510| 
        JMP       $C$L7                 ; [] |510| 
                                          ; [] |510| 
;* --------------------------------------------------------------------------*
$C$L1:    
        XOR.B     #240,&PBOUT_L+0       ; [] |506| 
        JMP       $C$L7                 ; [] 
                                          ; [] 
;* --------------------------------------------------------------------------*
$C$L2:    
        MOV.B     &S1_LED_state+0,r15   ; [] |480| 
        TST.W     r15                   ; [] |480| 
        JEQ       $C$L6                 ; [] |480| 
                                          ; [] |480| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |480| 
        JEQ       $C$L5                 ; [] |480| 
                                          ; [] |480| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |480| 
        JEQ       $C$L4                 ; [] |480| 
                                          ; [] |480| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |480| 
        JEQ       $C$L3                 ; [] |480| 
                                          ; [] |480| 
;* --------------------------------------------------------------------------*
        AND.W     #65520,&PJOUT+0       ; [] |499| 
        MOV.B     #0,&S1_LED_state+0    ; [] |500| 
        JMP       $C$L7                 ; [] |501| 
                                          ; [] |501| 
;* --------------------------------------------------------------------------*
$C$L3:    
        MOV.W     #8,&PJOUT+0           ; [] |495| 
        MOV.B     #0,&S1_LED_state+0    ; [] |496| 
        JMP       $C$L7                 ; [] |497| 
                                          ; [] |497| 
;* --------------------------------------------------------------------------*
$C$L4:    
        MOV.W     #4,&PJOUT+0           ; [] |491| 
        ADD.B     #1,&S1_LED_state+0    ; [] |492| 
        JMP       $C$L7                 ; [] |493| 
                                          ; [] |493| 
;* --------------------------------------------------------------------------*
$C$L5:    
        MOV.W     #2,&PJOUT+0           ; [] |487| 
        ADD.B     #1,&S1_LED_state+0    ; [] |488| 
        JMP       $C$L7                 ; [] |489| 
                                          ; [] |489| 
;* --------------------------------------------------------------------------*
$C$L6:    
        MOV.W     #1,&PJOUT+0           ; [] |483| 
        ADD.B     #1,&S1_LED_state+0    ; [] |484| 
;* --------------------------------------------------------------------------*
$C$L7:    
        BIC.W     #1,&TA1CCTL0+0        ; [] |513| 
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
        BIC.W     #16,0(SP)             ; [] |528| 
        BIC.W     #1,&TA0CCTL1+0        ; [] |530| 
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
        MOV.B     #165,&CSCTL0_H+0      ; [] |100| 
        BIC.W     #1,&CSCTL4+0          ; [] |101| 
        MOV.W     #51,&CSCTL2+0         ; [] |102| 
        AND.W     #63743,&CSCTL3+0      ; [] |103| 
        AND.W     #65343,&CSCTL4+0      ; [] |104| 
        AND.W     #65503,&CSCTL4+0      ; [] |105| 
        MOV.B     #0,&CSCTL0_H+0        ; [] |106| 
        AND.W     #65487,&TA0CTL+0      ; [] |109| 
        OR.W      #256,&TA0CTL+0        ; [] |110| 
        OR.W      #192,&TA0CTL+0        ; [] |111| 
        OR.W      #4,&TA0CTL+0          ; [] |112| 
        MOV.W     #15359,&TA0CCR0+0     ; [] |115| 
        AND.W     #16127,&TA0CCTL0+0    ; [] |116| 
        OR.W      #16,&TA0CCTL0+0       ; [] |117| 
        AND.W     #16127,&TA0CCTL1+0    ; [] |119| 
        OR.W      #16,&TA0CTL+0         ; [] |122| 
        AND.W     #65487,&TA1CTL+0      ; [] |125| 
        OR.W      #256,&TA1CTL+0        ; [] |126| 
        OR.W      #192,&TA1CTL+0        ; [] |127| 
        OR.W      #4,&TA1CTL+0          ; [] |128| 
        AND.W     #16127,&TA1CCTL0+0    ; [] |130| 
        MOV.W     #15,&PJDIR+0          ; [] |133| 
        MOV.B     #240,&PBDIR_L+0       ; [] |134| 
        MOV.B     #0,&PBDIR_H+0         ; [] |135| 
        OR.B      #3,&PBREN_H+0         ; [] |138| 
        OR.B      #3,&PBOUT_H+0         ; [] |139| 
        OR.B      #3,&PBIES_H+0         ; [] |142| 
        AND.B     #252,&PBIFG_H+0       ; [] |145| 
        AND.W     #65520,&PJOUT+0       ; [] |148| 
        AND.B     #15,&PBOUT_L+0        ; [] |149| 
        MOV.B     #3,&PASEL1_H+0        ; [] |152| 
        MOV.B     #129,&UCA0CTLW0_L+0   ; [] |153| 
        MOV.W     #6,&UCA0BRW+0         ; [] |154| 
        MOV.W     #8321,&UCA0MCTLW+0    ; [] |155| 
        BIC.B     #1,&UCA0CTLW0_L+0     ; [] |156| 
        OR.B      #3,&PBIE_H+0          ; [] |159| 
        NOP
        BIS.W    #8,SR
        NOP      ; [] |161| 
        RETA      ; [] 
        ; [] 
	.sect	".text:main"
	.clink
	.global	main

;*****************************************************************************
;* FUNCTION NAME: main                                                       *
;*                                                                           *
;*   Regs Modified     : SR                                                  *
;*   Regs Used         : SR                                                  *
;*   Local Frame Size  : 0 Args + 0 Auto + 0 Save = 0 byte                   *
;*****************************************************************************
main:
;* --------------------------------------------------------------------------*
        CALLA     #initial              ; [] |168| 
                                          ; [] |168| 
;* --------------------------------------------------------------------------*
;*   BEGIN LOOP $C$L8
;*
;*   Loop source line                : 170
;*   Loop closing brace source line  : 173
;*   Known Minimum Trip Count        : 1
;*   Known Maximum Trip Count        : 4294967295
;*   Known Max Trip Count Factor     : 1
;* --------------------------------------------------------------------------*
$C$L8:    
        NOP
        BIS.W    #24,SR
        NOP      ; [] |172| 
        JMP       $C$L8                 ; [] |170| 
                                          ; [] |170| 
        NOP       ; [] 
;* --------------------------------------------------------------------------*
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
        AND.B     #252,&PBIE_H+0        ; [] |180| 
        MOV.B     &PBIFG_H+0,r14        ; [] |183| 
        MOV.W     &TA0R+0,r15           ; [] |193| 
        ADD.W     #120,r15              ; [] |194| 
        MOV.W     r15,&TA0CCR1+0        ; [] |194| 
        CMP.W     &TA0CCR1+0,&TA0CCR0+0 ; [] |195| 
        JHS       $C$L11                ; [] |195| 
                                          ; [] |195| 
;* --------------------------------------------------------------------------*
        MOV.W     &TA0CCR1+0,r15        ; [] |197| 
        SUB.W     &TA0CCR0+0,r15        ; [] |197| 
        SUB.W     #1,r15                ; [] |197| 
        MOV.W     r15,&TA0CCR1+0        ; [] |197| 
;* --------------------------------------------------------------------------*
$C$L11:    
        OR.W      #16,&TA0CCTL1+0       ; [] |199| 
        NOP
        EINT
        NOP      ; [] |200| 
        NOP
        BIS.W    #24,SR
        NOP      ; [] |201| 
        DINT
        NOP      ; [] |202| 
        AND.W     #65519,&TA0CCTL1+0    ; [] |203| 
        BIT.B     #2,r14                ; [] |211| 
        JNE       $C$L15                ; [] |211| 
                                          ; [] |211| 
;* --------------------------------------------------------------------------*
        BIT.B     #1,r14                ; [] |376| 
        JEQ       $C$L20                ; [] |376| 
                                          ; [] |376| 
;* --------------------------------------------------------------------------*
        MOV.B     &current_task+0,r15   ; [] |376| 
        TST.W     r15                   ; [] |376| 
        JEQ       $C$L13                ; [] |376| 
                                          ; [] |376| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |376| 
        JEQ       $C$L12                ; [] |376| 
                                          ; [] |376| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |376| 
        JNE       $C$L14                ; [] |376| 
                                          ; [] |376| 
;* --------------------------------------------------------------------------*
        NOP       ; [] |446| 
        NOP
        EINT
        NOP      ; [] |452| 
        MOV.W     #$C$SL1+0,r12         ; [] |453| 
        CALLA     #printstr             ; [] |453| 
                                          ; [] |453| 
        MOV.W     #time+0,r12           ; [] |454| 
        CALLA     #convert_timer        ; [] |454| 
                                          ; [] |454| 
        MOV.W     #time+0,r12           ; [] |455| 
        CALLA     #printstr             ; [] |455| 
                                          ; [] |455| 
        MOV.W     #$C$SL2+0,r12         ; [] |456| 
        CALLA     #printstr             ; [] |456| 
                                          ; [] |456| 
        DINT
        NOP      ; [] |457| 
        JMP       $C$L14                ; [] |459| 
                                          ; [] |459| 
;* --------------------------------------------------------------------------*
$C$L12:    
        AND.W     #65487,&TA1CTL+0      ; [] |418| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |421| 
        OR.W      #4,&TA1CTL+0          ; [] |424| 
        MOV.B     #0,&current_task+0    ; [] |427| 
        MOV.W     #0,&TA1CCR0+0         ; [] |430| 
        AND.W     #65520,&PJOUT+0       ; [] |433| 
        NOP
        EINT
        NOP      ; [] |436| 
        MOV.W     #$C$SL1+0,r12         ; [] |437| 
        CALLA     #printstr             ; [] |437| 
                                          ; [] |437| 
        MOV.W     #time+0,r12           ; [] |438| 
        CALLA     #convert_timer        ; [] |438| 
                                          ; [] |438| 
        MOV.W     #time+0,r12           ; [] |439| 
        CALLA     #printstr             ; [] |439| 
                                          ; [] |439| 
        MOV.W     #$C$SL3+0,r12         ; [] |440| 
        CALLA     #printstr             ; [] |440| 
                                          ; [] |440| 
        DINT
        NOP      ; [] |441| 
        JMP       $C$L14                ; [] |443| 
                                          ; [] |443| 
;* --------------------------------------------------------------------------*
$C$L13:    
        AND.W     #65487,&TA1CTL+0      ; [] |381| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |384| 
        OR.W      #4,&TA1CTL+0          ; [] |387| 
        MOV.B     #1,&current_task+0    ; [] |390| 
        MOV.W     #614,&TA1CCR0+0       ; [] |393| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |396| 
        OR.W      #16,&TA1CCTL0+0       ; [] |397| 
        OR.W      #16,&TA1CTL+0         ; [] |400| 
        MOV.W     #1,&PJOUT+0           ; [] |403| 
        MOV.B     #1,&S1_LED_state+0    ; [] |404| 
        NOP
        EINT
        NOP      ; [] |407| 
        MOV.W     #$C$SL1+0,r12         ; [] |408| 
        CALLA     #printstr             ; [] |408| 
                                          ; [] |408| 
        MOV.W     #time+0,r12           ; [] |409| 
        CALLA     #convert_timer        ; [] |409| 
                                          ; [] |409| 
        MOV.W     #time+0,r12           ; [] |410| 
        CALLA     #printstr             ; [] |410| 
                                          ; [] |410| 
        MOV.W     #$C$SL4+0,r12         ; [] |411| 
        CALLA     #printstr             ; [] |411| 
                                          ; [] |411| 
        DINT
        NOP      ; [] |412| 
;* --------------------------------------------------------------------------*
$C$L14:    
        BIC.B     #1,&PBIFG_H+0         ; [] |465| 
        JMP       $C$L20                ; [] |465| 
                                          ; [] |465| 
;* --------------------------------------------------------------------------*
$C$L15:    
        MOV.B     &current_task+0,r15   ; [] |211| 
        TST.W     r15                   ; [] |211| 
        JEQ       $C$L18                ; [] |211| 
                                          ; [] |211| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |211| 
        JEQ       $C$L17                ; [] |211| 
                                          ; [] |211| 
;* --------------------------------------------------------------------------*
        SUB.W     #1,r15                ; [] |211| 
        JNE       $C$L19                ; [] |211| 
                                          ; [] |211| 
;* --------------------------------------------------------------------------*
        TST.B     &normal_suspended+0   ; [] |253| 
        JNE       $C$L16                ; [] |253| 
                                          ; [] |253| 
;* --------------------------------------------------------------------------*
        AND.W     #65487,&TA1CTL+0      ; [] |297| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |300| 
        OR.W      #4,&TA1CTL+0          ; [] |303| 
        MOV.B     #0,&current_task+0    ; [] |306| 
        MOV.W     #0,&TA1CCR0+0         ; [] |308| 
        AND.B     #15,&PBOUT_L+0        ; [] |311| 
        NOP
        EINT
        NOP      ; [] |314| 
        MOV.W     #$C$SL1+0,r12         ; [] |315| 
        CALLA     #printstr             ; [] |315| 
                                          ; [] |315| 
        MOV.W     #time+0,r12           ; [] |316| 
        CALLA     #convert_timer        ; [] |316| 
                                          ; [] |316| 
        MOV.W     #time+0,r12           ; [] |317| 
        CALLA     #printstr             ; [] |317| 
                                          ; [] |317| 
        MOV.W     #$C$SL5+0,r12         ; [] |318| 
        CALLA     #printstr             ; [] |318| 
                                          ; [] |318| 
        DINT
        NOP      ; [] |319| 
        JMP       $C$L19                ; [] |319| 
                                          ; [] |319| 
;* --------------------------------------------------------------------------*
$C$L16:    
        AND.W     #65487,&TA1CTL+0      ; [] |256| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |259| 
        OR.W      #4,&TA1CTL+0          ; [] |262| 
        MOV.B     #1,&current_task+0    ; [] |265| 
        MOV.B     #0,&normal_suspended+0 ; [] |267| 
        MOV.W     #614,&TA1CCR0+0       ; [] |270| 
        MOV.W     &normal_timer_mem+0,&TA1R+0 ; [] |273| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |276| 
        OR.W      #16,&TA1CCTL0+0       ; [] |277| 
        OR.W      #16,&TA1CTL+0         ; [] |280| 
        AND.B     #15,&PBOUT_L+0        ; [] |283| 
        NOP
        EINT
        NOP      ; [] |286| 
        MOV.W     #$C$SL1+0,r12         ; [] |287| 
        CALLA     #printstr             ; [] |287| 
                                          ; [] |287| 
        MOV.W     #time+0,r12           ; [] |288| 
        CALLA     #convert_timer        ; [] |288| 
                                          ; [] |288| 
        MOV.W     #time+0,r12           ; [] |289| 
        CALLA     #printstr             ; [] |289| 
                                          ; [] |289| 
        MOV.W     #$C$SL6+0,r12         ; [] |290| 
        CALLA     #printstr             ; [] |290| 
                                          ; [] |290| 
        DINT
        NOP      ; [] |291| 
        JMP       $C$L19                ; [] 
                                          ; [] 
;* --------------------------------------------------------------------------*
$C$L17:    
        AND.W     #65487,&TA1CTL+0      ; [] |327| 
        MOV.W     &TA1R+0,&normal_timer_mem+0 ; [] |330| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |333| 
        OR.W      #4,&TA1CTL+0          ; [] |336| 
        MOV.B     #1,&normal_suspended+0 ; [] |339| 
        MOV.B     #2,&current_task+0    ; [] |340| 
        MOV.W     #153,&TA1CCR0+0       ; [] |343| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |346| 
        OR.W      #16,&TA1CCTL0+0       ; [] |347| 
        OR.W      #16,&TA1CTL+0         ; [] |350| 
        OR.B      #240,&PBOUT_L+0       ; [] |353| 
        NOP
        EINT
        NOP      ; [] |356| 
        MOV.W     #$C$SL1+0,r12         ; [] |357| 
        CALLA     #printstr             ; [] |357| 
                                          ; [] |357| 
        MOV.W     #time+0,r12           ; [] |358| 
        CALLA     #convert_timer        ; [] |358| 
                                          ; [] |358| 
        MOV.W     #time+0,r12           ; [] |359| 
        CALLA     #printstr             ; [] |359| 
                                          ; [] |359| 
        MOV.W     #$C$SL7+0,r12         ; [] |360| 
        CALLA     #printstr             ; [] |360| 
                                          ; [] |360| 
        DINT
        NOP      ; [] |361| 
        JMP       $C$L19                ; [] |363| 
                                          ; [] |363| 
;* --------------------------------------------------------------------------*
$C$L18:    
        AND.W     #65487,&TA1CTL+0      ; [] |216| 
        AND.W     #65519,&TA1CCTL0+0    ; [] |219| 
        OR.W      #4,&TA1CTL+0          ; [] |222| 
        MOV.B     #2,&current_task+0    ; [] |225| 
        MOV.W     #153,&TA1CCR0+0       ; [] |228| 
        BIC.W     #1,&TA1CCTL0+0        ; [] |232| 
        OR.W      #16,&TA1CCTL0+0       ; [] |233| 
        OR.W      #16,&TA1CTL+0         ; [] |236| 
        OR.B      #240,&PBOUT_L+0       ; [] |239| 
        NOP
        EINT
        NOP      ; [] |242| 
        MOV.W     #$C$SL1+0,r12         ; [] |243| 
        CALLA     #printstr             ; [] |243| 
                                          ; [] |243| 
        MOV.W     #time+0,r12           ; [] |244| 
        CALLA     #convert_timer        ; [] |244| 
                                          ; [] |244| 
        MOV.W     #time+0,r12           ; [] |245| 
        CALLA     #printstr             ; [] |245| 
                                          ; [] |245| 
        MOV.W     #$C$SL8+0,r12         ; [] |246| 
        CALLA     #printstr             ; [] |246| 
                                          ; [] |246| 
        DINT
        NOP      ; [] |247| 
;* --------------------------------------------------------------------------*
$C$L19:    
        AND.B     #252,&PBIFG_H+0       ; [] |370| 
;* --------------------------------------------------------------------------*
$C$L20:    
        OR.B      #3,&PBIE_H+0          ; [] |470| 
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
        MOV.B     &print_idx+0,r15      ; [] |538| 
        ADD.W     &print_str+0,r15      ; [] |538| 
        TST.B     0(r15)                ; [] |538| 
        JNE       $C$L21                ; [] |538| 
                                          ; [] |538| 
;* --------------------------------------------------------------------------*
        BIC.W     #2,&UCA0IE+0          ; [] |545| 
        BIC.W     #16,4(SP)             ; [] |546| 
        JMP       $C$L22                ; [] |546| 
                                          ; [] |546| 
;* --------------------------------------------------------------------------*
$C$L21:    
        MOV.B     &print_idx+0,r15      ; [] |540| 
        ADD.W     &print_str+0,r15      ; [] |540| 
        MOV.B     @r15,r15              ; [] |540| 
        MOV.W     r15,&UCA0TXBUF+0      ; [] |540| 
        ADD.B     #1,&print_idx+0       ; [] |541| 
;* --------------------------------------------------------------------------*
$C$L22:    
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
        ADD.W     #1,&sys_timer_overflow+0 ; [] |520| 
        BIC.W     #1,&TA0CCTL0+0        ; [] |522| 
        RETI      ; [] 
        ; [] 
;******************************************************************************
;* STRINGS                                                                    *
;******************************************************************************
	.sect	".const:.string"
	.align	2
$C$SL1:	.string	"[ ",0
	.align	2
$C$SL2:	.string	" ms ] S1 -> NORMAL CALL IGNORED : EMERGENCY CALL ACTIVE",10
	.string	13,0
	.align	2
$C$SL3:	.string	" ms ] S1 -> NORMAL CALL COMPLETE",10,13,0
	.align	2
$C$SL4:	.string	" ms ] S1 -> NORMAL CALL : EXIT IDLE",10,13,0
	.align	2
$C$SL5:	.string	" ms ] S2 -> EMERGENCY CALL COMPLETE",10,13,0
	.align	2
$C$SL6:	.string	" ms ] S2 -> EXIT EMERGENCY CALL : RESUME NORMAL CALL",10,13
	.string	0
	.align	2
$C$SL7:	.string	" ms ] S2 -> EMERGENCY CALL : SUSPEND NORMAL CALL",10,13,0
	.align	2
$C$SL8:	.string	" ms ] S2 -> EMERGENCY CALL : EXIT IDLE",10,13,0
;*****************************************************************************
;* UNDEFINED EXTERNAL REFERENCES                                             *
;*****************************************************************************
	.global	CSCTL0_H
	.global	CSCTL2
	.global	CSCTL3
	.global	CSCTL4
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
