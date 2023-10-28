// Copyright 2023 Ekorau LLC
import device show hardware_id
import gpio
import i2c
import spi
import net

import gpio.adc show Adc
import esp32
import math show pow
import bitmap show bytemap_zap
import system.storage as storage

import pixel_strip show PixelStrip
import pixel-display show TwoColorPixelDisplay
// import .waveshare-2-color-2-9
import lis3dh


// Specific for the Adafruit MagTag.  https://www.adafruit.com/product/4800
BUTTON_A ::= 15
BUTTON_B ::= 14
BUTTON_C ::= 12
// BUTTON_D ::= 11  // Not available in Toit, refer esp32.toit.

RED_LED ::= 13

NEOPOWER_PIN ::= 21
NEOPIXEL_PIN ::= 1
NEOPIXELS ::= 4

LIGHT ::= 3
BATTERY_VOLTAGE ::= 4

ACCELEROMETER_INTERRUPT ::= 9
RETRIES ::= 5

// ------------ epaper display ------------
// This is an ILO373 control chip. The display is a 2.9" grayscale EInk. (from board.c)
BUSY ::= 5
RESET ::= 6
DC ::= 7
CS ::= 8
CLOCK ::= 36
DIN ::= 35

// ------------ Assignable ----------------
WAKEUP_PIN ::= 32  // Use a pull-down resistor to pull pin 32 to ground.

class ESP32s2MagTag:

  rled := gpio.Pin RED_LED --output
  neopixel_light_sns := gpio.Pin NEOPOWER_PIN --output
  pixels := PixelStrip.uart NEOPIXELS --pin=(gpio.Pin NEOPIXEL_PIN) --bytes_per_pixel=3
  light_adc/Adc := Adc (gpio.Pin LIGHT)
  battery_adc/Adc := Adc (gpio.Pin BATTERY_VOLTAGE)

  button-a := gpio.Pin BUTTON_A --input
  button-b := gpio.Pin BUTTON_B --input
  button-c := gpio.Pin BUTTON_C --input
  
  bus/i2c.Bus? := null
  spi-bus/spi.Bus? := null

  display-device := null
  display-reset/gpio.Pin? := null
  display-busy/gpio.Pin? := null
  e-paper := null

  accelerometer/lis3dh.Lis3dh? := null
  lisirq := gpio.Pin ACCELEROMETER_INTERRUPT --input

  pigeonhole := storage.Bucket.open --ram "/sys/pigeonhole"

  network/net.Interface? := null

  on:
    bus = i2c.Bus
      --sda=gpio.Pin 33
      --scl=gpio.Pin 34
  
    spi-bus = spi.Bus
      --mosi=gpio.Pin DIN
      --clock=gpio.Pin CLOCK    

    display-device = spi-bus.device
      --cs=gpio.Pin CS
      --dc=gpio.Pin DC
      --frequency=10_000_000
    display-reset = gpio.Pin.out RESET
    display-busy = gpio.Pin.in BUSY --pull_down
    // e-paper = TwoColorPixelDisplay (Waveshare2Color29 display-device display-reset display-busy)

    accelerometer = lis3dh.Lis3dh (add_i2c_device lis3dh.I2C_ADDRESS_ALT)
    accelerometer.enable
    neopixel_light_sns_enable
    print ".... MagTag $short_id started"

  off:
    accelerometer.disable
    neopixel_light_sns_disable

  add_i2c_device address/int -> i2c.Device:
    return bus.device address

  network_on -> bool:
    retries := 0
    while ++retries < RETRIES and not network:
      exception := catch --trace:
        network = net.open
        return true
    return false

  network_sync -> bool:
/*    if network:
      result = ntp.synchronize
      if result:
        print "ntp: $result.adjustment ±$result.accuracy"
        esp32.adjust_real_time_clock result.adjustment
        return true
      else:
        print "ntp sychronize failed"
*/    return false

  network_off -> none:
    if network: network.close

  neopixel_light_sns_enable -> none:
    neopixel_light_sns.set 0

  // Do this to save power in sleep mode.
  neopixel_light_sns_disable -> none:
    neopixel_light_sns.set 1

  red_on -> none:
    rled.set 0
  red_off -> none:
    rled.set 1

  short_id -> string:
    return (hardware_id.stringify)[24..]

  battery_voltage -> float:
    return battery_adc.get * 2  // battery_voltage_pin.get

  light -> float:
    return light_adc.get  // light_pin.get

  blink --on=250 --off=1000 -> none:
    red_on
    sleep --ms=on
    red_off
    sleep --ms=off

  get string -> any:
    return pigeonhole.get string
  
  get string [--ifAbsent]  -> any:
    return pigeonhole.get string --if_absent=ifAbsent
  
  set string value/any -> none:
    pigeonhole[string] = value

init_wakeup_pin:
  pin := gpio.Pin WAKEUP_PIN
  mask := 0
  mask |= 1 << pin.num
  esp32.enable_external_wakeup mask true

