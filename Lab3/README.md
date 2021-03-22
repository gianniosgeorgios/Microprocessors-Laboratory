### Lab 3: Developing programms using LCD screen and keypad of ARM microcontroller 

![lcd_keypad_shield](https://user-images.githubusercontent.com/50829499/112066801-b046e900-8b6f-11eb-8032-9270ef1e72fb.jpg)

#### 1. Building a simple Εlectronic lock using Keypad

If the number of our Team is pressed using `KEYPAD`, then all `LEDS` are turned ON for 4sec. If not then all `LEDs` are turned ON for 0.25 and OFF for 0.25 consecutively for 4 sec 
in total.

#### 2. HEX to DEC convertion on lcd screen 

The input,one 2-digit HEX (as 2nd complement) number, is read from keypad. Then is converted to DECIMAL form with sign. Examples:

```
6E=+110
```
```
80=-128
```
#### 3. Digital timer in form `MM:SS`
