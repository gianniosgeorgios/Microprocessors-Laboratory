#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

char one_wire_reset(void);
void one_wire_transmit_bit(char);
void one_wire_transmit_byte(char);
char one_wire_receive_bit(void);
char one_wire_receive_byte(void);
char * temperature(void);

void lcd_init (void);
void write_2_nibbles(char);
void lcd_data(char);
void lcd_command(char);

void main(void)
{
	SP = RAMEND;
	char c;
	DDRD=0xFC;
	while(1){
		char *temp; 
		DDRA=0x00;

	    char sign,metro=0,ekat=0,dec=0,mon=0;
		temp=temperature();
		while (temp[0]==0x00 && temp[1]==0x80){
			lcd_init();
			lcd_data('N');
			lcd_data('O');
			lcd_data(' ');
			lcd_data('D');
			lcd_data('e');
			lcd_data('v');
			lcd_data('i');
			lcd_data('c');
			lcd_data('e');
			temp=temperature();
		}

		if(temp[1]==0x00){
			if((temp[0] & 0x01)==1) {
				temp[0]=temp[0]>>1;
				temp[0]++;
			}
			else temp[0]=temp[0]>>1;
		}
		else{
			temp[0]=~temp[0];
			temp[0]++;
			if((temp[0] & 0x01)==1) {
				temp[0]=temp[0]>>1;
				temp[0]++;
			}
			else temp[0]=temp[0]>>1;
		}
		c=temp[0];
		if(c==0)
		{
			lcd_init();
			lcd_data('0');
			lcd_data('°');
			lcd_data('C');
		}
		else
		{
			if(c>=0x80)
			{
				sign='-';
				metro=(0x80-(c & 0x7f));
			}
			else
			{
				sign='+';
				metro=c;
			}
			if(metro>=100)
			{
				ekat=1;
				metro=metro-100;
			}
			
			while(metro>=10)
			{
				dec++;
				metro=metro-10;
			}
			mon=metro;

			lcd_init();
			lcd_data(sign);		
			if(ekat==0)
			{
				if(dec==0)
				{
					lcd_data((mon & 0x0f)+0x30);
					lcd_data('°');
					lcd_data('C');
				}
				else
				{
					lcd_data((dec & 0x0f)+0x30);
					lcd_data((mon & 0x0f)+0x30);
					lcd_data('°');
					lcd_data('C');
				}
			}
			else
			{
				lcd_data((ekat & 0x0f)+0x30);
				lcd_data((dec & 0x0f)+0x30);
				lcd_data((mon & 0x0f)+0x30);
				lcd_data('°');
				lcd_data('C');
			}
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

void write_2_nibbles(char x)
{
	char y=PIND & 0x0f;
	char x1=x & 0xf0;
	x1=x1+y;
	PORTD=x1;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
	x=x<<4 | x>>4;
	x=x & 0xf0;
	PORTD=x+y;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
}

void lcd_data(char x)
{
	PORTD=PORTD | (1<<PD2);
	write_2_nibbles(x);
	_delay_us(43);
}

void  lcd_command(char x)
{
	PORTD=PORTD | (0<<PD2);
	write_2_nibbles(x);
	_delay_us(43);
}

void lcd_init (void)
{
	_delay_ms(40);
	PORTD=0x30;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
	_delay_us(39);
	PORTD=0x30;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
	_delay_us(39);
	PORTD=0x20;
	PORTD=PORTD | (1<<PD3);
	PORTD=PORTD & (0<<PD3);
	_delay_us(39);
	lcd_command(0x28);
	lcd_command(0x0c);
	lcd_command(0x01);
	_delay_us(1530);
	lcd_command(0x06);
}
