### Lab 1: Familiarizing with 8085 microcontroller and its Instruction Set Architecture

![images](https://user-images.githubusercontent.com/50829499/112064493-b76bf800-8b6b-11eb-9cd8-d60619f436a7.jpg)


#### 1. Create a simple timer on LEDS

Using `DELB` routine for time delay (*1 sec*), we build a seconds' timer in `LEDS` PORT. When timer reaches the value
that is defined by the 4 dip-switches (in range [0-15]),  the countdown starts. Provided for these, the LSB of dip 
switches is ON. 

#### 2. Counting external interrupts during timing proccess 

When timer is on progress, we count `INTERRUPTS` in the right `7-segment display`, modulo 10 in decimal form.
Provided for that, `LSB` of `dip-switces` is ON.

#### 3. Compute a numeric expression and displaying to LCD screen 

The input is two  (x,y) hex numbers in range [0-F] from `KEYPAD`. Then the expression ` x-y` is computed, and 
shows up in three left 7-segment display with sign

#### 4. Controller of an wagon's automation mobving through LEDS

Provided that MSB `dip-switch` is ON, a wagon moves through `LEDs` periodically. If the switch is turned OFF, wagon chabges direction
