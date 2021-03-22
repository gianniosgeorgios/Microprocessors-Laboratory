#include "m16def.inc"

start:
 ldi r24 , low(RAMEND)
 out SPL , r24
 ldi r24 , high(RAMEND)
 out SPH , r24

 clr r27
 ldi r26, 0x60
 ldi r24, 'm'
 st X+, r24
 ldi r24, 'i'
 st X+, r24
 ldi r24, 'c'
 st X+, r24
 ldi r24, 'r'
 st X+, r24
 ldi r24, 'o'
 st X+, r24
 ldi r24, '\n'
 st X+, r24
 ldi r24, '\0'
 st X+, r24

 rcall usart_init
 clr r27
 ldi r26, 0x60

looop:
 ld r24, X+
 cpi r24,'\0'
 breq exit
 rcall usart_transmit
 rjmp looop


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

exit:
 ;rjmp exit
