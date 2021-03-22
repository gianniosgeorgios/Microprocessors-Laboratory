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

 ser r24
 out DDRB, r24		 ;PORTB έξοδος

;Θέτουμε ως έξoδο τα 4 MSB του PORTC για το keybpad
 ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)
 out DDRC ,r24

first_key:
 ldi r24,0x05		;5ms σπινθηρισμού
 rcall scan_keypad_rising_edge
 rcall keypad_to_ascii
 cpi r24,0x00		;Αν είναι μηδέν τότε δεν πατήθηκε τίποτα και
 breq first_key		;ξαναπήγαινε στο first_key
 mov r28, r24		;Αποθήκευσε προσωρινά στον r28

second_key:
 ldi r24,0x05		;5ms σπινθηρισμού
 rcall scan_keypad_rising_edge
 rcall keypad_to_ascii
 cpi r24,0x00		;Αν είναι μηδέν τότε δεν πατήθηκε τίποτα και
 breq second_key	;ξαναπήγαινε στο second_key
 ldi r16,8			;Φόρτωση μετρητή άναψε/σβήσε 
 cpi r24,'6'		;Σύγκρινε τον 2ο αριθμό εισόδου με της ομάδας
 brne wrong			;Αν δεν είναι ίσοι πήγαινε στο wrong
 cpi r28,'1'		;Σύγκρινε τον 1ο αριθμό εισόδου με της ομάδας
 brne wrong			;Αν δεν είναι ίσοι πήγαινε στο wrong


alright:
 ldi r26, 0xFF		
 out PORTB, r26	  	;’ναμμα όλων των LED
 ldi r24, low(4000) ;delay 4sec
 ldi r25, high(4000)
 rcall wait_msec
 ldi r26, 0x00
 out PORTB, r26 	;Σβήνουν όλα τα LED και
 rjmp reset			;ξαναπηγαίνουμε στην αρχή να πάρουμε νέα είσοδο

wrong:
 ldi r26, 0xFF		
 out PORTB, r26		;’ναμμα όλων των LED για 0.25 sec
 ldi r24, low(250)	;delay 0.25sec
 ldi r25, high(250)
 rcall wait_msec
 ldi r26, 0x00
 out PORTB, r26		;Σβήσιμο όλων των LED για 0.25 sec
 ldi r24, low(250) 
 ldi r25, high(250)
 rcall wait_msec
 dec r16
 breq reset			;Όταν γίνει αυτό 8 φορές (4sec)
 rjmp wrong			;επιστρέφουμε στην αρχή να πάρουμε νέα είσοδο


keypad_to_ascii:;λογικό 1 στις θέσεις του καταχωρητή r26 δηλώνουν
 movw r26 ,r24	;τα παρακάτω σύμβολα και αριθμούς
 ldi r24 ,'*'
 sbrc r26 ,0
 ret
 ldi r24 ,'0'
 sbrc r26 ,1
 ret
 ldi r24 ,'#'
 sbrc r26 ,2
 ret
 ldi r24 ,'D'
 sbrc r26 ,3	;αν δεν είναι 1παρακάμπτει την ret, αλλιώς (αν είναι 1)
 ret 			;επιστρέφει με τον καταχωρητή r24 την ASCII τιμή του D.
 ldi r24 ,'7'
 sbrc r26 ,4
 ret
 ldi r24 ,'8'
 sbrc r26 ,5
 ret
 ldi r24 ,'9'
 sbrc r26 ,6
 ret
 ldi r24 ,'C'
 sbrc r26 ,7
 ret
 ldi r24 ,'4' 	;λογικό 1 στις θέσεις του καταχωρητή r27 δηλώνουν
 sbrc r27 ,0 	;τα παρακάτω σύμβολα και αριθμούς
 ret
 ldi r24 ,'5'
 sbrc r27 ,1
 ret
 ldi r24 ,'6'
 sbrc r27 ,2
 ret
 ldi r24 ,'B'
 sbrc r27 ,3
 ret
 ldi r24 ,'1'
 sbrc r27 ,4
 ret
 ldi r24 ,'2'
 sbrc r27 ,5
 ret
 ldi r24 ,'3'
 sbrc r27 ,6
 ret
 ldi r24 ,'A'
 sbrc r27 ,7
 ret
 clr r24		;αν δεν πατήθηκε τίποτα επιστρέφει μηδέν
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
