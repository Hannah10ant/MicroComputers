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

// functions prototypes for UART printing (note they need to be uncommented at the end of the file)
void printstr(char * str);
void printend();
void convert_timer(char final[12]);

// do you want me (not hannah) to correct any of your comment spelling mistakes? they do provide character to the comments
// also some of the comments i (not hannah) leave are just me pointing out potential side effects or keeping track of what the code is doing
// will leave my comments as // comments where possible

// (after reading through) i believe you do not turn on TA0CTL |= TAIE on at any point so that TIMER0_A0_VECTOR never gets requested (might be wrong) ...
// other than that i dont see a problem with the actual logic, looks good, just running through so many if statements (if else chains will set me free) and also ...
// in essence polling the timer through interrupts where we could be sitting in LPM0 (during the ISR) while waiting for the very long (computer time) delays seems, uhh, not good, LMP0 has a wake up time ... 
// of typical 0.58 micro secs so that wouldnt affect the actual delay between LED switching to use measly humans.
// TLDR : looks fine (i still want to try make a version that runs off of timer interrupts by myself on the side though)

// tracks which process has priority
volatile unsigned char current_task = IDLE;

// used to remeber wether normal call was running beofre emeergancy
volatile unsigned char normal_suspended = FALSE;

// these are the button event flags
// These are set by the PORT4 interrupt.
volatile unsigned char S1_event = FALSE;
volatile unsigned char S2_event = FALSE;

// this is the normal call state
// Keeps track of which normal LED is currently active.
//
// 0 = LED1
// 1 = LED2
// 2 = LED3
// 3 = LED4
volatile unsigned char S1_state = 0;

// this is the emergancy call state
//
// 0 = emergency LEDs OFF
// 1 = emergency LEDs ON
volatile unsigned char emergency_leds_on = FALSE;

// timer varibles
// System time in milliseconds
volatile unsigned long system_ms = 0;

// Time spent on the current normal LED
volatile unsigned int normal_timer = FALSE;

// Time spent since the emergency LEDs last changed state
volatile unsigned int emergency_timer = FALSE;

// how many times has the system timer overflowed, needs an ISR, total time in ms = sys_timer_overflow * 15990.5 + TA0R * 0.244, prob type cast this to int to get whole number for print
volatile unsigned int sys_timer_overflow = 0;

// a lot of strings to print the UART message using printstr(), note these do not include the "[ time ms", also just pass these directly into the printstr() instead of initializing a string
// " ] S2 -> EMERGENCY CALL : EXIT IDLE\n";
// " ] S2 -> EMERGENCY CALL : SUSPEND NORMAL CALL\n";
// " ] S2 -> EXIT EMERGENCY CALL : RESUME NORMAL CALL\n";
// " ] S2 -> EMERGENCY CALL COMPLETE\n";
// " ] S1 -> NORMAL CALL : EXIT IDLE\n";
// " ] S1 -> NORMAL CALL COMPLETE\n";
// " ] S1 -> NORMAL CALL IGNORED : EMERGENCY CALL ACTIVE\n"

void main(void)
{    
    WDTCTL = WDTPW + WDTHOLD; // hold watchdog

    // timer config
    TA0CTL = 0x00;
    TA1CTL = 0x00;

    TA0CTL |= TASSEL_1;     // ACLK
    TA1CTL |= TASSEL_1;     // ^
    TA0CTL |= ID_3;         // Input divider /8 -> 32768 / 8 = 4096 Hz
    TA1CTL |= ID_3;         // ^
    TA0CTL |= TACLR;        // Clear timer
    TA1CTL |= TACLR;        // ^
    TA0CTL |= MC_2;         // continuous mode, will interrupt when overflowing, overflow at 0xFFFF = 65535, at 4096 Hz => 0.244 ms, 65535 * 0.244 ~ 15990.5 ms
    TA1CTL &= ~MC_3;        // turn the 10 ms timer off, so it doesnt break out of LPM before button ISR
    // TA1CTL |= MC_1;         // up mode, this is here to remind of general config after button ISR

    TA1CCR0 = 41;           // Approximately 10 ms at 4096 Hz -> 1/4096 * 41 = 0.01000976 note: prev was 40 -> 1/4096 * 40 = 0.009765 slightly further away from 10 ms, change back if care about overstep

    // enable timer interrupts
    TA0CTL |= TAIE;
    TA1CTL |= TAIE;

    // Enable interrupt for TA0CCR0
    TA0CCTL0 |= CCIE;
    TA1CCTL0 |= CCIE;

    // select the source for ACLK to be XT1CLK ~ 32 kHz, AND mask op since XT1CLK is 000b
    CSCTL2 &= ~SELA_7;

    // select the input divider for the ACLK to be /1, TA0CTL now has 4.096 kHz / 1 ~ 4.096 kHz
    CSCTL3 &= ~(0x0700); // need to use 0x0700 here because 0b0000011100000000 is not a standard macro for the CSCTL3 register DIVA bits // alternatively reuse the SELA_7 macro
    CSCTL3 |= DIVA_0; // can remove this line since the prev line already clears the DIVA bits so /1 is selected, but for clarity leave it in

    //GPIO config
    // PJ.0 - PJ.3 = LED1 - LED4
    PJDIR = 0x0F;

    // P3.4 - P3.7 = LED5 - LED8
    P3DIR = 0xF0;

    // P4.0 = S1
    // P4.1 = S2
    P4DIR = 0x00;

    // buton configs 
    // Enable pull-up resistors for active-low buttons
    P4REN |= BIT0 | BIT1;
    P4OUT |= BIT0 | BIT1;

    // Interrupt on high-to-low transition
    // This corresponds to the buttons being active-low.
    P4IES |= BIT0 | BIT1;

    // Clear any existing interrupt flags
    P4IFG &= ~(BIT0 | BIT1);

    // Enable S1 and S2 interrupts
    P4IE |= BIT0 | BIT1;

    // initalisze
    // All LEDs OFF
    PJOUT = 0x00;
    P3OUT = 0x00;


    // UART settings, same settings as lab 4 so 9600 baud, 8 data bits, no parity, 1 stop bit
    P2SEL1 = BIT0 | BIT1; 
    UCA0CTL1 = UCSSEL_2 | UCSWRST;
    UCA0BRW = 6;
    UCA0MCTLW = 0x2081;
    UCA0CTL1 &= ~UCSWRST;

    __bis_SR_register(GIE); // enable general interrupts


    while(1) {

        // S2 HAS PRIORITY OVER S1
        //
        // If both events happen at approximately the same
        // time, S2 is processed first. // first thing i notice is that this is very different to how i did mine lol
        //

        if (S2_event)
        {
            S2_event = FALSE;

            // S2 while IDLE

            if (current_task == IDLE)
            {
                // Start emergency call
                current_task = EMERGENCY;

                normal_suspended = FALSE;

                emergency_timer = 0;

                emergency_leds_on = TRUE;

                // Turn ON LED5-LED8 together
                P3OUT = LED5 | LED6 | LED7 | LED8;

                // ---------------------------------------- print ---> [ time ms ] S2 -> EMERGENCY CALL : EXIT IDLE\n

            }
            // S2 while NORMAL

            else if (current_task == NORMAL)
            {
                // Suspend normal task
                normal_suspended = TRUE;

                // normal_timer is NOT reset.
                // S1_state is NOT reset.
                // Therefore the normal call can resume from the same LED and remaining time.

                current_task = EMERGENCY;

                emergency_timer = 0;

                emergency_leds_on = TRUE;

                // Start emergency LEDs ON
                P3OUT = LED5 | LED6 | LED7 | LED8;

                // ---------------------------------------- print ---> [ time ms ] S2 -> EMERGENCY CALL : SUSPEND NORMAL CALL\n

            }
            // S2 while EMERGENCY

            else if (current_task == EMERGENCY)
            {
                // A second S2 acknowledges the /* (end of) */ emergency call

                emergency_leds_on = FALSE;
                emergency_timer = 0;

                // Turn OFF emergency LEDs
                P3OUT = 0x00;

                // If a normal call was suspended
                // resume it
                if (normal_suspended)
                {
                    current_task = NORMAL;

                    // Restore the normal LED that was active
                    switch(S1_state)
                    {
                        case 0:
                            PJOUT = LED1;
                            break;

                        case 1:
                            PJOUT = LED2;
                            break;

                        case 2:
                            PJOUT = LED3;
                            break;

                        case 3:
                            PJOUT = LED4;
                            break;

                        default:
                            S1_state = 0;
                            PJOUT = LED1;
                            break;
                    }

                    // not reseting normal_timer.
                    //
                    // The normal task resumes with the amount
                    // of time that remained before the
                    // emergency occurred.

                    normal_suspended = FALSE;

                    // ---------------------------------------- print ---> [ time ms ] S2 -> EXIT EMERGENCY CALL : RESUME NORMAL CALL\n

                }
                else
                {
                    // Emergency started while idle,
                    // so return to idle.
                    current_task = IDLE;

                    // since return to idle turn off 10 ms timer
                    TA1CTL &= ~MC_3;

                    PJOUT = 0x00;

                    // ---------------------------------------- print ---> [ time ms ] S2 -> EMERGENCY CALL COMPLETE\n

                }
            }
        }

        // S1 EVENT

        // S1 is only processed after S2.
        //
        // This means that if both S1 and S2 events are
        // waiting, the emergency event gets priority.
        //

        if (S1_event)
        {
            S1_event = FALSE;

            // S1 while IDLE


            if (current_task == IDLE)
            {
                // Start normal call
                current_task = NORMAL;

                S1_state = 0;

                normal_timer = 0;

                // Start at LED1
                PJOUT = LED1;

                // ---------------------------------------- print ---> [ time ms ] S1 -> NORMAL CALL : EXIT IDLE\n

            }


            // S1 while NORMAL

            else if (current_task == NORMAL)
            {
                // Second S1 acknowledges/completes
                // the normal call.

                current_task = IDLE;

                normal_timer = 0;

                S1_state = 0;

                // turn off the 10 ms timer
                TA1CTL &= ~MC_3;

                // Turn OFF normal LEDs
                PJOUT = 0x00;

                // ---------------------------------------- print ---> [ time ms ] S1 -> NORMAL CALL COMPLETE\n

            }

            // S1 while EMERGENCY


            else if (current_task == EMERGENCY)
            {
                // S1 must be ignored while emergency is active.

                // ---------------------------------------- print ---> [ time ms ] S1 -> NORMAL CALL IGNORED : EMERGENCY CALL ACTIVE\n

            }
        }


        // ENTER LOW POWER MODE
        // CPU sleeps here until an interrupt occurs.
        // Timer_A0, running from ACLK, can continue operating.

        __low_power_mode_0(); // runs entire while(1) loop once, then falls asleep, while(1) loop is checking which case we are in and setting variables to whatever is needed on the button cases
                              // since you have not turned off timer interrupts during this (that i can see) the timer ISR will break out of this LPM and rerun the if statements above ~ every 10 ms, consider turning off timer until button ISR
                              // alternatively (just thought of this after insta msg) we could use LPM4 here instead since that turns off ACLK so that the interrupt doesnt happen, but of course the interrupt every 10 ms method wouldnt work then
    }


    return 0;
}

// this is were im the most unsure - but using this methood means the most coding is done above yes? // well, yes...
#pragma vector = PORT4_VECTOR
__interrupt void button_ISR(void)
{
    switch(P4IV)
    {
        // S1
        case P4IV_P4IFG0:

            S1_event = 1;

            break;

        // s2
        case P4IV_P4IFG1:

            S2_event = 1;

            break;

        // else

        default:

            break;
    }

    // if button ISR turn on the 10 ms clock
    TA1CTL |= MC_1;
}



/// TIMER_A0 CCR0 INTERRUPT
//
// Timer_A0 generates approximately one interrupt every 10 ms. 
// This gives us a common system clock for:
//
//     - millisecond timing
//     - normal LED timing
//     - emergency LED timing
//     - future button debouncing
//
// No blocking while-loops are required.

#pragma vector = TIMER1_A0_VECTOR // changed the 10 ms timer to timer 1 so this vector needed to be changed
__interrupt void Timer1_A0_ISR(void)
{

    // SYSTEM TIME

    system_ms += 10;

    // NORMAL CALL TIMER

    if (current_task == NORMAL)
    {
        normal_timer += 10;


        // Normal LED changes every 500 ms
        if (normal_timer >= 500)
        {
            normal_timer = 0;


            // Move to next normal LED

            switch(S1_state)
            {
                case 0:

                    // LED1 -> LED2
                    PJOUT = LED2;

                    S1_state = 1;

                    break;


                case 1:

                    // LED2 -> LED3
                    PJOUT = LED3;

                    S1_state = 2;

                    break;


                case 2:

                    // LED3 -> LED4
                    PJOUT = LED4;

                    S1_state = 3;

                    break;


                case 3:

                    // LED4 -> LED1
                    PJOUT = LED1;

                    S1_state = 0;

                    break;


                default:

                    S1_state = 0;

                    PJOUT = LED1;

                    break;
            }
        }
    }

    // EMERGENCY CALL TIMER

    if (current_task == EMERGENCY)
    {
        emergency_timer += 10;


        // Emergency LEDs change every 100 ms
        if (emergency_timer >= 100)
        {
            emergency_timer = 0;


            // Toggle all four emergency LEDs together

            if (emergency_leds_on)
            {
                // Turn them OFF
                P3OUT = 0x00;

                emergency_leds_on = 0;
            }
            else
            {
                // Turn them ON
                P3OUT = LED5 | LED6 | LED7 | LED8;

                emergency_leds_on = 1;
            }
        }
    }
}

#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer0_A0_ISR(void)
{
    // dont think there is anything else to do in here?
    sys_timer_overflow++;
}

// new structure!
// S1/S2 press
//
// PORT4 ISR
//
// set event flag
//
// return from ISR
//
// scheduler processes event


// generic UART functions for printing

void printstr(char * str) 
{
    char i = 0;
    while (str[i] != '\0') { // check if end of string
        UCA0TXBUF = str[i]; // load character into transmitter buffer
        while (UCA0STATW & UCBUSY); // check whether the transmitter is busy sending a char

        i++; // increment index
    
    }
}

void printend() 
{
    UCA0TXBUF = 0x0A; // 0x0A is '\n' i.e. print a newline on the output
    while (UCA0STATW & UCBUSY); // wait for this to be sent

    UCA0TXBUF = 0x0D; // 0x0D is '\r' carrige return, goes back to the start of the newline 
    while (UCA0STATW & UCBUSY); // wait for this to be sent
}


// big mostly commented function
void convert_timer(char final[12])
{
    // how do you convert a integer to its string representation without a standard library ???
    unsigned long total_time_ms = sys_timer_overflow * 15990.5 + TA0R * 0.244; // maximum value of 4,294,967,295 ms

    // 0 in ascii is 48
    // 1 in ascii is 49 etc...

    // if i have 2468
    // do 2468 % 10 = 8 then 2468 / 10 = 246
    // do 246 % 10 = 6 then 246 / 10 = 24
    // do 24 % 10 = 4 then 24 / 10 = 2
    // do char str[] = {'0' + 2, '0' + 4, '0' + 6, '0' + 8, '\0'}

    signed char idx;

    for (idx = 0; idx < 10; idx ++)
    {
        final[ 10 - idx ] = (total_time_ms % 10) + '0';
        total_time_ms = total_time_ms / 10;
    }

    // not a good strategy, msp does not have a inbuilt % operator, and TI suggests avoiding / or % entirely
    // the other thing i found was double dabble, more complex, but apparently cheaper on hardware

    // also can maybe get some sort of lookup table implementation, but everything past the above im out of my depth





    // // double dabble algorithm (yes thats the actual name)
    // // initialize some array for the scratch space
    // // maximum number of characters is 10 * 4 bits per character + 32 bits for total time = 72 bits = 9 bytes
    // unsigned char scratch[9] = {0, 0, 0, 0, 0, 0, 0, 0, 0};

    // // lower 2 bytes
    // scratch[8] = total_time_ms & 0xFF;
    // total_time_ms >>= 8;
    // scratch[7] = total_time_ms & 0xFF;
    // total_time_ms >>= 8;
    // // upper 2 bytes
    // scratch[6] = total_time_ms & 0xFF;
    // total_time_ms >>= 8;
    // scratch[5] = total_time_ms & 0xFF;
    // // total_time is now loaded into the upper elements of the array

    // signed char idx;
    // signed char odx;

    // // need to keep track of the byte thats one lower to get correct shifting
    // unsigned char carry_in = 0;
    // unsigned char carry_out = 0;

    // char lower_nibble;
    // char upper_nibble;

    // while ( (scratch[8] != 0x00) ||
    //         (scratch[7] != 0x00) ||
    //         (scratch[6] != 0x00) ||
    //         (scratch[5] != 0x00) )
    // {

    //     for (odx = 0; odx < 5; odx++)
    //     {
    //         // check lower nibble
    //         lower_nibble = scratch[odx] & 0x0F;
    //         if (lower_nibble >= 5)
    //         {
    //             scratch[odx] += 0x03;
    //         }
            
    //         // check upper nibble
    //         upper_nibble = (scratch[odx] >> 4) & 0x0F;
    //         if (upper_nibble >= 5)
    //         {
    //             scratch[odx] += 0x30;
    //         }
    //     }

    //     carry_in = 0;
    //     for (idx = 8; idx >= 0; idx--)
    //     {
    //         carry_out = scratch[idx] & 0x80; // is the top bit set, important for carrying over to next byte
    //         carry_out >>= 7; // place the previous top bit to bottom bit
    //         scratch[idx] = (scratch[idx] << 1) | carry_in; // shift the byte one left and replace the lowest bit with the highest bit of the previous byte
    //         carry_in = carry_out;
    //     }
    // }

    // // scratch[0 - 4] now holds all the values in "decimal"
    // for (idx = 0; idx < 5; idx++)
    // {
    //     lower_nibble = scratch[idx] & 0x0F;
    //     upper_nibble = scratch[idx] >> 4;

    //     final[ 2 * idx ] = upper_nibble + '0';
    //     final[ (2 * idx) + 1 ] = lower_nibble + '0';
    // }
}


// for timer interrupts:

// the timer A0 and timer A1 (configured via TA0CTL and TA1CTL, both should have the same settings) 
// can set a compare interrupt flag (note below is not functional code, just which bits to set where BIT = 1 and ~BIT = 0)

// TIMER0_A1_VECTOR is the interrupt vector which captures TA0CCR1 CCIFG1, TA0CCR2 CCIFG2, and TA0IFG (from MSP430FR573x Mixed-Signal Microcontrollers document SLAUS639L)
// note (informative not necessarily useful): TIMER0_A0_VECTOR is for the interrupt from TA0CCR0 CCIFG0 (also from MSP430FR573x Mixed-Signal Microcontrollers document SLAUS639L)
// TIMER1_A1_VECTOR is the interrupt vector which captures TA1CCR1 CCIFG1, TA1CCR2 CCIFG2, and TA1IFG
// you can tell by looking at the interrupt vector table and checking the word address of the interrupt and line that up with the macro
// i.e. TIMER0_A1_VECTOR = 0xFFE8 and TIMER1_A1_VECTOR = 0xFFE0

// TA0CTL = TAIE // set interrupts enabled, note that TA0CTL = TAIFG is the flag thats set when interrupt happens, covered by TIMER0_A1_VECTOR
// TA1CTL = TAIE // ^^
// TA0CCTLn = ~CM // do not want a capture mode, also n here is for either 1 or 2, to keep it simple i suggest using 1 only for both timer A0 and timer A1
// TA1CCTLn = ~CM // ^^
// TA0CCTLn = ~CAP // do not want a capture mode, this will select compare mode
// TA1CCTLn = ~CAP // ^^
// TA0CCTLn = CCIE // do want interrupts from the compare register
// TA1CCTLn = CCIE // ^^
// CCIFG // when set an interrupt will be pending, will be set by the register TAxCCTL itself and trigger TIMER0_A1_VECTOR or TIMER1_A1_VECTOR
// TAxCCRn // holds the compare value for the TAxCCTLn register, write into this the value that should trigger an interrupt
// 		// for 600 ms count up should be 0x099A, if 150 ms count up should be 0x0267
//      // also note that for TA1 we could use up mode instead of continuous mode and set TA1CCR0 = 0x099A or 0x0267 to get overflow interrupt, cannot do this on TA0 since TA0CCR0 is the system timer
// 		// not sure about the == of this, i.e. if a simple set TA0R = (0xFFFF - 0x0267) and check for overflow via TA0CTL = TAIFG flag would be better
// 		// distinguishing between the timers should be simple given two different interrupt vectors
// 		// since the normal call should stop when a emergency call occurs, would need to stop the timer A0 with TA0CTL &= ~MC_3 (just noticed i that wrote that wrong in main)
// 		// this would replace the while((TA0R < number)) in the button_ISR, switch statement would need to go into the timer ISR
// 		// the while followed by switch could should be swapped for a __low_power_mode_3(); LPM3 has CPU, MCLK, SMCLK, DCO disabled but ACLK still active
// 		// would have to look at errata but maybe add a __no_operation after entering LPM3 so that it doesnt accidentally reset the counting register?


// short thing i noticed while writing the procedure section for lab 4, the UCAxCTLW0 register resets to 0x0001 on start-up
// this is with the software reset enabled, so if you dont config anything you still need to switch this to 0 to let you do UART or any other serial comms

// below are the interrupt vectors for the two different timers

// timer0 interrupt vector, see above for deets
// #pragma vector = TIMER0_A1_VECTOR
// __interrupt void Timer_A1_ISR(void) {

// }

// timer1 interrupt vector, see above for deets
// #pragma vector = TIMER1_A1_VECTOR
// __interrupt void Timer_A0_ISR(void) {

// }
