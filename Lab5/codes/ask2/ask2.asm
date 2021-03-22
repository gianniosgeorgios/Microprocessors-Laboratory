.include "m16def.inc"

.def zero = r16
.def count = r27
.def temp = r24
.def flag = r19
.def low_ = r21
.def median_ = r22
.def high_ = r23
.def ekat = r29
.def dek = r28

.org 0x00
jmp reset

.org 0x1c
jmp ADC_interrupt
reti


reset:  
 ldi r26, low(RAMEND)
 out SPL, r26
 ldi r26,high(RAMEND)
 out SPH, r26
 ser temp
 out DDRB,temp
 ldi count,0x00
 sei
 rcall usart_init
 rcall adc_init

	
start:	
	
 out PORTB, count
 ldi r24 ,low(300)        
 ldi r25 ,high(300)
 rcall wait_msec

 sbi ADCSRA, ADSC
 rjmp start

ADC_interrupt:
 set		
 clr low_
 clr median_
 clr high_
 clr ekat
 clr dek
 clr zero

loop:
 in r24, ADCSRA
 sbrc r24, ADSC
 rjmp loop
 in r24,ADCL
 in r25,ADCH
 clr flag

convert1:
 add low_, r24
 adc median_, r25
 adc high_, zero
 inc flag
 cpi flag,250
 brlo convert1

 clr flag

convert2:
 add low_, r24
 adc median_, r25
 adc high_, zero
 inc flag
 cpi flag,250
 brlo convert2


 clr low_
 lsr high_
 ror median_
 lsr high_
 ror median_

ekato:
 cpi median_,100
 brlo decc
 inc ekat
 subi median_, 100
 rjmp ekato

decc:
 cpi median_,10
 brlo mon
 inc dek
 subi median_, 10
 rjmp decc

 ;ekat=r29, dek=r28, mon=median_=r22

mon:
 sbrs high_, 0
 rjmp screen
 
check_mon:
 subi median_, -6
 cpi median_, 10
 brsh mon_big_than_10
 rjmp check_dec

mon_big_than_10:
 subi median_, 10
 inc dek
 
check_dec:
 subi dek, -5
 cpi dek, 10
 brsh dec_big_than_10
 rjmp check_ekat

dec_big_than_10:
 subi dek, 10
 inc ekat
 
check_ekat:
 subi ekat, -2

screen:
 subi median_,-0x30
 subi dek,-0x30
 subi ekat,-0x30

 mov temp,ekat
 rcall usart_transmit

 ldi r24,'.'
 rcall usart_transmit

 mov temp,dek
 rcall usart_transmit

 mov temp,median_
 rcall usart_transmit

 ldi temp,'\n'      
 rcall usart_transmit
	
 inc count

 reti


usart_init:
 clr r24 ; initialize UCSRA to zero
 out UCSRA ,r24
 ldi r24 ,(1<<RXEN) | (1<<TXEN) ; activate transmitter/receiver
 out UCSRB ,r24
 ldi r24 ,0 ; baud rate = 9600
 out UBRRH ,r24
 ldi r24 ,51
 out UBRRL ,r24
 ldi r24 ,(1 << URSEL) | (3 << UCSZ0) ; 8-bit character size,
 out UCSRC ,r24 ; 1 stop bit
 ret

usart_transmit:
 sbis UCSRA ,UDRE ; check if usart is ready to transmit
 rjmp usart_transmit ; if no check again, else transmit
 out UDR ,r24 ; content of r24
 ret

usart_receive:
 sbis UCSRA ,RXC ; check if usart received byte
 rjmp usart_receive ; if no check again, else read
 in r24 ,UDR ; receive byte and place it in
 ret ; r24

ADC_init:
 ldi r24,(1<<REFS0) ; Vref: Vcc
 out ADMUX,r24 ;MUX4:0 = 00000 for A0.
 ;ADC is Enabled (ADEN=1)
 ;ADC Interrupts are Enabled (ADIE=1)
 ;Set Prescaler CK/128 = 62.5Khz (ADPS2:0=111)
 ldi r24,(1<<ADEN)|(1<<ADIE)|(1<<ADPS2)|(1<<ADPS1)|(1<<ADPS0)
 out ADCSRA,r24
 ret


wait_msec:
 push r24
 push r25
 ldi r24 , low(998)
 ldi r25 , high(998)
 rcall wait_usec
 pop r25
 pop r24
 sbiw r24 , 1
 brne wait_msec
 ret

wait_usec:
 sbiw r24 ,1
 nop
 nop
 nop
 nop
 brne wait_usec
 ret
