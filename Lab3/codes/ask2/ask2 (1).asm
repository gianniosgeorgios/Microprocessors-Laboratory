#include "m16def.inc"

.DSEG
 _tmp_: .byte 2

.CSEG

reset:
 ;������������ ������ ������� 
 ldi r24 , low(RAMEND)
 out SPL , r24
 ldi r24 , high(RAMEND)
 out SPH , r24

 ldi r24, 0xfc		;������������ PORTD ��� ��������� 
 out DDRD, r24		;� ����� �� ������

;������� �� ��o�� �� 4 MSB ��� PORTC
 ldi r24 ,(1 << PC7) | (1 << PC6) | (1 << PC5) | (1 << PC4)
 out DDRC ,r24

first_key:
 ldi r24,0x05		;5ms ������������
 rcall scan_keypad_rising_edge
 rcall keypad_to_hex
 cpi r24,0x10		;�� ����� 0x10 ���� ��� �������� ������ ���
 breq first_key		;����������� ��� first_key
 andi r24,0x0F		;��������� �� LSB
 mov r17,r24		;r17=1o �����
 swap r24			;LSB -> MSB
 mov r16, r24		;���������� ��������� ���� r16

second_key:
 ldi r24,0x05		;5ms ������������
 rcall scan_keypad_rising_edge
 rcall keypad_to_hex
 cpi r24,0x10		;�� ����� 0x10 ���� ��� �������� ������ ���
 breq second_key	;����������� ��� second_key
 andi r24,0x0F		;��������� �� LSB
 mov r18,r24		;r18=2o �����
 add r24,r16		;�������� ��� ����������� ������
 

;������� �������
cpi r24,0x00
brne sign

zero:
 rcall lcd_init
 ldi r24, '0'
 rcall lcd_data
 ldi r24, '0'
 rcall lcd_data
 ldi r24, '='
 rcall lcd_data
 ldi r24, '0'
 rcall lcd_data
 rjmp reset

;������� ��������
sign:
 sbrs r24,7			;�� r24(7)=1 ������ �������� ������
 rjmp positive

negative:			;��������� �� ����� ��� ��������� �������
 ldi r29,'-'
 andi r24,0x7F
 ldi r25,0x80
 sub r25,r24
 mov r24,r25
 rjmp bcd

positive:
 ldi r29,'+'

bcd:
 cpi r24,0x64		;�������� ������ �� �� 100
 brcc ekat			;�� ����� >= 100 ������� ��� ekat
 ldi r28,'0'		;����������� (r28) = 0
 rjmp deci

ekat:
 ldi r28,'1'		;����������� (r28) = 1
 subi r24,0x64

deci:
 ldi r27,0x00		;������������ ������� (r27) ��� 0
 cpi r24,0x0A		;�������� ������ �� �� 10
 brcc mon			;�� ����� >= 10 ������� ��� mon
 rjmp end
 
mon:
 inc r27
 subi r24,0x0A
 cpi r24,0x0A		;�������� ������ �� �� 10
 brcc mon			;�� ����� >= 10 ������� ��� mon

end:
 ldi r16,0x30		
 add r27,r16		;��������� �� ascii
 add r24,r16		;��������� �� ascii
 mov r26,r24		;��������� �� ascii
 add r17,r16		;��������� �� ascii
 add r18,r16		;��������� �� ascii
 cpi r17,0x3A
 brcc greater1
 cpi r18,0x3A
 brcc greater2
 rjmp lcd

greater1:
 ldi r16,0x07
 add r17, r16
 cpi r18,0x3A
 brcc greater2
 rjmp lcd

greater2:
 ldi r16,0x07
 add r18, r16
 

;����� ������ ������ ���� r29:�������, r28:ekat, r27:dec, r26:mon ��� ������� �������� ����� r17-r18
lcd:
rcall lcd_init		;������������ ������
mov r24, r17
rcall lcd_data		;�������� 1o� ������
mov r24, r18
rcall lcd_data		;�������� 2o� ������
ldi r24,'='
rcall lcd_data		;�������� ��� ����
mov r24, r29		;�������� ��������
rcall lcd_data		;���� �����

cpi r28,'0'			;�� ekat!=0 
brne triple			;������� ��� triple

double:
 cpi r27,'0'		;�� dec==0
 breq single		;������� ��� single
 mov r24, r27
 rcall lcd_data		;������ �������
 mov r24, r26
 rcall lcd_data		;������ �������
 rjmp reset

single:
 mov r24, r26
 rcall lcd_data		;������ �������
 rjmp reset

triple:
 mov r24, r28
 rcall lcd_data		;������ �����������
 mov r24, r27
 rcall lcd_data		;������ �������
 mov r24, r26
 rcall lcd_data		;������ �������
 rjmp reset


;������� ������������� ��������� �� hex
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
 ldi r24, 0x10		;�� ��� �������� ������ ������� �� 0x010
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


;������� ������� ���� ��� �������������
scan_keypad:
 ldi r24 , 0x01	; ������ ��� ����� ������ ��� �������������
 rcall scan_row
 swap r24 		; ���������� �� ����������
 mov r27 , r24 	; ��� 4 msb ��� r27
 ldi r24 ,0x02	; ������ �� ������� ������ ��� �������������
 rcall scan_row
 add r27 , r24 	; ���������� �� ���������� ��� 4 lsb ��� r27
 ldi r24 , 0x03 ; ������ ��� ����� ������ ��� �������������
 rcall scan_row
 swap r24 		; ���������� �� ����������
 mov r26 , r24 	; ��� 4 msb ��� r26
 ldi r24 ,0x04 	; ������ ��� ������� ������ ��� �������������
 rcall scan_row
 add r26 , r24 	; ���������� �� ���������� ��� 4 lsb ��� r26
 movw r24 , r26 ; �������� �� ���������� ����� ����������� r25:r24
 ret


;������� ������� ���� ������� ��� �������������
scan_row:
 ldi r25 , 0x08	; ������������ �� �0000 1000�
back_: 
 lsl r25 		; �������� �������� ��� �1� ����� ������
 dec r24		; ���� ����� � ������� ��� �������
 brne back_
 out PORTC , r25; � ���������� ������ ������� ��� ������ �1�
 nop			; ����������� ��� �� �������� �� ����� � ������ ����������
 nop 
 in r24 , PINC 	; ����������� �� ������ (������) ��� ��������� ��� ����� ���������
 andi r24 ,0x0f ; ������������� �� 4 LSB ���� �� �1� �������� ��� ����� ���������
 ret 			; �� ���������.

;������� ������������ ��� ��������� LCD
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

;������� ��������� ���� byte ��������� ���� LCD
lcd_data:
 sbi PORTD ,PD2
 rcall write_2_nibbles
 ldi r24 ,43
 ldi r25 ,0
 rcall wait_usec
 ret

;������� ��������� ���� ������� ���� LCD
lcd_command:
 cbi PORTD ,PD2
 rcall write_2_nibbles
 ldi r24 ,39
 ldi r25 ,0
 rcall wait_usec
 ret

;������� ��������� ���� byte ���� LCD
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

;�������� ���������������� 
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
