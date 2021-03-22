#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

char scan_row(int);
void scan_keypad(char *);
void scan_keypad_rising_edge(char*, char*);
int keypad_to_hex(char *);

void lcd_init (void);
void write_2_nibbles(char);
void lcd_data(char);
void lcd_command(char);

void main(void)
{
	SP = RAMEND;
	char prev[2],next[2],c,c1,c2,pressed[4];
	DDRD=0xFC;

	while(1)
	{
		char sign,metro=0,ekat=0,dec=0,mon=0;
		DDRC=(1<<PC7)|(1<<PC6)|(1<<PC5)|(1<<PC4); // Initiating PORT C4-C7 as output
		scan_keypad_rising_edge(prev,next);
		while((c=keypad_to_hex(next))==0x10)
		{
			scan_keypad_rising_edge(prev,next);
	    }
		
		pressed[0]=c & 0x0f;

		scan_keypad_rising_edge(prev,next);
		while((c=keypad_to_hex(next))==0x10)
		{
			scan_keypad_rising_edge(prev,next);
	    }
		
		pressed[1]=c & 0x0f;
		
		scan_keypad_rising_edge(prev,next);
		while((c=keypad_to_hex(next))==0x10)
		{
			scan_keypad_rising_edge(prev,next);
	    }
		
		pressed[2]=c & 0x0f;
		
		scan_keypad_rising_edge(prev,next);
		while((c=keypad_to_hex(next))==0x10)
		{
			scan_keypad_rising_edge(prev,next);
	    }
		
		pressed[3]=c & 0x0f;		
		
		lcd_init();
	
		if(pressed[0]>=10)
		{
			lcd_data(pressed[0]+0x37);
		}
	
		else
		{
			lcd_data(pressed[0]+0x30);
		}
		
		if(pressed[1]>=10)
		{
			lcd_data(pressed[1]+0x37);
		}
	
		else
		{
			lcd_data(pressed[1]+0x30);
		}

		if(pressed[2]>=10)
		{
			lcd_data(pressed[2]+0x37);
		}
	
		else
		{
			lcd_data(pressed[2]+0x30);
		}

		if(pressed[3]>=10)
		{
			lcd_data(pressed[3]+0x37);
		}
	
		else
		{
			lcd_data(pressed[3]+0x30);
		}
		
		lcd_data('=');
		lcd_data('>');


		c1=(pressed[0]<<4)|pressed[1];
		c2=(pressed[2]<<4)|pressed[3];

		if(c1==0x80 && c2==0x00){
			lcd_data('N');
			lcd_data('O');
			lcd_data(' ');
			lcd_data('D');
			lcd_data('e');
			lcd_data('v');
			lcd_data('i');
			lcd_data('c');
			lcd_data('e');
			continue;
		}
		else if(c1!=0x00 && c1!=0xFF){
			lcd_data('E');
			lcd_data('R');
			lcd_data('R');
			lcd_data('O');
			lcd_data('R');
			continue;
		}

		if((c2==0) && (c1==0))
		{
			lcd_data('0');
			lcd_data('°');
			lcd_data('C');

		}
		else
		{
			if(c1 == 0xFF)
			{
				if (c2 == 0x00)
				{
					lcd_data('E');
					lcd_data('R');
					lcd_data('R');
					lcd_data('O');
					lcd_data('R');
					continue;
				}
				sign='-';
				metro=~c2;
				metro=metro+0x01;

			}
			else
			{
				sign='+';
				metro=c2;
			}
			if(sign=='+' && metro>=251){
				lcd_data('E');
				lcd_data('R');
				lcd_data('R');
				lcd_data('O');
				lcd_data('R');
				continue;
			}
			else if(sign=='-' && metro>=111){
				lcd_data('E');
				lcd_data('R');
				lcd_data('R');
				lcd_data('O');
				lcd_data('R');
				continue;
			}
			if (metro%2==0) metro=metro/2;
			else metro=(metro/2)+1;
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


char scan_row(int row)
{
	char x=0x08,a;
	x=x<<row;
	PORTC =x;
	_delay_us(1);
	a=PINC & 0x0F;
	return a;
}

void scan_keypad(char next_st[2])
{
	next_st[0]=0x00;
	next_st[1]=0x00;

	char line=scan_row(1) & 0x0f;
	char temp = line<<4;
	next_st[0]=temp;
	
	line=scan_row(2) & 0x0f;
	next_st[0]=next_st[0]|line;
	
	line=scan_row(3) & 0x0f;
	temp = line<<4;
	next_st[1]=temp;
	
	line=scan_row(4) & 0x0f;
	next_st[1]=next_st[1]|line;
	
	return;
}

void scan_keypad_rising_edge(char prev_st[2], char next_st[2]) {

	scan_keypad(next_st);
	char temp[2];
	
	temp[0] = next_st[0];
	temp[1] = next_st[1];

	_delay_ms(15);

	scan_keypad(next_st);

	next_st[0] = next_st[0] & temp[0];
	next_st[1] = next_st[1] & temp[1];

	temp[0] = ~prev_st[0];
	temp[1] = ~prev_st[1];

	prev_st[0] = next_st[0];
	prev_st[1] = next_st[1];

	next_st[0] = next_st[0] & temp[0];
	next_st[1] = next_st[1] & temp[1];

	return;

}

int keypad_to_hex(char * keys)
{
	if ((keys[1]&0x01)==0x01) return 0x0E;
	if ((keys[1]&0x02)==0x02) return 0x00;
	if ((keys[1]&0x04)==0x04) return 0x0F;
	if ((keys[1]&0x08)==0x08) return 0x0D;
	if ((keys[1]&0x10)==0x10) return 0x07;
	if ((keys[1]&0x20)==0x20) return 0x08;
	if ((keys[1]&0x40)==0x40) return 0x09;
	if ((keys[1]&0x80)==0x80) return 0x0C;
	if ((keys[0]&0x01)==0x01) return 0x04;
	if ((keys[0]&0x02)==0x02) return 0x05;
	if ((keys[0]&0x04)==0x04) return 0x06;
	if ((keys[0]&0x08)==0x08) return 0x0B;
	if ((keys[0]&0x10)==0x10) return 0x01;
	if ((keys[0]&0x20)==0x20) return 0x02;
	if ((keys[0]&0x40)==0x40) return 0x03;
	if ((keys[0]&0x80)==0x80) return 0x0A;
	return 0x10;
}
