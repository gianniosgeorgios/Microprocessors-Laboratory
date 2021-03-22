#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

void usart_init(void);
void usart_transmit(char);
void ADC_init(void);


void main(void)
{
	SP = RAMEND;

	unsigned long long int x, y;
	
	ADC_init();
	usart_init();

	while(1){
		ADCSRA = ADCSRA | (1<<ADSC);
		while(ADCSRA & (1<<ADSC));

		x = ADCL & 0xFF;
        y = ADCH & 0x03;
        x = x + (y * 256);
        x = 100* x * 5 /1024;

        y = x / 100 ;
            
        usart_transmit(y + 0x30);
        usart_transmit(',');
            
        y = x - 100*y;
		y=y/10;
            
        usart_transmit(y + 0x30);
			
		y = x % 10;
			
		usart_transmit(y + 0x30);		
			
        usart_transmit('\n');
	}

}

void usart_init(void){
	UBRRH=0x00;
	UBRRL=51;
	UCSRA=0x00;
	UCSRB=(1<<RXEN) | (1<<TXEN);
	UCSRC=(1 << URSEL) | (3 << UCSZ0);
}

void usart_transmit(char x){
	while ((UCSRA & 0x20)==0);
	UDR=x;
}


void ADC_init(void) {
	ADMUX = (1<<REFS0);
	ADCSRA = (1<<ADEN)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0);
}
