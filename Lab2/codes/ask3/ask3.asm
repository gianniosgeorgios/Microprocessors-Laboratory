#include "m16def.inc"

.org 0x0
rjmp reset

.org 0x4
rjmp ISR1

.org 0x10
rjmp ISR_TIMER1_OVF ;ρουτίνα εξυπηρέτησης του timer1

reset:
ldi r24 ,( 1 << ISC11) | ( 0 << ISC10) ;κατερχόμενη ακμή
out MCUCR , r24 
ldi r24 ,( 1 << INT1)
out GICR , r24
sei 

ldi r24 , low(RAMEND)
out SPL , r24
ldi r24 , high(RAMEND)
out SPH , r24

ser r26 
out DDRB, r26 ;έξοδος
clr r26
out DDRA, r26 ;είσοδος

ldi r24 ,(1<<TOIE1) ;ενεργοποίηση διακοπής υπερχύλισης 
out TIMSK ,r24      ;για timer1

ldi r24 ,(1<<CS12) | (0<<CS11) | (1<<CS10) ; CK/1024
out TCCR1B ,r24 

main:
sbis PINA, 7 ;έλεγχος πατήματος PA7
rjmp main
main2:
sbic PINA, 7 ;έλεγχος αφήματος PA7
rjmp main2

ldi r24, 0x85    ;αρχικοποίσηση TCNT1
out TCNT1H, r24  ;για 4 sec
ldi r24, 0xEE
out TCNT1L, r24

sbic PINB, 0 ;έλεγχος PB0
rjmp reload1

ldi r26, 0x01   ;άναμα PB0
out PORTB, r26
rjmp main

reload1:
ldi r26, 0xFF
out PORTB, r26
ldi r24, low(500) 
ldi r25, high(500)
rcall wait_msec
ldi r26, 0x01
out PORTB, r26
rjmp main

ISR1:
ldi r24,0x85 ; αρχικοποίσηση TCNT1
out TCNT1H ,r24 ;για 4 sec
ldi r24, 0xEE
out TCNT1L ,r24

sbic PINB, 0 ;έλεγχος PB0
rjmp reload2

ldi r26, 0x01   ;άναμα PB0
out PORTB, r26
reti

reload2:
ldi r26, 0xFF
out PORTB, r26
ldi r24, low(500) 
ldi r25, high(500)
rcall wait_msec
ldi r26, 0x01
out PORTB, r26
reti

ISR_TIMER1_OVF:
ldi r26, 0x00
out PORTB, r26 ;σβήνουν όλα
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
