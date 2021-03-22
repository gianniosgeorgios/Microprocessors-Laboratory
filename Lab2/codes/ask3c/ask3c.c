#define F_CPU 8000000UL
#include <avr/io.h>
#include<avr/interrupt.h>
#include <util/delay.h>

ISR (INT1_vect) 					// Ρουτίνα εξυπηρέτησης διακοπής INT1
{
	if((PINB & 0x01)==1) {			// Εαν PB0=1 έχουμε ανανέωση
		TCNT1H=0x85;				// Αρχικοποίσηση TCNT1 για 4sec
		TCNT1L=0xEE;
		PORTB=0xFF;					// Ανοίγουμε όλα τα PB leds
		_delay_ms(500);				// Καθυστέρηση 0.5sec
		PORTB=0x01;					// Ανοίγουμε μόνο το PB0
	}
	else {							// Εάν PB0=0 έχουμε ξεκίνημα
		TCNT1H=0x85;
		TCNT1L=0xEE;
		PORTB=0x01;					// Ανοίγουμε μόνο το PB0
	}
}

ISR (TIMER1_OVF_vect)				// Ρουτίνα εξυπηρέτησης διακοπής
{									// υπερχύλισης Timer1
	PORTB=0x00;						// Τα σβήνουμε όλα
}

void main(void)
{
	DDRB=0xFF;						// Αρχικοποίηση της θύρας B σαν έξοδο
	DDRA=0x00;						// Αρχικοποίηση της θύρας A σαν είσοδο
	GICR=1<<INT1;					// Ενεργοποίηση εξωτερικής διακοπής INT1:On
	MCUCR=(1<<ISC11)|(0<<ISC10);	// INT1 Mode: στην κατερχόμενη ακμή
	sei();							// Ενεργοποίηση συνολικά των διακοπών
	TIMSK=1<<TOIE1;					// Ενεργοποίηση διακοπής υπερχύλισης Timer1
	TCCR1B=(1<<CS12)|(0<<CS11)|(1<<CS10); //CK/1024

	while(1)
	{
		if((PINA & 0x80)==128) {		// Έλεγχος πατήματος PA0
			while ((PINA & 0x80)==128);	// Έλεγχος επαναφοράς PA0
			if((PINB & 0x01)==1) {		// Εαν PB0=1 έχουμε ανανέωση
				TCNT1H=0x85;			// Αρχικοποίσηση TCNT1 για 4sec
				TCNT1L=0xEE;
				PORTB=0xFF;				// Ανοίγουμε όλα τα PB leds
				_delay_ms(500);			// Καθυστέρηση 0.5sec
				PORTB=0x01;				// Ανοίγουμε μόνο το PB0
			}
			else {						// Εάν PB0=0 έχουμε ξεκίνημα
				TCNT1H=0x85;			// Αρχικοποίσηση TCNT1 για 4sec
				TCNT1L=0xEE;
				PORTB=0x01;				// Ανοίγουμε μόνο το PB0
			}
		}
	};
}
