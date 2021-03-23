### Lab 4: Combining sensory data from temperature sources


![71-gFUwqUlL _SX425_](https://user-images.githubusercontent.com/50829499/112127715-65a88980-8bce-11eb-9fc1-752d0f712c7f.jpg)


#### 1. Display environment's temperature on LEDS

Taking temperature from  `DS1820 ` sensor and displaying it to  `PORB ` leds. The resolution (he minimum change in input that can be sensed) is about 0.5 °C.Note that 8  `MSB ` 
correspond to sign value (sign extention), and 8  `LSB ` to temperature's value (as 2nd complement)
Examples:

* Example 1: 
 ```
 0x0032 = 25 °C
 ```
* Example 2:
 ```
 0xFFFF = - 0.5 °C
 ```
 * Example 3:
 ```
 0xFF92 = - 55 °C
 ```
#### 2. Display environment's temperature on LCD screen 
