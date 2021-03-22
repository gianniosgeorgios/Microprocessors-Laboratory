#define F_CPU 8000000UL
#include <avr/io.h>
#include <util/delay.h>

void usart_init(void);
void usart_transmit(char);
char usart_receive(void);
void usart_transmit_string (char *);

void lcd_init (void);
void write_2_nibbles(char);
void lcd_data(char);
void lcd_command(char);

char one_wire_reset(void);
void one_wire_transmit_bit(char);
void one_wire_transmit_byte(char);
char one_wire_receive_bit(void);
char one_wire_receive_byte(void);
char * temperature(void);

char scan_row(int);
void scan_keypad(char *);
void scan_keypad_rising_edge(char*, char*);
int keypad_to_hex(char *);

void main(void)
{
	SP = RAMEND;
	DDRD=0xFC;
	DDRC=(1<<PC7)|(1<<PC6)|(1<<PC5)|(1<<PC4);
	char c1[9];
	char c2[9];
	char c3[9];
	char c4[9];
	char *team="teamname: \"A16\"\n";
	//char *payload="payload: [{\"A14\": \"Temperature\",\"value\": 36}]";
	char *temp;
	char prev[2],next[2];

	usart_init();
		char t;		

		usart_transmit_string(team);
		int i=0;
		while((t=usart_receive())!='\n'){
			c1[i]=t;
			i++;
		}

		_delay_ms(100);
		if (c1[0]=='"' && c1[1]=='S' && c1[2]=='u' && c1[3]=='c' && c1[4]=='c' && c1[5]=='e' && c1[6]=='s' && c1[7]=='s' && c1[8]=='"') {
			lcd_init();
			lcd_data('1');
			lcd_data('.');
			lcd_data('S');
			lcd_data('u');
			lcd_data('c');
			lcd_data('c');
			lcd_data('e');
			lcd_data('s');
			lcd_data('s');
		}
		else if (c1[0]=='"' && c1[1]=='F' && c1[2]=='a' && c1[3]=='i' && c1[4]=='l' && c1[5]=='"') {
			lcd_init();
			lcd_data('1');
			lcd_data('.');
			lcd_data('F');
			lcd_data('a');
			lcd_data('i');
			lcd_data('l');
		}

		usart_transmit_string("connect\n");
		i=0;
		while((t=usart_receive())!='\n'){
			c2[i]=t;
			i++;
		}
		_delay_ms(100);
		if (c2[0]=='"' && c2[1]=='S' && c2[2]=='u' && c2[3]=='c' && c2[4]=='c' && c2[5]=='e' && c2[6]=='s' && c2[7]=='s' && c2[8]=='"') {
			lcd_init();
			lcd_data('2');
			lcd_data('.');
			lcd_data('S');
			lcd_data('u');
			lcd_data('c');
			lcd_data('c');
			lcd_data('e');
			lcd_data('s');
			lcd_data('s');
		}
		else if (c2[0]=='"' && c2[1]=='F' && c2[2]=='a' && c2[3]=='i' && c2[4]=='l' && c2[5]=='"') {
			lcd_init();
			lcd_data('2');
			lcd_data('.');
			lcd_data('F');
			lcd_data('a');
			lcd_data('i');
			lcd_data('l');
		}
		
		while(1){
		char sign,metro=0,ekat=0,dec=0,mon=0;
		temp=temperature();
		while (temp[0]==0x00 && temp[1]==0x80){
			temp=temperature();
		}

		if(temp[1] & 0xf0 == 0xf0){
			temp[0]=temp[0]>>4;
			temp[0]=temp[0] & 0x0f;
			temp[1]=temp[1]<<4;
			temp[1]=temp[1] & 0xf0;
			temp[0]=temp[0]|temp[1];

			if((temp[0] & 0x01)==1) temp[0]++;
		}
		else{
			temp[0]=~temp[0];
			temp[0]++;
			temp[0]=temp[0]>>4;
			temp[0]=temp[0] & 0x0f;
			temp[1]=temp[1]<<4;
			temp[1]=temp[1] & 0xf0;
			temp[0]=temp[0]|temp[1];
			if((temp[0] & 0x01)==1) temp[0]++;
		}

		char c=temp[0];

		usart_transmit_string("payload: [{\"name\": \"Temperature\",\"value\":");

		if(c==0)
		{
			usart_transmit('0');
			//usart_transmit('°');
			//usart_transmit('C');
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

			//usart_transmit(sign);		
			if(ekat==0)
			{
				if(dec==0)
				{
					usart_transmit((mon & 0x0f)+0x30);
					//usart_transmit('°');
					//usart_transmit('C');
				}
				else
				{
					usart_transmit((dec & 0x0f)+0x30);
					usart_transmit((mon & 0x0f)+0x30);
					//usart_transmit('°');
					//usart_transmit('C');
				}
			}
			else
			{
				usart_transmit((ekat & 0x0f)+0x30);
				usart_transmit((dec & 0x0f)+0x30);
				usart_transmit((mon & 0x0f)+0x30);
				//usart_transmit('°');
				//usart_transmit('C');
			}
		}
		usart_transmit_string("}]\n");

		i=0;
		while((t=usart_receive())!='\n'){
			c3[i]=t;
			i++;
		}
		_delay_ms(100);
		if (c3[0]=='"' && c3[1]=='S' && c3[2]=='u' && c3[3]=='c' && c3[4]=='c' && c3[5]=='e' && c3[6]=='s' && c3[7]=='s' && c3[8]=='"') {
			lcd_init();
			lcd_data('3');
			lcd_data('.');
			lcd_data('S');
			lcd_data('u');
			lcd_data('c');
			lcd_data('c');
			lcd_data('e');
			lcd_data('s');
			lcd_data('s');
		}
		else if (c3[0]=='"' && c3[1]=='F' && c3[2]=='a' && c3[3]=='i' && c3[4]=='l' && c3[5]=='"') {
			lcd_init();
			lcd_data('3');
			lcd_data('.');
			lcd_data('F');
			lcd_data('a');
			lcd_data('i');
			lcd_data('l');
		}

		scan_keypad_rising_edge(prev,next);

		if (keypad_to_hex(next)==0x06) {
			usart_transmit_string("ready: \"true\"\n");
			
			i=0;
			while((t=usart_receive())!='\n'){
				c4[i]=t;
				i++;
			}
			_delay_ms(100);
			if (c4[0]=='"' && c4[1]=='S' && c4[2]=='u' && c4[3]=='c' && c4[4]=='c' && c4[5]=='e' && c4[6]=='s' && c4[7]=='s' && c4[8]=='"') {
				lcd_init();
				lcd_data('4');
				lcd_data('.');
				lcd_data('S');
				lcd_data('u');
				lcd_data('c');
				lcd_data('c');
				lcd_data('e');
				lcd_data('s');
				lcd_data('s');
			}
			else if (c4[0]=='"' && c4[1]=='F' && c4[2]=='a' && c4[3]=='i' && c4[4]=='l' && c4[5]=='"') {
				lcd_init();
				lcd_data('4');
				lcd_data('.');
				lcd_data('F');
				lcd_data('a');
				lcd_data('i');
				lcd_data('l');
			}
		}
		if (keypad_to_hex(next)!=0x06 && keypad_to_hex(next)!=0x10){
			usart_transmit_string("ready: \"false\"\n");
			i=0;
			while((t=usart_receive())!='\n'){
				c4[i]=t;
				i++;
			}
			_delay_ms(100);
			if (c4[0]=='"' && c4[1]=='S' && c4[2]=='u' && c4[3]=='c' && c4[4]=='c' && c4[5]=='e' && c4[6]=='s' && c4[7]=='s' && c4[8]=='"') {
				lcd_init();
				lcd_data('4');
				lcd_data('.');
				lcd_data('S');
				lcd_data('u');
				lcd_data('c');
				lcd_data('c');
				lcd_data('e');
				lcd_data('s');
				lcd_data('s');
			}
			else if (c4[0]=='"' && c4[1]=='F' && c4[2]=='a' && c4[3]=='i' && c4[4]=='l' && c4[5]=='"') {
				lcd_init();
				lcd_data('4');
				lcd_data('.');
				lcd_data('F');
				lcd_data('a');
				lcd_data('i');
				lcd_data('l');
			}
		}
		usart_transmit_string("transmit\n");
		lcd_init();
		while((t=usart_receive())!='\n'){
			lcd_data(t);
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
