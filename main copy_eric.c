#include "msp430fr5739.h"

#define LED1 0x01
#define LED2 0x02
#define LED3 0x04
#define LED4 0x08

#define LED5 0x10
#define LED6 0x20
#define LED7 0x40
#define LED8 0x80

// consider for readability
#define FALSE 0
#define TRUE !FALSE

// define task states
#define IDLE       0
#define NORMAL     1
#define EMERGENCY  2

// change to 1 if using on working MSP430
#define TIME_SCALAR 0.25

// tracks which process has priority
volatile unsigned char current_task = IDLE;

// used to remeber wether normal call was running beofre emeergancy
volatile unsigned char normal_suspended = FALSE;

// remember how many ticks there were in timer if emergency
volatile unsigned int normal_timer_mem = 0;
// !!!!!!!!! TODO: Check whether this should be volatile since it is modified/read as part of interrupt-driven state changes. // ig just make it volatile

// this is the normal call state
// Keeps track of which normal LED is currently active.
//
// 0 = LED1
// 1 = LED2
// 2 = LED3
// 3 = LED4
volatile unsigned char S1_LED_state = 0;

// how many times has the system timer overflowed, needs an ISR, total time in ms = sys_timer_overflow * 15000 + TA0R * 0.244, prob type cast this to int to get whole number for print
volatile unsigned int sys_timer_overflow = 0;
// !!!!!!!!!!  TODO: The comment says ~15990.5 ms per overflow, but convert_timer() currently uses 15000 ms. These might need to match the acual TA0CCR0 timing. // this comment (above) was not updated, see initial() TA0 setup for more detail

// generic string to store the time string inside, note that maximum value will be 4,294,967,295 ms ~ 4,294,967 sec ~ 71,582 min ~ 1193 hours before unsigned long overflow
volatile char time[11] = {'0', '0', '0', '0', '0', '0', '0', '0', '0', '0', '\0'}; 
// TODO: Make sure convert_timer() always writes the final '\0'. printstr() relies on this to know where the string ends - debugging // final loop in convert timer only goes up to time[9] while leaving time[10] untouched, can always include time[10] = '\0' if wanted

volatile char print_idx = 0;

volatile char * print_str;

void printstr(volatile char * str) 
{
    print_str = str;
    print_idx = 0;

    UCA0TXBUF = print_str[print_idx];
    print_idx++;
    
    UCA0IE |= UCTXIE;

    _low_power_mode_0();

    // char i = 0;
    // while (str[i] != '\0') { // check if end of string
    //     UCA0TXBUF = str[i]; // load character into transmitter buffer
    //     while (UCA0STATW & UCBUSY); // check whether the transmitter is busy sending a char

    //     i++; // increment index
    // }
}

void convert_timer(volatile char final[11])
{
    // how do you convert a integer to its string representation without a standard library ???
    // !!!!!!!!!! TODO: Verify 15000 against the actual TA0CCR0 period TA0CCR0 and this calculation must represent the same amount of time, otherwise UART timestamps will drift............ // TA0CCR0 set to 61440 - 1 which at 4096 Hz ~ 61440/4096 = 15 sec
    unsigned long total_time_ms = ((unsigned long)sys_timer_overflow) * 15000 + (((unsigned long)TA0R * 1000)>>12); // maximum value of 4,294,967,295 ms note that 1000/4096 is just the time in ms for clock ticks, overflow issue here hence longs, >>12 is just /4096

    signed char idx;

    for (idx = 0; idx < 9; idx ++)
    {
        final[ 9 - idx ] = (total_time_ms % 10) + '0';
        total_time_ms = total_time_ms / 10;
    }
}

void initial()
{
    // hold watchdog
    WDTCTL = WDTPW + WDTHOLD;

    TA0CTL = 0x0000;
    TA1CTL = 0x0000;

    CSCTL0_H = CSKEY_H; // unlock CS
    CSCTL4 &= ~XT1OFF; // make sure XT1 is on
    CSCTL2 = SELA__XT1CLK | SELS__DCOCLK | SELM__DCOCLK; // ACLK source is XT1CLK ~ 32,768 Hz
    CSCTL3 &= ~(0x0700); // ACLK input divider /1
    CSCTL4 &= ~XT1DRIVE_3;
    CSCTL4 &= ~XTS;
    CSCTL0_H = 0;

    // timer 0
    TA0CTL &= ~MC_3; // turn the timer off to ensure stable config
    TA0CTL |= TASSEL_1; // ACLK
    TA0CTL |= ID_3; // /8 -> 4,096 Hz
    TA0CTL |= TACLR; // clear TA0R to start from known
   // Hannah TODO: Check the assignment requirements regarding Timer_A0..... 

    TA0CCR0 = 61439 * TIME_SCALAR; // the timer will overflow at ~ exactly 15 sec, note 61440 - 1 since up mode will count one extra tick before overflow flag // changed this due to comment in top of convert_timer
    TA0CCTL0 &= ~(CM_3 | CAP); // no capture
    TA0CCTL0 |= CCIE; // interrupt on control register enabled

    TA0CCTL1 &= ~(CM_3 | CAP);

    // turn timers on
    TA0CTL |= MC_1; // up mode

    // timer 1
    TA1CTL &= ~MC_3; // turn the timer off to ensure stable config
    TA1CTL |= TASSEL_1; // ACLK
    TA1CTL |= ID_3; // /8 -> 4,096 Hz
    TA1CTL |= TACLR; // clear TA0R to start from known

    TA1CCTL0 &= ~(CM_3 | CAP); // no capture

    // GPIO configs
    PJDIR = 0x0F;
    P3DIR = 0xF0;
    P4DIR = 0x00; // S1 and S2

    // enable pull up on buttons for active low
    P4REN |= BIT0 | BIT1;
    P4OUT |= BIT0 | BIT1;

    // interrupt on high to low
    P4IES |= BIT0 | BIT1;

    // clear existing interrupt flags
    P4IFG &= ~(BIT0 | BIT1);

    // reset LEDs to known value
    PJOUT &= ~( LED1 | LED2 | LED3 | LED4 );
    P3OUT &= ~( LED5 | LED6 | LED7 | LED8 );

    // UART settings, 9600 baud from 1 MHz DCO CLK
    P2SEL1 = BIT0 | BIT1; 
    UCA0CTL1 = UCSSEL_2 | UCSWRST;
    UCA0BRW = 6;
    UCA0MCTLW = 0x2081;
    UCA0CTL1 &= ~UCSWRST;

    // enable button interrupts
    P4IE |= BIT0 | BIT1;

    __bis_SR_register(GIE);

}

void main(void)
{

    initial();

    printstr("[ ");
    convert_timer(time);
    printstr(time);
    printstr(" ms ] EXITING STARTUP -> ENTERING IDLE\n\r");

    while(1)
    {
        __low_power_mode_0();
    }
}

#pragma vector = PORT4_VECTOR
__interrupt void button_ISR(void)
{
    // during this turn off during button interrupts, also note that GIE is turned off whenever inside a interrupt
    P4IE &= ~(BIT0 | BIT1);

    // remember which button has been pressed
    unsigned int port_interrupts = P4IFG;

    // unsigned int start = TA0R;
    // while ( (unsigned int)(TA0R - start) < 40 * 1/TIME_SCALAR ) // button debounce not sure how to change to not polling
    // {
    //     __no_operation();
    // }
    // ^^^: This is currently a blocking delay inside the button ISR The CPU cannot handle other interrupt work normally while this is running !
    // Consider changing the debounce to use timer-based timing maybeee // i know (im crine), im not sure how to change this to interrupt based

    unsigned int start = TA0R;
    TA0CCR1 = start + 120; // change this 120 to something more appropriate for 32 kHz
    if (TA0CCR1 > TA0CCR0)
    {
        TA0CCR1 = TA0CCR1 - (TA0CCR0 + 1);
    }
    TA0CCTL1 |= CCIE;
    __enable_interrupt();
    _low_power_mode_0();
    __disable_interrupt();
    TA0CCTL1 &= ~CCIE;

    // add a check to see if the button is still pressed?

    // change the state of timers i.e. load different values into TA1CCTL0 for TA0CCR0 interrupts to TIMER1_A0_VECTOR
    if ( ( port_interrupts & BIT1 ) ) // this will detect both cases of S2 alone and S1 with S2 giving S2 priority
    {

        switch ( current_task )
        {
            case IDLE:

                // turn off TA1
                TA1CTL &= ~MC_3;

                // disable TA1CCTL0 interrupts
                TA1CCTL0 &= ~CCIE;

                // reset TA1R
                TA1CTL |= TACLR;

                // if in idle and emergency task has been set
                current_task = EMERGENCY;

                // set up the correct timer values, in emergency need ~150 ms delay at 4096 Hz this is about 615 ticks
                TA1CCR0 = 615 * TIME_SCALAR;

                // do not set TA1CTL = TAIE since thats the overflow flag, i.e. not what is needed for up mode
                // enable interrupts from the capture/compare register
                TA1CCTL0 &= ~CCIFG;
                TA1CCTL0 |= CCIE;

                // turn on timer TA1 to up mode
                TA1CTL |= MC_1;

                // toggle LEDs to on, note not an XOR here, thats in the timer interrupt
                P3OUT |= LED5 | LED6 | LED7 | LED8;

                // UART logging
                __enable_interrupt();
                printstr("[ ");
                convert_timer(time);
                printstr(time);
                printstr(" ms ] S2 -> EMERGENCY CALL : EXIT IDLE\n\r");
                __disable_interrupt();

                break;

            case EMERGENCY:

                if ( normal_suspended )
                {
                    // turn off TA1
                    TA1CTL &= ~MC_3;
            
                    // disable TA1CCTL0 interrupts
                    TA1CCTL0 &= ~CCIE;

                    // reset TA1R, not strictly necessary because of later line
                    TA1CTL |= TACLR;

                    // case of emergency that did interrupt a normal call
                    current_task = NORMAL;

                    normal_suspended = FALSE;

                    // load the different interrupt time into capture/compare register, ~600  ms at 4096 Hz requires 2548 ticks
                    TA1CCR0 = 2458 * TIME_SCALAR;

                    // load the remembered time into the TA1R to continue from where the timer left off
                    TA1R = normal_timer_mem;

                    // enable TA1CCTL0 interrupts
                    TA1CCTL0 &= ~CCIFG;
                    TA1CCTL0 |= CCIE;

                    // turn on TA1
                    TA1CTL |= MC_1;

                    // turn off emergency LEDs
                    P3OUT &= ~(LED5 | LED6 | LED7 | LED8);

                    // UART logging
                    __enable_interrupt();
                    printstr("[ ");
                    convert_timer(time);
                    printstr(time);
                    printstr(" ms ] S2 -> EXIT EMERGENCY CALL : RESUME NORMAL CALL\n\r");
                    __disable_interrupt();

                }
                else // normal_suspended == FALSE
                {
                    // turn off TA1
                    TA1CTL &= ~MC_3;

                    // disable TA1CCTL0 interrupts
                    TA1CCTL0 &= ~CCIE;

                    // reset TA1R
                    TA1CTL |= TACLR;

                    // case of emergency that did not interrupt a normal call
                    current_task = IDLE;

                    TA1CCR0 = 0x0000;

                    // turn off LEDs
                    P3OUT &= ~(LED5 | LED6 | LED7 | LED8);

                    // UART logging
                    __enable_interrupt();
                    printstr("[ ");
                    convert_timer(time);
                    printstr(time);
                    printstr(" ms ] S2 -> EMERGENCY CALL COMPLETE\n\r");
                    __disable_interrupt();

                }

                break;

            case NORMAL:
                // turn off TA1
                TA1CTL &= ~MC_3;

                // record the stopped value
                normal_timer_mem = TA1R;

                // disable TA1CCTL0 interrupts
                TA1CCTL0 &= ~CCIE;

                // reset TA1R
                TA1CTL |= TACLR;

                // case of normal task being interrupted
                normal_suspended = TRUE;
                current_task = EMERGENCY;

                // load the different interrupt time into capture/compare register
                TA1CCR0 = 615 * TIME_SCALAR;

                // enable TA1CCTL0 interrupts
                TA1CCTL0 &= ~CCIFG;
                TA1CCTL0 |= CCIE;

                // turn on TA1
                TA1CTL |= MC_1;

                // turn on LEDs
                P3OUT |= LED5 | LED6 | LED7 | LED8;

                // UART logging
                __enable_interrupt();
                printstr("[ ");
                convert_timer(time);
                printstr(time);
                printstr(" ms ] S2 -> EMERGENCY CALL : SUSPEND NORMAL CALL\n\r");
                __disable_interrupt();

                break;

            default:
                break;
        }

        // if there was a switch 1 event at the same time as the switch 2 event ignore the switch 1 event
        P4IFG &= ~(BIT0 | BIT1);

    }
    else if ( port_interrupts & BIT0 )
    {
        // normal case, if both S1 and S2 then the previous if will have caught it and defaulted it to a emergency
        switch ( current_task )
        {
            case IDLE:
                // swap to normal operation
                // turn off TA1
                TA1CTL &= ~MC_3;

                // disable TA1CCTL0 interrupts
                TA1CCTL0 &= ~CCIE;

                // reset TA1R
                TA1CTL |= TACLR;

                // set current task
                current_task = NORMAL;

                // load normal interrupt time into capture/compare
                TA1CCR0 = 2458 * TIME_SCALAR;

                // enable TA1CCTL0 interrupts
                TA1CCTL0 &= ~CCIFG;
                TA1CCTL0 |= CCIE;

                // turn on TA1
                TA1CTL |= MC_1;

                // set the first LED and reset the LEDs state (note set to 1 because 0 is LED1 ON, which is done here)
                PJOUT = LED1;
                S1_LED_state = 1;

                // UART logging
                __enable_interrupt();
                printstr("[ ");
                convert_timer(time);
                printstr(time);
                printstr(" ms ] S1 -> NORMAL CALL : EXIT IDLE\n\r");
                __disable_interrupt();

                break;
            case NORMAL:
                // exit normal operation
                // turn off TA1
                TA1CTL &= ~MC_3;

                // disable TA1CCTL0 interrupts
                TA1CCTL0 &= ~CCIE;

                // reset TA1R
                TA1CTL |= TACLR;

                // set current task
                current_task = IDLE;

                // load nothing into the TA1CCTL0
                TA1CCR0 = 0x0000;

                // turn off all LEDs
                PJOUT &= ~(LED1 | LED2 | LED3 | LED4);

                // UART logging
                __enable_interrupt();
                printstr("[ ");
                convert_timer(time);
                printstr(time);
                printstr(" ms ] S1 -> NORMAL CALL COMPLETE\n\r");
                __disable_interrupt();

                break;
            case EMERGENCY:

                __no_operation();

                // S1 is intentionally ignored during an emergency because EMERGENNCY has priority over NORMAL
                // TODO: Confirm that the S1 interrupt flag is clleared corrrectly so that the ignored button press does not get processed after the emergency. // should be done by line 506 after the switch statement?

                // UART logging
                __enable_interrupt();
                printstr("[ ");
                convert_timer(time);
                printstr(time);
                printstr(" ms ] S1 -> NORMAL CALL IGNORED : EMERGENCY CALL ACTIVE\n\r");
                __disable_interrupt();

                break;
            default:
                break;
        }

        // clear the interrupt flag from S1
        P4IFG &= ~BIT0;

    }

    // after flags are set turn on button interrupts again
    P4IE |= BIT0 | BIT1;

}

#pragma vector = TIMER1_A0_VECTOR
__interrupt void timer1_ISR(void)
{
    // TA1CCTL0 -> TA1CCR0
    if ( current_task == NORMAL )
    {
        switch( S1_LED_state )
        {
            case 0:
                PJOUT = LED1;
                S1_LED_state++;
                break;
            case 1:
                PJOUT = LED2;
                S1_LED_state++;
                break;
            case 2:
                PJOUT = LED3;
                S1_LED_state++;
                break;
            case 3:
                PJOUT = LED4;
                S1_LED_state = 0;
                break;
            default:
                PJOUT &= ~(LED1 | LED2 | LED3 | LED4);
                S1_LED_state = 0;
                break;
        }
    }
    else if ( current_task == EMERGENCY )
    {
        P3OUT ^= (LED5 | LED6 | LED7 | LED8);
    }
    else
    {
        __no_operation();
    }

    TA1CCTL0 &= ~CCIFG;
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer0_ISR(void)
{
    // exclusively for system timer overflows
    sys_timer_overflow++;

    TA0CCTL0 &= ~CCIFG;
}

#pragma vector = TIMER0_A1_VECTOR
__interrupt void timer0_A1_ISR(void)
{
    __bic_SR_register_on_exit(LPM0_bits);

    TA0CCTL1 &= ~CCIFG;
}

#pragma vector = USCI_A0_VECTOR
// interrupt for when the transmitter buffer is empty
// need to enable the UCA0IE |= UCTXIE
__interrupt void UART_ISR(void)
{
    if ( print_str[print_idx] != '\0' )
    {
        UCA0TXBUF = print_str[print_idx];
        print_idx++;
    }
    else
    {
        UCA0IE &= ~UCTXIE;
        __bic_SR_register_on_exit(LPM0_bits);
    }
}
