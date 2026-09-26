#include "msp430fr5739.h"

#define LED1 0x01
#define LED2 0x02
#define LED3 0x04
#define LED4 0x08

#define LED5 0x10
#define LED6 0x20
#define LED7 0x40
#define LED8 0x80

// should we intricude a task state..?
// #define IDLE 0
// #define NORMAL 1
// #define EMERGENCY 2
// volatile unassigned char current_task = IDLE;

// switch 1 state, keeps track of which LEDs to turn on
char S1_state;

// switch 2 state, keeps track of which LEDs to turn on
char S2_state;

void main(void)
{
	
	WDTCTL = WDTPW + WDTHOLD; // hold watchdog

	// timer config
	TA0CTL = 0x00;

	// want the timer from ACLK to be out of the way, also will want to configure ACLK to be sourced from XT1CLK ~ 32.768 kHz since i need 0.5 sec delays
	TA0CTL |= TASSEL_1;

	// input divider to /8 again slow delays, 32.768 kHz / 8 ~ 4.096 kHz note this will be changed again later to be slower again 
	TA0CTL |= ID_3;

	// set the mode control to stop the timer, and start the timer again when needing a delay
	TA0CTL &= ~MC_3; // already updated this in main (accidentally), so check the note there for why

	// select the source for ACLK to be XT1CLK ~ 32 kHz, AND mask op since XT1CLK is 000b
	CSCTL2 &= ~SELA_7;

	// select the input divider for the ACLK to be /1, TA0CTL now has 4.096 kHz / 1 ~ 4.096 kHz
	CSCTL3 &= ~(0x0700) // need to use 0x0700 here because 0b0000011100000000 is not a standard macro for the CSCTL3 register DIVA bits
	CSCTL3 |= DIVA_0; // can remove this line since the prev line already clears the DIVA bits so /1 is selected, but for clarity leave it in

	// configure outputs and inputs
	PJDIR = 0x0F; // lower nibble for PJ
	P3DIR = 0xF0; // upper nibble for P3
	P4DIR = 0x00; // buttons are inputs, 0 is used for inputs

	__bis_SR_register(GIE); // enable general interrupts

	P4IE |= BIT0 | BIT1; // enable interrupts from port 4

	while(1) {
		// ------------- NOTES: If you're using ACLK/Timer_A0 to generate timing events, putting the CPU into a mode that stops the relevant clocks means the timer cannot operate expecctedly? no?
		// ------------- Assigment would suggest LPM0 - if we want to keep LPM4, needs to be justifies

		__low_power_mode_4(); // use LMP4 because this disables all the clock sources, since we are not using a clock based interrupt to init anything
	
	}


	return 0;
}

#pragma vector = PORT4_VECTOR
__interrupt void button_ISR(void) {
	switch(P4IV) {
		case P4IV_P4IFG0:
			// button debouncing, not sure how i would do this
			
			S1_state = 0;
			// S1 case
			// normal call
			// turn off interrupts from S1 during operation
			P4IE &= ~BIT0;			
			// turn on GIE, it turns off automatically when entering an interrupt
			__bis_SR_register(GIE);

			// NOTES: wouldn't this mean 'when S1 interupt is not set' ? and if so, that wouldnt make sense bc the interupt happend because it WAS set?
			// erics note : first sorry for updating main instead of dev branch (im confused, also ignore that pull request, i thought thats how i get the other branch), ...
			//              check the discussions.txt i made there (main branch), can also just put that files contents at the end of this file?
			//              yes this is supposed to mean 'when S1 interrupt is not set', when an interrupt occurs the P4IV gets reset (will get back to this in a sec) and the P4IFG.0 gets reset ...
			//              they have an example right above section 8.2.6.1 in SLAU272D, and then we turn off P4IE so that P4IFG does not execute another interrupt, since we only...
			//              want to break out of the ISR when S1 gets pressed again we have to check something to see if it gets pressed again, and i saw that the P4IFG.0 gets set even when P4IE.0 = 0 ...
			//              so we can use that to check if its been hit again by checking if the interrupt flag has been set
			//              back to the P4IV, im not sure if the board reading its own P4IV to see where the interrupt vector is will reset it (i.e. entering the __interrupt void button_ISR() ), so that the switch case always sees 0 ...
			//              the user guide doesnt say anything in that regard, so im not sure. much text
			while(!(P4IFG & BIT0)) { // when P4IFG = 0x0000 (dont need to consider P4IFG = 0x0001 since this is an ISR) then & 0x0001 = 0, then when its set its 0x0001

				TA0CTL |= TACLR; // clears TA0R to count from 0 again
				
				// ------------- NOTES: currently this section is Polling
				// ------------- Change to interupt

				TA0CTL |= MC_2; // counter starts counting up contiuously 
				// change this eventually to a interrupt based thing? the switch statement would have to be in the interrupt? can use timer A1 for S2 instead of timer A0 to resolve between the two?
				while((TA0R < 0x099A)); // TA0 is counting at 4.096 kHz, for a ~600 ms delay want to count to 4096*0.6 = 2458 = 0x099A

				switch(S1_state) {
					case 0:
						// turn on LED1 and turn off LED2-4
						PJOUT = LED1;
						S1_state++;

						break;
					case 1:
						// turn on LED2 and turn off LED1, 3-4
						PJOUT = LED2;
						S1_state++;

						break;
					case 2:
						// turn on LED3 and turn off LED1-2, 4
						PJOUT = LED3;
						S1_state++;

						break;
					case 3:
						// turn on LED 4 and turn off LED1-3
						PJOUT = LED4;
						S1_state = 0;

						break;
					default:
						S1_state = 0;
				}
			
			}

			// when exiting the ISR need to turn on the normal conditions again
			P4IFG &= ~P4IV_P4IFG0;

			// turn off the timer A0
			TA0CTL &= ~MC_3;

			// turn off all the LEDs
			PJOUT = 0x00;

			// last thing to do before exiting is enabling the S1 interrupts again
			P4IE |= BIT0;

			break;
		case P4IV_P4IFG1:
			// S2 case
			// turn off interrupts from S2 during operation, GIE already stops when entering, so S1 doesnt interrupt
			// button debouncing, not sure how i would do this
			
			S2_state = 0;


			P4IE &= ~BIT1;

			while(!(P4IFG & BIT1)) { // when P4IFG = 0x0000 then & 0x0002 = 0, then when its set its 0x0002

				TA0CTL |= TACLR; // clears TA0R to count from 0 again
				TA0CTL |= MC_2; // counter starts counting up contiuously 
				// change this eventually to a interrupt based thing? the switch statement would have to be in the interrupt? can use timer A1 for S2 instead of timer A0 to resolve between the two?
				while((TA0R < 0x0267)); // TA0 is counting at 4.096 kHz, for a ~150 ms delay want to count to 4096*0.15 = 615 = 0x0267

				switch(S2_state) {
					case 0:
						// turn on LED5 and turn off LED6-8
						P3OUT = LED5;
						S2_state++;

						break;
					case 1:
						// turn on LED6 and turn off LED5, 6-8
						P3OUT = LED6;
						S2_state++;

						break;
					case 2:
						// turn on LED7 and turn off LED5-6, 8
						P3OUT = LED7;
						S2_state++;

						break;
					case 3:
						// turn on LED8 and turn off LED5-7
						P3OUT = LED8;
						S2_state = 0;

						break;
					default:
						S2_state = 0;
				}
			
			}

			// when exiting the ISR need to turn on the normal conditions again
			P4IFG &= ~P4IV_P4IFG1;

			// turn off the timer A0
			TA0CTL &= ~MC_3;

			// turn off all the LEDs
			P3OUT = 0x00;

			// last thing to do before exiting is enabling the S2 interrupts again
			P4IE |= BIT1;


			break;
		default:
			P4IFG = 0x00;
	}
}


