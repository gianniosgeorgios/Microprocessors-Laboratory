#define F_CPU 8000000UL
#include <avr/io.h>
#include<avr/interrupt.h>
#include <util/delay.h>

ISR (INT1_vect) 					// ������� ������������ �������� INT1
{
	if((PINB & 0x01)==1) {			// ��� PB0=1 ������ ��������
		TCNT1H=0x85;				// ������������� TCNT1 ��� 4sec
		TCNT1L=0xEE;
		PORTB=0xFF;					// ��������� ��� �� PB leds
		_delay_ms(500);				// ����������� 0.5sec
		PORTB=0x01;					// ��������� ���� �� PB0
	}
	else {							// ��� PB0=0 ������ ��������
		TCNT1H=0x85;
		TCNT1L=0xEE;
		PORTB=0x01;					// ��������� ���� �� PB0
	}
}

ISR (TIMER1_OVF_vect)				// ������� ������������ ��������
{									// ����������� Timer1
	PORTB=0x00;						// �� �������� ���
}

void main(void)
{
	DDRB=0xFF;						// ������������ ��� ����� B ��� �����
	DDRA=0x00;						// ������������ ��� ����� A ��� ������
	GICR=1<<INT1;					// ������������ ���������� �������� INT1:On
	MCUCR=(1<<ISC11)|(0<<ISC10);	// INT1 Mode: ���� ����������� ����
	sei();							// ������������ �������� ��� ��������
	TIMSK=1<<TOIE1;					// ������������ �������� ����������� Timer1
	TCCR1B=(1<<CS12)|(0<<CS11)|(1<<CS10); //CK/1024

	while(1)
	{
		if((PINA & 0x80)==128) {		// ������� ��������� PA0
			while ((PINA & 0x80)==128);	// ������� ���������� PA0
			if((PINB & 0x01)==1) {		// ��� PB0=1 ������ ��������
				TCNT1H=0x85;			// ������������� TCNT1 ��� 4sec
				TCNT1L=0xEE;
				PORTB=0xFF;				// ��������� ��� �� PB leds
				_delay_ms(500);			// ����������� 0.5sec
				PORTB=0x01;				// ��������� ���� �� PB0
			}
			else {						// ��� PB0=0 ������ ��������
				TCNT1H=0x85;			// ������������� TCNT1 ��� 4sec
				TCNT1L=0xEE;
				PORTB=0x01;				// ��������� ���� �� PB0
			}
		}
	};
}
