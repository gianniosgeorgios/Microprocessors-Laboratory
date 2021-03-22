#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

char one_wire_reset(void);
void one_wire_transmit_bit(char);
void one_wire_transmit_byte(char);
char one_wire_receive_bit(void);
char one_wire_receive_byte(void);
char * temperature(void);

void main(void)
{
	while(1){
		SP = RAMEND;
		char *temp;
		DDRB=0xFF; // Initiating PORT B as output
	
		temp=temperature();
		while (temp[0]==0x00 && temp[1]==0x80){
			temp=temperature();
		}

		if(temp[1]==0x00){
			if((temp[0] & 0x01)==1) {
				temp[0]=temp[0]>>1;
				temp[0]++;
			}
			else temp[0]=temp[0]>>1;
			PORTB=temp[0];
		}
		else if(temp[1]==0x80){
			temp[0]=~temp[0];
			temp[0]++;
			if((temp[0] & 0x01)==1) {
				temp[0]=temp[0]>>1;
				temp[0]++;
			}
			else temp[0]=temp[0]>>1;

			temp[0]=~temp[0];
			temp[0]++;
			PORTB= temp[0] | 0x80;
		}
	}
}

char one_wire_reset(){
	PORTA=PORTA | (1<<PA4);
	DDRA=DDRA | (1<<PA4);
	PORTA=PORTA & ~(1<<PA4);
	
	_delay_us(480);

	DDRA=DDRA & ~(1<<PA4);
	PORTA=PORTA & ~(1<<PA4);
	
	_delay_us(100);

	char x=(PINA & (1<<PA4));
	_delay_us(380);

	if(x==0x10) return 0x00;
	else return 0x01;
}

void one_wire_transmit_bit(char x){
	DDRA=DDRA | (1<<PA4);
	PORTA=PORTA & (0<<PA4);
	_delay_us(2);
	if((x & 0x01)==1) PORTA=PORTA | (1<<PA4);
	if((x & 0x01)==0) PORTA=PORTA & (0<<PA4);
	_delay_us(58);
	DDRA=DDRA & (0<<PA4);
	PORTA=PORTA & (0<<PA4);
	_delay_us(1);
}

void one_wire_transmit_byte(char x){
	for(int i=0; i<8; i++){
		if((x & 0x01)==1) one_wire_transmit_bit(0x01);
		else one_wire_transmit_bit(0x00);
		x=x>>1;
	}
}

char one_wire_receive_bit(){
	char x=0x00;
	DDRA=DDRA | (1<<PA4);
	PORTA=PORTA & (0<<PA4);
	_delay_us(2);
	DDRA=DDRA & (0<<PA4);
	PORTA=PORTA & (0<<PA4);
	_delay_us(10);
	if((PINA & 0x10)==0x10) x=0x01;
	_delay_us(49);
	return x;
}

char one_wire_receive_byte(){
	char x, y=0x00;
	for(int i=0; i<8; i++){
		x=one_wire_receive_bit();
		y=y>>1;
		if((x & 0x01)==1) y=y|0x80;
		else y=y|x;
	}
	return y;
}
			

char * temperature(){
	static char x[2];
	char check=one_wire_reset();
	//PORTC=check;	correct
	if((check & 0x01)==0) {
		//PORTC=0xF0; correct
		x[0]=0x00;
		x[1]=0x80;
		return x;
	}
	one_wire_transmit_byte(0xCC);
	one_wire_transmit_byte(0x44);
	while((one_wire_receive_bit() & 0x01)==0);

	if((one_wire_reset() & 0x01)==0) {
		x[0]=0x00;
		x[1]=0x80;
		return x;
	}
	one_wire_transmit_byte(0xCC);
	one_wire_transmit_byte(0xBE);
	x[0]=one_wire_receive_byte();
	x[1]=one_wire_receive_byte();

	return x;

}
