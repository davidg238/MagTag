# MagTag

This library simplifies usage of the Adafruit [MagTag](https://www.adafruit.com/product/4800) board with [Toit](https://toit.io/).  


## Wiring 

The device may be programmmed via the USB C connector, by entering boot mode (see Ref2. Reset and Boot0) then executing:  
```
jag flash --chip esp32s2
```
The Toit console is available on JP2 (TXD0/RXD0), not via the USB C connector (IO19,20) so a little soldering is required.  
For the cable in Ref5. RX/TX/GND were connected.

## Progress:

|  Feature, support  | Y | N |Notes |
| :---      |:-:|:-:|:- |
| 2.9” 296x128 greyscale E-ink display  |  | N | |
| Four RGB NeoPixels | Y | |  |
| Red LED | Y | |  |
| Four buttons | Y |  | Only Button-B works; A and C should, not D
| Triple-axis accelerometer | Y | | 
| Speaker/Buzzer | | N | 
| Light sensor  | Y | | 
| Battery voltage  | Y | | 
| Stemma QT/Qwiic connector |  | N | (Untested)
| Two STEMMA 3pin JST ports | |N | (Untested)
| UART Debug | Y | | JP2, Toit console

## Notes


## Links
1. [MagTag](https://www.adafruit.com/product/4800)
2. [learn.adafruit MagTag](https://learn.adafruit.com/adafruit-magtag)
3. [MagTag schematic](https://learn.adafruit.com/assets/96946)
4. [MagTag pinouts](https://learn.adafruit.com/assets/102127)
5. [USB to TTL Serial Cable - Debug/Console](https://www.adafruit.com/product/954)
6. [2.9inch e-Paper V2 Specifion-WS](https://files.waveshare.com/upload/7/79/2.9inch-e-paper-v2-specification.pdf)
7. [Python driver interface](https://www.waveshare.com/wiki/E-Paper_API_Analysis#Driver_Interface)



"Once a new technology rolls over 