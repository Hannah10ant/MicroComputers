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
// #define FALSE 0
// #define TRUE !FALSE

// define task states
#define IDLE       0
#define NORMAL     1
#define EMERGENCY  2

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
volatile unsigned char normal_suspended = 0;

// these are the button event flags
// These are set by the PORT4 interrupt.
volatile unsigned char S1_event = 0;
volatile unsigned char S2_event = 0;

// this is the normal call state
// Keeps track of which normal LED is currently active.
//
// 0 = LED1
// 1 = LED2
// 2 = LED3
// 3 = LED4
volatile unsigned char S1_state = 0;

// this is the emergancy call state
// 0 = emergency LEDs OFF
// 1 = emergency LEDs ON
volatile unsigned char emergency_leds_on = 0;

// timer varibles
// System time in milliseconds
volatile unsigned long system_ms = 0;

// Time spent on the current normal LED
volatile unsigned int normal_timer = 0;

// Time spent since the emergency LEDs last changed state
volatile unsigned int emergency_timer = 0;

void main(void)
{
	
	WDTCTL = WDTPW + WDTHOLD; // hold watchdog

	// timer config
	TA0CTL = 0x00;

	TA0CTL |= TASSEL_1;     // ACLK
    TA0CTL |= ID_3;         // Input divider /8
    TA0CTL |= TACLR;        // Clear timer
    TA0CTL |= MC_1;         // Up mode // do note this will count to the value in TA0CCR0 which is used as the "system timer" (not sure what is meant by that though)
                                       // also consider moving this the the button ISR and setting this to &= ~MC_3, read note on line 301

	TA0CCR0 = 40;           // Approximately 10 ms // in up mode the TA0R will be reset to zero once this many + 1 have been counted, see figure 11-2 in SLAU272D, also include a "10 ms (at x CLK freq)"

    // Enable interrupt for TA0CCR0
    TA0CCTL0 |= CCIE;

	// select the source for ACLK to be XT1CLK ~ 32 kHz, AND mask op since XT1CLK is 000b
	CSCTL2 &= ~SELA_7;

	// select the input divider for the ACLK to be /1, TA0CTL now has 4.096 kHz / 1 ~ 4.096 kHz
	CSCTL3 &= ~(0x0700) // need to use 0x0700 here because 0b0000011100000000 is not a standard macro for the CSCTL3 register DIVA bits // alternatively reuse the SELA_7 macro
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

	__bis_SR_register(GIE); // enable general interrupts


	while(1) {

        // S2 HAS PRIORITY OVER S1
        //
        // If both events happen at approximately the same
        // time, S2 is processed first. // first thing i notice is that this is very different to how i did mine lol
        //

        if (S2_event)
        {
            S2_event = 0;

			// S2 while IDLE

            if (current_task == IDLE)
            {
                // Start emergency call
                current_task = EMERGENCY;

                normal_suspended = 0;

                emergency_timer = 0;

                emergency_leds_on = 1;

                // Turn ON LED5-LED8 together
                P3OUT = LED5 | LED6 | LED7 | LED8;
            }
			// S2 while NORMAL

            else if (current_task == NORMAL)
            {
                // Suspend normal task
                normal_suspended = 1;

                // normal_timer is NOT reset.
                // S1_state is NOT reset.
                // Therefore the normal call can resume from the same LED and remaining time.

                current_task = EMERGENCY;

                emergency_timer = 0;

                emergency_leds_on = 1;

                // Start emergency LEDs ON
                P3OUT = LED5 | LED6 | LED7 | LED8;
            }
            // S2 while EMERGENCY

            else if (current_task == EMERGENCY)
            {
                // A second S2 acknowledges the /* (end of) */ emergency call

                emergency_leds_on = 0;
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

                    normal_suspended = 0;
                }
                else
                {
                    // Emergency started while idle,
                    // so return to idle.
                    current_task = IDLE;

                    PJOUT = 0x00;
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
            S1_event = 0;

            // S1 while IDLE


            if (current_task == IDLE)
            {
                // Start normal call
                current_task = NORMAL;

                S1_state = 0;

                normal_timer = 0;

                // Start at LED1
                PJOUT = LED1;
            }


            // S1 while NORMAL

            else if (current_task == NORMAL)
            {
                // Second S1 acknowledges/completes
                // the normal call.

                current_task = IDLE;

                normal_timer = 0;

                S1_state = 0;

                // Turn OFF normal LEDs
                PJOUT = 0x00;
            }

            // S1 while EMERGENCY


            else if (current_task == EMERGENCY)
            {
                // S1 must be ignored while emergency is active.

                // ------------------------> UART logging for this event will be added later.
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

#pragma vector = TIMER0_A0_VECTOR
__interrupt void Timer_A0_ISR(void)
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