#include "m16def.inc"

.org 0x0
rjmp reset

.org 0x4
sbic PIND, 7
rjmp ISR1
rjmp loop

reset:
ldi r24 , low(RAMEND)
out SPL , r24
ldi r24 , high(RAMEND)
out SPH , r24

ser r26 
out DDRB, r26
out DDRA, r26
clr r26
out DDRD, r26
ldi r23, 0x00

loop:
ldi r24 ,( 1 << ISC11) | ( 1 << ISC10)
out MCUCR , r24 
ldi r24 ,( 1 << INT1)
out GICR , r24
sei 

out PORTB , r26 
ldi r24 , low(100)
ldi r25 , high(100)
rcall wait_msec
inc r26
rjmp loop

ISR1: 
sts 0x3D2, r26

spin:
ldi r24 ,(1 << INTF1)
out GIFR ,r24 
ldi r24 , low(5)
ldi r25 , high(5)
rcall wait_msec
in r24, GIFR
sbrc r24, 7
rjmp spin
inc r23
out PORTA , r23
lds r26, 0x3D2
reti


wait_msec:
 push r24
 push r25
 ldi r24, low(998)
 ldi r25, high(998)
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
