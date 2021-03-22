#include "m16def.inc"

.org 0x0
rjmp reset

.org 0x2
rjmp ISR0

reset:
ldi r24 , low(RAMEND)
out SPL , r24
ldi r24 , high(RAMEND)
out SPH , r24

ser r26 
out DDRB, r26 ;έξοδος
out DDRC, r26 ;έξοδος
clr r26
out DDRA, r26 ;είσοδος
ldi r22, 0x00

loop: 
ldi r24 ,( 1 << ISC01) | ( 1 << ISC00)
out MCUCR , r24 
ldi r24 ,( 1 << INT0)
out GICR , r24
sei 

out PORTB , r26 
ldi r24, low(200) 
ldi r25, high(200)
rcall wait_msec
inc r26
rjmp loop


ISR0: 
sts 0x3D2, r26
ldi r22, 0x00
spin:
ldi r24 ,(1 << INTF1)
out GIFR ,r24 
ldi r24 , low(5)
ldi r25 , high(5)
rcall wait_msec
in r24, GIFR
sbrc r24, 7
rjmp spin

in r23, PINA
add r23,r22
count:
breq done
lsr r23
brcs increase
rjmp count

increase:
inc r22
rjmp count

done:
out PORTC , r22
lds r26, 0x3D2
reti


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
