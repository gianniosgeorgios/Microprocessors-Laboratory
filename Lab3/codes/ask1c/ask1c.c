#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

char scan_row(int);
void scan_keypad(char *);
void scan_keypad_rising_edge(char*, char*);
char keypad_to_ascii(char *);

void main(void)
{
	SP = RAMEND;
	char prev[2],next[2],c,pressed[2];
	DDRB=0xFF; // Initiating PORT B as output

	while(1)
	{
		DDRC=(1<<PC7)|(1<<PC6)|(1<<PC5)|(1<<PC4); // Initiating PORT C4-C7 as output
		scan_keypad_rising_edge(prev,next);
		while((c=keypad_to_ascii(next))=='@')
		{
			scan_keypad_rising_edge(prev,next);
	    }
		
		pressed[0]=c;

		scan_keypad_rising_edge(prev,next);
		while((c=keypad_to_ascii(next))=='@')
		{
			scan_keypad_rising_edge(prev,next);
	    }
		
		pressed[1]=c;		

		if((pressed[0]=='1') && (pressed[1]=='6')) 
		{
			PORTB=0xFF;
			_delay_ms(4000);
			PORTB=0x00;
		}
		else
		{
			for(int i=0; i<8; i++)
			{
				PORTB=0xFF;
				_delay_ms(250);
				PORTB=0x00;
				_delay_ms(250);
			}
		}
	}
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


char keypad_to_ascii(char * keys)
{
	if ((keys[1]&0x01)==0x01) return '*';
	if ((keys[1]&0x02)==0x02) return '0';
	if ((keys[1]&0x04)==0x04) return '#';
	if ((keys[1]&0x08)==0x08) return 'D';
	if ((keys[1]&0x10)==0x10) return '7';
	if ((keys[1]&0x20)==0x20) return '8';
	if ((keys[1]&0x40)==0x40) return '9';
	if ((keys[1]&0x80)==0x80) return 'C';
	if ((keys[0]&0x01)==0x01) return '4';
	if ((keys[0]&0x02)==0x02) return '5';
	if ((keys[0]&0x04)==0x04) return '6';
	if ((keys[0]&0x08)==0x08) return 'B';
	if ((keys[0]&0x10)==0x10) return '1';
	if ((keys[0]&0x20)==0x20) return '2';
	if ((keys[0]&0x40)==0x40) return '3';
	if ((keys[0]&0x80)==0x80) return 'A';
	return '@';
}
