### Lab 3: Developing programms using LCD screen and keypad of ARM microcontroller 

![lcd_keypad_shield](https://user-images.githubusercontent.com/50829499/112069409-70363500-8b74-11eb-85e2-44225259a6b0.jpg)

#### 1. Building a simple Εlectronic lock using Keypad

If the number of our Team is pressed using `KEYPAD`, then all `LEDS` are turned ON for 4sec. If not then all `LEDs` are turned ON for 0.25 and OFF for 0.25 consecutively for 4 sec 
in total.

#### 2. HEX to DEC convertion on lcd screen 

The input,one 2-digit HEX (as 2nd complement) number, is read from keypad. Then is converted to DECIMAL form with sign. Examples:

* Example 1:
```
6E=+110
```
* Example 2: 
```
80=-128
```
#### 3. Digital timer in LCD screen 

On `LCD` screen a timer is displayed in form `MM:SS ` When timer reaches the value `59:59` starts from beggining.  Timer starts if `PB7` is pressed, and continues provided this. It stops if `PB0` is pressed.   
