#include "m16def.inc"

reset:
 ;Αρχικοποίηση δείκτη στοίβας 
 ldi r24 , low(RAMEND)
 out SPL , r24
 ldi r24 , high(RAMEND)
 out SPH , r24

 ldi r24,0xfc		;αρχικοποίηση PORTD που συνδέεται 
 out DDRD, r24		;η οθόνη ως έξοδος
 
 clr r24
 out DDRB,r24

 ;Αρχικοποίηση μετρητή
clear:
 ldi r29, '0'		;min_decades
 ldi r28, '0'		;min_monades
 ldi r27, '0'		;sec_decades
 ldi r26, '0'		;sec_monades

loopp:	
 
 rcall lcd_init		;Αρχικοποίηση οθόνης
 mov r24, r29		
 rcall lcd_data		;Τύπωσε min_decades
 mov r24, r28
 rcall lcd_data		;Τύπωσε min_monades
 ldi r24, 'M'
 rcall lcd_data		;Τύπωσε το 'M'
 ldi r24, 'I'
 rcall lcd_data		;Τύπωσε το 'I'
 ldi r24, 'N'
 rcall lcd_data		;Τύπωσε το 'N'
 ldi r24, ':'
 rcall lcd_data		;Τύπωσε το ':'
 mov r24, r27
 rcall lcd_data		;Τύπωσε sec_decades
 mov r24, r26
 rcall lcd_data		;Τύπωσε sec_monades
 ldi r24, 'S'
 rcall lcd_data		;Τύπωσε το 'S'
 ldi r24, 'E'
 rcall lcd_data		;Τύπωσε το 'E'
 ldi r24, 'C'
 rcall lcd_data		;Τύπωσε το 'C'

 ldi r24,low(1000)
 ldi r25,high(1000)
 rcall wait_msec	;Καθυστέρησε 1sec

 cpi r26, '9'
 breq zero_sec
 inc r26

 stop_1:
 sbic PINB,7		;Aν πατηθεί το PB7, ξεκίνα τη μέτρηση απο
 rjmp clear  		;την αρχή 
;Όσο ο διακόπτης ειναι 1 		
 sbis PINB,0		;συνέχισε τη μετρηση σου 
 rjmp stop_1
 rjmp loopp

zero_sec:
 cpi r27, '5'
 breq one_minute
 inc r27
 ldi r26, '0'

stop_2:
 sbic PINB,7		;Aν πατηθεί το PB7, ξεκίνα τη μέτρηση απο
 rjmp clear  		;την αρχή 
;Όσο ο διακόπτης ειναι 1 		
 sbis PINB,0		;συνέχισε τη μετρηση σου 
 rjmp stop_2
 rjmp loopp

one_minute:
 cpi r28, '9'
 breq zero_min
 inc r28
 ldi r27, '0'
 ldi r26, '0'

stop_3:
 sbic PINB,7		;Aν πατηθεί το PB7, ξεκίνα τη μέτρηση απο
 rjmp clear  		;την αρχή 
;Όσο ο διακόπτης ειναι 1 		
 sbis PINB,0		;συνέχισε τη μετρηση σου 
 rjmp stop_3
 rjmp loopp

zero_min:
 cpi r29, '5'
 breq one_hour
 inc r29
 ldi r28, '0'
 ldi r27, '0'
 ldi r26, '0'

stop_4:
 sbic PINB,7		;Aν πατηθεί το PB7, ξεκίνα τη μέτρηση απο
 rjmp clear  		;την αρχή 
;Όσο ο διακόπτης ειναι 1 		
 sbis PINB,0		;συνέχισε τη μετρηση σου 
 rjmp stop_4
 rjmp loopp

one_hour:
 ldi r29, '0'
 ldi r28, '0'
 ldi r27, '0'
 ldi r26, '0'

stop_5:
 sbic PINB,7		;Aν πατηθεί το PB7, ξεκίνα τη μέτρηση απο
 rjmp clear  		;την αρχή 
;Όσο ο διακόπτης ειναι 1 		
 sbis PINB,0		;συνέχισε τη μετρηση σου 
 rjmp stop_5
 rjmp loopp


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
