// Copyright 2023 Ekorau LLC
import device show hardware_id
import gpio
import i2c
import net

import gpio.adc show Adc
import esp32
import math show pow
import bitmap show bytemap_zap
import pixel_strip show PixelStrip


// Specific for the Adafruit MagTag.  https://www.adafruit.com/product/4800
BUTTON_A ::= 15
BUTTON_B ::= 14
BUTTON_C ::= 12
BUTTON_D ::= 11

RED_LED ::= 13

NEOPOWER_PIN ::= 21
NEOPIXEL_PIN ::= 1
NEOPIXELS ::= 4

LIGHT ::= 3
BATTERY_VOLTAGE ::= 4

RETRIES ::= 5

// Assignable.
WAKEUP_PIN ::= 32  // Use a pull-down resistor to pull pin 32 to ground.

class ESP32s2MagTag:

  rled := gpio.Pin RED_LED --output
  pixel_pwr := gpio.Pin NEOPOWER_PIN --output
  pixels := PixelStrip.uart NEOPIXELS --pin=(gpio.Pin NEOPIXEL_PIN) --bytes_per_pixel=3

  light_adc/Adc := Adc (gpio.Pin LIGHT)
  battery_adc/Adc := Adc (gpio.Pin BATTERY_VOLTAGE)
  bus/i2c.Bus? := null

  network/net.Interface? := null

  on:
  /*
    bus = i2c.Bus
      --sda=gpio.Pin 21
      --scl=gpio.Pin 22
    
    // init_wakeup_pin
    battery_sense_off
  */
    pixel_pwr.set 0
    print ".... MagTag $short_id started"

  off:
    pixel_pwr.set 1

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

  red_on -> none:
    rled.set 0
  red_off -> none:
    rled.set 1

  short_id -> string:
    return (hardware_id.stringify)[24..]

  battery_voltage -> float:
    return battery_adc.get * 2  // battery_voltage_pin.get

  light -> float:
    return light_adc.get  // battery_voltage_pin.get

  blink --on=250 --off=1000 -> none:
    red_on
    sleep --ms=on
    red_off
    sleep --ms=off

init_wakeup_pin:
  pin := gpio.Pin WAKEUP_PIN
  mask := 0
  mask |= 1 << pin.num
  esp32.enable_external_wakeup mask true

//  https://github.com/EzSBC/ESP32_Feather/blob/main/ESP32_Feather_Vbat_Test.ino

/*
  raw_voltage -> float:
    battery_sense_pin.set 1
    sleep --ms=100
    voltage := voltage battery_adc  // battery_voltage_pin.get
    battery_sense_pin.set 0
    return voltage

  battery_voltage -> float:
    battery_sense_pin.set 1
    sleep --ms=10
    x := 7600.0
    10.repeat:
      x = x + 200* (voltage battery_adc)// (voltage battery_voltage_pin)
    x = 0.9*x + 200* (voltage battery_adc)// (voltage battery_voltage_pin)
    battery_sense_pin.set 0
    return x/2.0

    voltage adc/Adc -> float:
    reading := adc.get // Reference voltage is 3v3 so maximum reading is 3v3 = 4095 in range 0 to 4095
    if reading < 1 or reading > 4095:
      return 0.0
  // Return the voltage after fixin the ADC non-linearity
    return linearize reading

  linearize reading/float -> float:
    return -0.000000000000016*(pow reading 4) + 0.000000000118171*(pow reading 3 ) - 0.000000301211691*(pow reading 2) + 0.001109019271794*reading + 0.034143524634089

  */  



