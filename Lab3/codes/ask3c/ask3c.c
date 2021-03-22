#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

void lcd_init (void);
void write_2_nibbles(char);
void lcd_data(char);
void lcd_command(char);

void main (void)
{
	DDRD=0xfc;					//Initiating PORTD as output
	DDRB=0x00;
	char min_dec='0',min_mon='0',sec_dec='0',sec_mon='0';
	while(1)
	{
		while((PINB & 0x01)==0)
		{
			if((PINB & 0x80)==128)
			{
				min_dec='0',min_mon='0',sec_dec='0',sec_mon='0';
				lcd_init();				//Initiating LCD
				lcd_data(min_dec);		//Print min_dec
				lcd_data(min_mon);		//Print min_mon
				lcd_data('M');			//Print 'M'
				lcd_data('I');			//Print 'I'
				lcd_data('N');			//Print 'N'
				lcd_data(':');			//Print ':'
				lcd_data(sec_dec);		//Print sec_dec
				lcd_data(sec_mon);		//Print sec_mon
				lcd_data('S');			//Print 'S'
				lcd_data('E');			//Print 'E'
				lcd_data('C');			//Print 'C'
			}
		}
		lcd_init();				//Initiating LCD
		lcd_data(min_dec);		//Print min_dec
		lcd_data(min_mon);		//Print min_mon
		lcd_data('M');			//Print 'M'
		lcd_data('I');			//Print 'I'
		lcd_data('N');			//Print 'N'
		lcd_data(':');			//Print ':'
		lcd_data(sec_dec);		//Print sec_dec
		lcd_data(sec_mon);		//Print sec_mon
		lcd_data('S');			//Print 'S'
		lcd_data('E');			//Print 'E'
		lcd_data('C');			//Print 'C'
		_delay_ms(1000);		//delay 1sec

		if(sec_mon=='9')
		{
			if(sec_dec=='5')
			{
				if(min_mon=='9')
				{
					if(min_dec=='5')
					{
						min_dec='0';
						min_mon='0';
						sec_dec='0';
						sec_mon='0';
					}
					else
					{
						min_dec++;
						min_mon='0';
						sec_dec='0';
						sec_mon='0';
					}
				}
				else
				{
					min_mon++;
					sec_mon='0';
					sec_dec='0';
				}
			}
			else
			{
				sec_dec++;
				sec_mon='0';
			}
		}
		else
		{
			sec_mon++;
		}
	}
}

void write_2_nibbles(char x)
{
	char x2;
	char y=PIND & 0x0f;
	char x1=x & 0xf0;
	x1=x1+y;
	PORTD=x1;
	PORTD=PORTD | 0x08;
	PORTD=PORTD & 0xf7;
	x2=x<<4 ;
	x=x>>4;
	x=x|x2;
	x=x & 0xf0;
	PORTD=x+y;
	PORTD=PORTD | 0x08;
	PORTD=PORTD & 0xf7;
}

void lcd_data(char x)
{
	PORTD=PORTD | 0x04;
	write_2_nibbles(x);
	_delay_us(43);
}

void  lcd_command(char x)
{
	PORTD=PORTD & (0xfb);
	write_2_nibbles(x);
	_delay_us(39);
}

void lcd_init (void)
{
	_delay_ms(40);
	
	PORTD=0x30;
	PORTD=PORTD | 0x08;
	PORTD=PORTD & 0xf7;
	_delay_us(39);
	
	PORTD=0x30;
	PORTD=PORTD | 0x08;
	PORTD=PORTD & 0xf7;
	_delay_us(39);
	
	PORTD=0x20;
	PORTD=PORTD | 0x08;
	PORTD=PORTD & 0xf7;
	_delay_us(39);
	
	lcd_command(0x28);
	lcd_command(0x0c);
	lcd_command(0x01);
	_delay_us(1530);
	lcd_command(0x06);
}
