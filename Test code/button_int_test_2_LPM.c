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

volatile char state = 0;

void main(void)
{
     // hold watchdog
    WDTCTL = WDTPW + WDTHOLD;

    // doing this up here for debug purposes
    PJDIR = 0x0F;
    P3DIR = 0xF0;

    PJOUT &= ~( LED1 | LED2 | LED3 | LED4 );
    P3OUT |= ( LED5 | LED6 | LED7 | LED8 );

    // TA0CTL = 0x0000;
    // TA1CTL = 0x0000;

    // CSCTL2 &= ~SELA_7; // ACLK source is XT1CLK ~ 32,768 Hz
    // CSCTL3 &= ~(0x0700); // ACLK input divider /1

    // timer 0
    // TA0CTL &= ~MC_3; // turn the timer off to ensure stable config
    // TA0CTL |= TASSEL_1; // ACLK
    // TA0CTL |= ID_3; // /8 -> 4,096 Hz
    // TA0CTL |= TACLR; // clear TA0R to start from known
   // Hannah TODO: Check the assignment requirements regarding Timer_A0..... 

    // TA0CCR0 = 61439; // the timer will overflow at ~ exactly 15 sec, note 61440 - 1 since up mode will count one extra tick before overflow flag // changed this due to comment in top of convert_timer
    // TA0CCTL0 &= ~(CM_3 | CAP); // no capture
    // TA0CCTL0 |= CCIE; // interrupt on control register enabled

    // TA0CTL |= MC_1; // up mode

    // // timer 1
    // TA1CTL &= ~MC_3; // turn the timer off to ensure stable config
    // TA1CTL |= TASSEL_1; // ACLK
    // TA1CTL |= ID_3; // /8 -> 4,096 Hz
    // TA1CTL |= TACLR; // clear TA0R to start from known

    // TA1CCTL0 &= ~(CM_3 | CAP); // no capture

    // GPIO configs
    // PJDIR = 0x0F;
    // P3DIR = 0xF0;
    P4DIR = 0x00; // S1 and S2

    // enable pull up on buttons for active low
    P4REN |= BIT0 | BIT1;
    P4OUT |= BIT0 | BIT1;

    // interrupt on high to low
    P4IES |= BIT0 | BIT1;

    // clear existing interrupt flags
    P4IFG &= ~(BIT0 | BIT1);

    // reset LEDs to known value
    // PJOUT &= ~( LED1 | LED2 | LED3 | LED4 );
    // P3OUT &= ~( LED5 | LED6 | LED7 | LED8 );

    // UART settings, 9600 baud from 1 MHz DCO CLK
    // P2SEL1 = BIT0 | BIT1; 
    // UCA0CTL1 = UCSSEL_2 | UCSWRST;
    // UCA0BRW = 6;
    // UCA0MCTLW = 0x2081;
    // UCA0CTL1 &= ~UCSWRST;

    // enable button interrupts
    P4IE |= BIT0 | BIT1;

    __bis_SR_register(GIE);

    while ( 1 )
    {
        __low_power_mode_0();
    }
}

#pragma vector = PORT4_VECTOR
__interrupt void button_ISR(void)
{
    switch ( state )
    {
        case 0:
            PJOUT ^= LED1;
            P3OUT ^= LED8;
            state++;
            break;
        case 1:
            PJOUT ^= LED2;
            P3OUT ^= LED7;
            state++;
            break;
        case 2:
            PJOUT ^= LED3;
            P3OUT ^= LED6;
            state++;
            break;
        case 3:
            PJOUT ^= LED4;
            P3OUT ^= LED5;
            state++;
            break;
        default:
            break;
    }

    P4IFG &= ~(BIT1 | BIT0);
}
