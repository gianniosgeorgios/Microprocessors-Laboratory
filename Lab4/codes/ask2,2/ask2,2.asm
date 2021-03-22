#include "m16def.inc"

.DSEG
 _tmp_: .byte 2

.CSEG

reset:
 ;Αρχικοποίηση δείκτη στοίβας 
 ldi r24 , low(RAMEND)
 out SPL , r24
 ldi r24 , high(RAMEND)
 out SPH , r24

 ldi r24, 0xfc		;αρχικοποίηση PORTD που συνδέεται 
 out DDRD, r24		;η οθόνη ως έξοδος

;Θέτουμε ως έξoδο τα 4 MSB του PORTC
 ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)
 out DDRC ,r24

first_key:
 ldi r24,0x05		;5ms σπινθηρισμού
 rcall scan_keypad_rising_edge
 rcall keypad_to_hex
 ;ldi r24,0x08
 cpi r24,0x10		;αν είναι 0x10 τότε δεν πατήθηκε τίποτα και
 breq first_key		;ξαναπήγαινε στο first_key
 andi r24,0x0F		;απομώνωσε τα LSB
 mov r16,r24		;r16=1o ψηφίο
 swap r24			;LSB -> MSB
 mov r29, r24		;αποθήκευσε

 ldi r20, 0x30
 cpi r16,0x0A
 brcc is_letter1
 add r16,r20
 rjmp second_key

is_letter1:
 ldi r20, 0x37
 add r16,r20


second_key:
 ldi r24,0x05		;5ms σπινθηρισμού
 rcall scan_keypad_rising_edge
 rcall keypad_to_hex
 ;ldi r24,0x00
 cpi r24,0x10		;αν είναι 0x10 τότε δεν πατήθηκε τίποτα και
 breq second_key	;ξαναπήγαινε στο second_key
 andi r24,0x0F		;απομώνωσε τα LSB
 mov r17,r24		;r17=2o ψηφίο
 add r29,r17		;πρόσθεσε τον προηγούμενο αριθμό

 ldi r20, 0x30
 cpi r17,0x0A
 brcc is_letter2
 add r17,r20
 rjmp third_key

is_letter2:
 ldi r20, 0x37
 add r17,r20

third_key:
 ldi r24,0x05		;5ms σπινθηρισμού
 rcall scan_keypad_rising_edge
 rcall keypad_to_hex
 ;ldi r24,0x00
 cpi r24,0x10		;αν είναι 0x10 τότε δεν πατήθηκε τίποτα και
 breq third_key 	;ξαναπήγαινε στο third_key
 andi r24,0x0F		;απομώνωσε τα LSB
 mov r18,r24		;r18=3o ψηφίο ascii
 swap r24			;LSB -> MSB
 mov r21, r24		;αποθήκευσε προσωρινά στον r21

 ldi r20, 0x30
 cpi r18,0x0A
 brcc is_letter3
 add r18,r20
 rjmp fourth_key

is_letter3:
 ldi r20, 0x37
 add r18,r20

fourth_key:
 ldi r24,0x05		;5ms σπινθηρισμού
 rcall scan_keypad_rising_edge
 rcall keypad_to_hex
 ;ldi r24,0x00
 cpi r24,0x10		;αν είναι 0x10 τότε δεν πατήθηκε τίποτα και
 breq fourth_key	;ξαναπήγαινε στο fourth_key
 andi r24,0x0F		;απομώνωσε τα LSB
 mov r19,r24		;r19=4o ψηφίο
 add r21,r24		;πρόσθεσε τον προηγούμενο αριθμό

 ldi r20, 0x30
 cpi r19,0x0A
 brcc is_letter4
 add r19,r20
 rjmp print_keys

is_letter4:
 ldi r20, 0x37
 add r19,r20

;Στον r29,r21 έχουμε την θερμοκρασία και στους r16-r19 τα ψηφία προς εκτύπωση

print_keys:
 rcall lcd_init
 mov r24,r16
 rcall lcd_data
 mov r24,r17
 rcall lcd_data
 mov r24,r18
 rcall lcd_data
 mov r24,r19
 rcall lcd_data
 ldi r24, '='
 rcall lcd_data
 ldi r24, '>'
 rcall lcd_data

check_device:
 cpi r29, 0x80
 brne check2
 cpi r21, 0x00
 brne error

no_div:
 ldi r24, 'N'
 rcall lcd_data		;Τύπωσε το 'N'
 ldi r24, 'O'
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
 rjmp reset

check2: 
 cpi r29, 0x00
 breq check_zero
 cpi r29, 0xFF
 breq negative
 rjmp error

check_zero:
 cpi r21,0x00
 brne positive

zero:
 ldi r24, '0'
 rcall lcd_data
 ldi r24, '°'
 rcall lcd_data
 ldi r24, 'C'
 rcall lcd_data
 rjmp reset

error:
 ldi r24, 'E'
 rcall lcd_data		;Τύπωσε το 'E'
 ldi r24, 'R'
 rcall lcd_data		;Τύπωσε το 'R'
 ldi r24, 'R'
 rcall lcd_data		;Τύπωσε το 'R
 ldi r24, 'O'
 rcall lcd_data		;Τύπωσε το 'O'
 ldi r24, 'R'
 rcall lcd_data		;Τύπωσε το 'R'
 rjmp reset

negative:			;Βρίσκουμε το μέτρο του αρνητικού αριθμού
 neg r21
 cpi r21, 0x00		;OVERFLOW
 breq error
 clr r29
 lsr r21
 adc r21,r29
 cpi r21,0x38
 brcc error
 ldi r24,'-'
 rcall lcd_data
 rjmp bcd

positive:
 clr r29
 lsr r21
 adc r21,r29
 cpi r21,0x7e
 brcc error
 ldi r24,'+'
 rcall lcd_data
  

bcd:
 mov r24,r21
 cpi r24,0x64		;Σύγκριση μέτρου με το 100
 brcc ekat			;Αν είναι >= 100 πήγαινε στο ekat
 ldi r28,'0'		;Εκατοντάδες (r28) = 0
 rjmp deci

ekat:
 ldi r28,'1'		;Εκατοντάδες (r28) = 1
 subi r24,0x64

deci:
 ldi r27,0x00		;Αρχικοποίηση δεκάδων (r27) στο 0
 cpi r24,0x0A		;Σύγκριση μέτρου με το 10
 brcc mon			;Αν είναι >= 10 πήγαινε στο mon
 rjmp end
 
mon:
 inc r27
 subi r24,0x0A
 cpi r24,0x0A		;Σύγκριση μέτρου με το 10
 brcc mon			;Αν είναι >= 10 πήγαινε στο mon

;Οπότε τελικά έχουμε στον r28:ekat σε ascii, r27:dec, r26:mon και αρχικός τετραψήφιος στους r16-r19

end:
 ldi r20,0x30		
 add r27,r20		;Μετατροπή σε ascii
 add r24,r20		;Μετατροπή σε ascii
 mov r26,r24		;Μετατροπή σε ascii

 cpi r28,'0'		;Αν ekat!=0 
 brne triple		;πήγαινε στο triple

double:
 cpi r27,'0'		;Αν dec==0
 breq single		;πήγαινε στο single
 mov r24, r27
 rcall lcd_data		;Τύπωσε δεκάδες
 mov r24, r26
 rcall lcd_data		;Τύπωσε μονάδες
 ldi r24, '°'
 rcall lcd_data
 ldi r24, 'C'
 rcall lcd_data
 rjmp reset

single:
 mov r24, r26
 rcall lcd_data		;Τύπωσε μονάδες
 ldi r24, '°'
 rcall lcd_data
 ldi r24, 'C'
 rcall lcd_data
 rjmp reset

triple:
 mov r24, r28
 rcall lcd_data		;Τύπωσε εκατοντάδες
 mov r24, r27
 rcall lcd_data		;Τύπωσε δεκάδες
 mov r24, r26
 rcall lcd_data		;Τύπωσε μονάδες
 ldi r24, '°'
 rcall lcd_data
 ldi r24, 'C'
 rcall lcd_data
 rjmp reset
 
 
 ;ρουτίνα αντιστοίχισης διακοπτών σε hex
keypad_to_hex:
 movw r26 ,r24
 ldi r24 ,0x0E
 sbrc r26 ,0
 ret
 ldi r24 ,0x00
 sbrc r26 ,1
 ret
 ldi r24 ,0x0F
 sbrc r26 ,2
 ret
 ldi r24 ,0x0D
 sbrc r26 ,3
 ret
 ldi r24 ,0x07
 sbrc r26 ,4
 ret
 ldi r24 ,0x08
 sbrc r26 ,5
 ret
 ldi r24 ,0x09
 sbrc r26 ,6
 ret
 ldi r24 ,0x0C
 sbrc r26 ,7
 ret
 ldi r24 ,0x04
 sbrc r27 ,0
 ret
 ldi r24 ,0x05
 sbrc r27 ,1
 ret
 ldi r24 ,0x06
 sbrc r27 ,2
 ret
 ldi r24 ,0x0B
 sbrc r27 ,3
 ret
 ldi r24 ,0x01
 sbrc r27 ,4
 ret
 ldi r24 ,0x02
 sbrc r27 ,5
 ret
 ldi r24 ,0x03
 sbrc r27 ,6
 ret
 ldi r24 ,0x0A
 sbrc r27 ,7
 ret
 ldi r24, 0x10		;Αν δεν πατήθηκε τίποτα φόρτωσε το 0x010
 ret

scan_keypad_rising_edge:
 mov r22 ,r24
 rcall scan_keypad
 push r24
 push r25
 mov r24 ,r22
 ldi r25 ,0
 rcall wait_msec
 rcall scan_keypad
 pop r23
 pop r22
 and r24 ,r22
 and r25 ,r23
 ldi r26 ,low(_tmp_)
 ldi r27 ,high(_tmp_)
 ld r23 ,X+
 ld r22 ,X
 st X ,r24
 st -X ,r25
 com r23
 com r22
 and r24 ,r22
 and r25 ,r23
 ret


;Ρουτίνα ελέγχου όλου του πληκτρολογίου
scan_keypad:
 ldi r24 , 0x01	; έλεγξε την πρώτη γραμμή του πληκτρολογίου
 rcall scan_row
 swap r24 		; αποθήκευσε το αποτέλεσμα
 mov r27 , r24 	; στα 4 msb του r27
 ldi r24 ,0x02	; έλεγξε τη δεύτερη γραμμή του πληκτρολογίου
 rcall scan_row
 add r27 , r24 	; αποθήκευσε το αποτέλεσμα στα 4 lsb του r27
 ldi r24 , 0x03 ; έλεγξε την τρίτη γραμμή του πληκτρολογίου
 rcall scan_row
 swap r24 		; αποθήκευσε το αποτέλεσμα
 mov r26 , r24 	; στα 4 msb του r26
 ldi r24 ,0x04 	; έλεγξε την τέταρτη γραμμή του πληκτρολογίου
 rcall scan_row
 add r26 , r24 	; αποθήκευσε το αποτέλεσμα στα 4 lsb του r26
 movw r24 , r26 ; μετέφερε το αποτέλεσμα στους καταχωρητές r25:r24
 ret


;Ρουτίνα ελέγχου μιας γραμμής του πληκτρολογίου
scan_row:
 ldi r25 , 0x08	; αρχικοποίηση με 0000 1000
back_: 
 lsl r25 		; αριστερή ολίσθηση του 1 τόσες θέσεις
 dec r24		; όσος είναι ο αριθμός της γραμμής
 brne back_
 out PORTC , r25; η αντίστοιχη γραμμή τίθεται στο λογικό 1
 nop			; καθυστέρηση για να προλάβει να γίνει η αλλαγή κατάστασης
 nop 
 in r24 , PINC 	; επιστρέφουν οι θέσεις (στήλες) των διακοπτών που είναι πιεσμένοι
 andi r24 ,0x0f ; απομονώνονται τα 4 LSB όπου τα 1 δείχνουν που είναι πατημένοι
 ret 			; οι διακόπτες.

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
