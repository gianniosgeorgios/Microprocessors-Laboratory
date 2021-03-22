### Lab 2: Familiarizing with ARM  microcontroller and its Instruction Set Architecture

![arm-processor](https://user-images.githubusercontent.com/50829499/112064647-fbf79380-8b6b-11eb-86aa-8ed6cd905433.jpg)

#### 1. Simple timer on `LEDS PORT` and counting external interrputs 

When timer on `PORTB LEDS` is on progress, then, provided that dip-switch `PD7` is ON, `INT1` (`PD3`) interrupts are counted in `LEDS PΑ7-PΑ0`. It is necessary to controll spin in switch press.

#### 2. Simple timer on leds port and counting on dip - switches

As timer on `PORTB LEDS` is on progress, when an external interrupt `INT0 (PD2)` occurs, ON dip-switces of `PORTA (PA7-PA0)` are counted in `PORTC` leds (`PC7-PC0`).


#### 3. Contolling of a luminaire automation  

When button `PA7` is pressed or an external interrupt `PD3` occurs,`PB0` led is turned  ON for 4 msec. After this time has passed, led is turned OFF and all leds are turned ON for 0.5 msec. However if `PA7` is pressed or an external interrupts occurs again, time is reloaded
