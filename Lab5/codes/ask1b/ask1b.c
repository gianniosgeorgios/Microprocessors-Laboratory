#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

void usart_init(void);
void usart_transmit(char);
char usart_receive(void);
void usart_transmit_string (char *);

void main(void)
{
	SP = RAMEND;
	char c;
	char *read="Read ";
	char *invalid="Invalid Number\n";
	DDRB=0xFF; // Initiating PORT B as output

	usart_init();

	while(1){
		c=usart_receive();
		_delay_ms(100);
		if(c>='0' && c<='8'){
			usart_transmit_string(read);
			usart_transmit(c);
  	    	usart_transmit('\n');
			if(c=='0') PORTB=0x00;
			else {
				c=c-0x30;
				c=c-1;
				PORTB=0x01<<c;
			}
			_delay_ms(100);
		}
		else if(c!='\n') {
			usart_transmit_string(invalid);
			_delay_ms(100);
		}
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

char usart_receive(void){
 while ((UCSRA & 0x80)==0);
 return UDR;

}

void usart_transmit_string (char *message){
 int i=0;
 while (message[i]!='\0'){
 	usart_transmit(message[i]);
	i++;
 }
}
