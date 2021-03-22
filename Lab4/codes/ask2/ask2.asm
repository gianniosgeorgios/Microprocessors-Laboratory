#include "m16def.inc"

start:
 ;Αρχικοποίηση δείκτη στοίβας 
 ldi r24 , low(RAMEND)
 out SPL , r24
 ldi r24 , high(RAMEND)
 out SPH , r24

 clr r24
 out DDRA, r24
 ser r24
 out DDRB, r24		 ;PORTB έξοδος
 
 ldi r24,0xfc		;αρχικοποίηση PORTD που συνδέεται 
 out DDRD, r24		;η οθόνη ως έξοδος

 rcall temperature
 cpi r25, 0x80
 breq no_div
 rjmp check_zero

no_div:
 rcall lcd_init
 ldi r24, 'N'
 rcall lcd_data		;Τύπωσε το 'N'
 ldi r24, 'o'
 rcall lcd_data		;Τύπωσε το 'o'
 ldi r24, ' '
 rcall lcd_data		;Τύπωσε το ' '
 ldi r24, 'D'
 rcall lcd_data		;Τύπωσε το 'D'
 ldi r24, 'e'
 rcall lcd_data		;Τύπωσε το 'e'
 ldi r24, 'v'
 rcall lcd_data		;Τύπωσε το 'v'
 ldi r24, 'i'
 rcall lcd_data		;Τύπωσε το 'i'
 ldi r24, 'c'
 rcall lcd_data		;Τύπωσε το 'c'
 ldi r24, 'e'
 rcall lcd_data		;Τύπωσε το 'e'
 rjmp start

check_zero:
 cpi r24,0x00
 brne sign

zero:
 rcall lcd_init
 ldi r24, '0'
 rcall lcd_data
 rjmp start

sign:
 cpi r25, 0x00
 brne negative

positive:
 push r24
 rcall lcd_init
 ldi r24, '+'
 rcall lcd_data		;Τύπωσε το '+'
 pop r24
 lsr r24
 adc r24,r25
 rjmp bcd

negative:
 push r24
 rcall lcd_init
 ldi r24, '-'
 rcall lcd_data		;Τύπωσε το '-'
 pop r24
 neg r24
 clr r25
 lsr r24
 adc r24,r25

bcd:
 cpi r24,0x64		
 brcc ekat	
 ldi r28,'0'
 rjmp deci

ekat:
 ldi r28,'1'
 subi r24,0x64

deci:
 ldi r27,0x00	
 cpi r24,0x0A	
 brcc mon
 rjmp end
 
mon:
 inc r27
 subi r24,0x0A
 cpi r24,0x0A	
 brcc mon

end:
 ldi r16,0x30		
 add r27,r16
 add r24,r16
 mov r26,r24

;r26 monades
;r27 dekades
;r28 ekatontades 

lcd:
 cpi r28,'0'			
 brne triple

double:
 cpi r27,'0'
 breq single
 mov r24, r27
 rcall lcd_data
 mov r24, r26
 rcall lcd_data
 ldi r24, '°'
 rcall lcd_data
 ldi r24, 'C'
 rcall lcd_data
 rjmp start

single:
 mov r24, r26
 rcall lcd_data
 ldi r24, '°'
 rcall lcd_data
 ldi r24, 'C'
 rcall lcd_data
 rjmp start

triple:
 mov r24, r28
 rcall lcd_data
 mov r24, r27
 rcall lcd_data
 mov r24, r26
 rcall lcd_data
 ldi r24, '°'
 rcall lcd_data
 ldi r24, 'C'
 rcall lcd_data
 rjmp start


;ρουτίνα αρχικοποίσης και ρυθμίσεων LCD
lcd_init:
 ldi r24 ,40
 ldi r25 ,0
 rcall wait_msec
 ldi r24 ,0x30
 out PORTD ,r24
 sbi PORTD ,PD3
 cbi PORTD ,PD3
 ldi r24 ,39
 ldi r25 ,0
 rcall wait_usec
 ldi r24 ,0x30
 out PORTD ,r24
 sbi PORTD ,PD3
 cbi PORTD ,PD3
 ldi r24 ,39
 ldi r25 ,0
 rcall wait_usec
 ldi r24 ,0x20
 out PORTD ,r24
 sbi PORTD ,PD3
 cbi PORTD ,PD3
 ldi r24 ,39
 ldi r25 ,0
 rcall wait_usec
 ldi r24 ,0x28
 rcall lcd_command
 ldi r24 ,0x0c
 rcall lcd_command
 ldi r24 ,0x01
 rcall lcd_command
 ldi r24 ,low(1530)
 ldi r25 ,high(1530)
 rcall wait_usec
 ldi r24 ,0x06
 rcall lcd_command
 ret

;ρουτίνα αποστολής ενός byte δεδομένων στην LCD
lcd_data:
 sbi PORTD ,PD2
 rcall write_2_nibbles
 ldi r24 ,43
 ldi r25 ,0
 rcall wait_usec
 ret

;ρουτίνα αποστολής μιας εντολής στην LCD
lcd_command:
 cbi PORTD ,PD2
 rcall write_2_nibbles
 ldi r24 ,39
 ldi r25 ,0
 rcall wait_usec
 ret

;ρουτίνα αποστολής ενός byte στην LCD
write_2_nibbles:
 push r24
 in r25 ,PIND
 andi r25 ,0x0f
 andi r24 ,0xf0
 add r24 ,r25
 out PORTD ,r24
 sbi PORTD ,PD3
 cbi PORTD ,PD3
 pop r24
 swap r24
 andi r24 ,0xf0
 add r24 ,r25
 out PORTD ,r24
 sbi PORTD ,PD3
 cbi PORTD ,PD3
 ret


temperature:
 rcall one_wire_reset
 sbrs r24, 0
 rjmp no_device

 ldi r24, 0xCC
 rcall one_wire_transmit_byte

 ldi r24, 0x44
 rcall one_wire_transmit_byte
check:
 rcall one_wire_receive_bit
 sbrs r24, 0
 rjmp check

reset:
 rcall one_wire_reset
 sbrs r24, 0
 rjmp no_device

 ldi r24, 0xCC
 rcall one_wire_transmit_byte

 ldi r24, 0xBE
 rcall one_wire_transmit_byte

 rcall one_wire_receive_byte
 mov r16, r24
 rcall one_wire_receive_byte
 mov r25, r24
 mov r24, r16
 ret

no_device:
 ldi r25,0x80
 ldi r24,0x00
 ret


one_wire_receive_byte:
 ldi r27 ,8
 clr r26
loop_:
 rcall one_wire_receive_bit
 lsr r26
 sbrc r24 ,0
 ldi r24 ,0x80
 or r26 ,r24
 dec r27
 brne loop_
 mov r24 ,r26
 ret

one_wire_receive_bit:
 sbi DDRA ,PA4
 cbi PORTA ,PA4 		; generate time slot
 ldi r24 ,0x02
 ldi r25 ,0x00
 rcall wait_usec
 cbi DDRA ,PA4 		; release the line
 cbi PORTA ,PA4
 ldi r24 ,10 		; wait 10 µs
 ldi r25 ,0
 rcall wait_usec
 clr r24 			; sample the line
 sbic PINA ,PA4
 ldi r24 ,1
 push r24
 ldi r24 ,49 		; delay 49 µs to meet the standards
 ldi r25 ,0 		; for a minimum of 60 µsec time slot
 rcall wait_usec 	; and a minimum of 1 µsec recovery time
 pop r24
 ret

one_wire_transmit_byte:
 mov r26 ,r24
 ldi r27 ,8
_one_more_:
 clr r24
 sbrc r26 ,0
 ldi r24 ,0x01
 rcall one_wire_transmit_bit
 lsr r26
 dec r27
 brne _one_more_
 ret

one_wire_transmit_bit:
 push r24 			; save r24
 sbi DDRA ,PA4
 cbi PORTA ,PA4 		; generate time slot
 ldi r24 ,0x02
 ldi r25 ,0x00
 rcall wait_usec
 pop r24 ; output bit
 sbrc r24 ,0
 sbi PORTA ,PA4
 sbrs r24 ,0
 cbi PORTA ,PA4
 ldi r24 ,58 		; wait 58 µsec for the
 ldi r25 ,0 		; device to sample the line
 rcall wait_usec
 cbi DDRA ,PA4 		; recovery time
 cbi PORTA ,PA4
 ldi r24 ,0x01
 ldi r25 ,0x00
 rcall wait_usec
 ret

one_wire_reset:
 sbi DDRA ,PA4 		; PA4 configured for output
 cbi PORTA ,PA4 		; 480 µsec reset pulse
 ldi r24 ,low(480)
 ldi r25 ,high(480)
 rcall wait_usec
 cbi DDRA ,PA4 		; PA4 configured for input
 cbi PORTA ,PA4
 ldi r24 ,100 		; wait 100 µsec for devices
 ldi r25 ,0 		; to transmit the presence pulse
 rcall wait_usec
 in r24 ,PINA 		; sample the line
 push r24
 ldi r24 ,low(380) 	; wait for 380 µsec
 ldi r25 ,high(380)
 rcall wait_usec
 pop r25 			; return 0 if no device was
 clr r24 			; detected or 1 else
 sbrs r25 ,PA4
 ldi r24 ,0x01
 ret


;Ρουτίνες χρνοκαθυστέρησης 
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
