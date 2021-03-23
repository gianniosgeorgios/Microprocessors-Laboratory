### Lab 5: Serial communication and Analog to Digital Convertion 

![Στιγμιότυπο οθόνης 2021-03-23 122353](https://user-images.githubusercontent.com/50829499/112131934-c0dc7b00-8bd2-11eb-96d4-b146182b34e4.png)


#### 1. Sending strings from `RAM` to `UART` of ATmega16

A message (with \0 as ending character) is sent from program's RAM to UART and shows up in `ARDUINO's IDE`

#### 2. Reading number from `UART` and display it to `LEDS PORT`

The input number ([0-8]) is read from `ARDUINO IDE` and is sent to board, in order to open corresponding `LED`

#### 3. Reading, analyzing and processing **Analog signals**

* The analog input of potentiometer is converted to digital output in `UART` (input is mapped to [0, 4.99] range).

*
