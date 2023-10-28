// Copyright (C) 2018 Toitware ApS. All rights reserved.
// Use of this source code is governed by an MIT-style license that can be
// found in the LICENSE file.

// Driver for SPI-connected e-paper displays.  These are two- or three-color displays.

import binary
import bitmap
import spi
import pixel-display show AbstractDriver


import .waveshare-2-color-1-54
export *

PANEL-SETTING_                     ::= 0x00  // PSR
POWER-SETTING_                     ::= 0x01
POWER-OFF_                         ::= 0x02  // PWR
POWER-OFF-SEQUENCE_                ::= 0x03
POWER-ON_                          ::= 0x04
POWER-ON-MEASURE_                  ::= 0x05  // PMES
BOOSTER-SOFT-START_                ::= 0x06  // BTST
DEEP-SLEEP_                        ::= 0x07
DATA-START-TRANSMISSION-1_         ::= 0x10
DATA-STOP_                         ::= 0x11
DISPLAY-REFRESH_                   ::= 0x12
DATA-START-TRANSMISSION-2_         ::= 0x13
PARTIAL-DATA-START-TRANSMISSION-1_ ::= 0x14
PARTIAL-DATA-START-TRANSMISSION-2_ ::= 0x15
PARTIAL-DISPLAY-REFRESH_           ::= 0x16
VCOM-LUT_                          ::= 0x20  // LUTC
W2W-LUT_                           ::= 0x21  // LUTWW
B2W-LUT_                           ::= 0x22  // LUTBW/LUTR
W2B-LUT_                           ::= 0x23  // LUTWB/LUTW
B2B-LUT_                           ::= 0x24  // LUTBB/LUTB
VCOM-LUT-2_                        ::= 0x25  // For grayscale.
PLL-CONTROL_                       ::= 0x30
TEMPERATURE-SENSOR-CALIBRATION_    ::= 0x40
TEMPERATURE-SENSOR-SELECTION_      ::= 0x41
TEMPERATURE-SENSOR-WRITE_          ::= 0x42  // TSW
TEMPERATURE-SENSOR-READ_           ::= 0x43  // TSR
VCOM-AND-DATA-SETTING-INTERVAL_    ::= 0x50
LOW-POWER-DETECTION_               ::= 0x51
TCON-SETTING_                      ::= 0x60  // TCON
RESOLUTION-SETTING_                ::= 0x61
SOURCE-AND-GATE-START-SETTING_     ::= 0x62
FLASH-CONTROL_                     ::= 0x65  // 1 = enable, 0 = disable
GET-STATUS_                        ::= 0x71
AUTO-MEASURE-VCOM_                 ::= 0x80  // AMV
VCOM-VALUE_                        ::= 0x81  // VV
VCOM-DC_                           ::= 0x82
PARTIAL-WINDOW_                    ::= 0x90
PARTIAL-IN_                        ::= 0x91  // Enter partial update mode
PARTIAL-OUT_                       ::= 0x92  // Exit partial update mode
PROGRAM-MODE_                      ::= 0xa0  // PGM
ACTIVE-PROGRAM_                    ::= 0xa1  // APG
READ-OTP-DATA_                     ::= 0xa2  // ROTP
TURN-OFF-FLASH_                    ::= 0xb9

// Check code for deep sleep command.
DEEP-SLEEP-CHECK_                  ::= 0xa5

DRIVER-OUTPUT-154_                 ::= 0x01
BOOSTER-SOFT-START-154_            ::= 0x0c
GATE-SCAN-START-POSITION-154_      ::= 0x0f
DEEP-SLEEP-MODE-154_               ::= 0x10
DATA-ENTRY-MODE-154_               ::= 0x11
SOFTWARE-RESET-154_                ::= 0x12
TEMPERATURE-SENSOR-154_            ::= 0x1a
MASTER-ACTIVATION-154_             ::= 0x20
DISPLAY-UPDATE-1-154_              ::= 0x21
DISPLAY-UPDATE-2-154_              ::= 0x22
WRITE-RAM-154_                     ::= 0x24
WRITE-VCOM-154_                    ::= 0x2c
WRITE-LUT-154_                     ::= 0x32
WRITE-DUMMY-LINE-PERIOD-154_       ::= 0x3a
SET-GATE-TIME-154_                 ::= 0x3b
BORDER-WAVEFORM-154_               ::= 0x3c
SET-RAM-X-RANGE-154_               ::= 0x44
SET-RAM-Y-RANGE-154_               ::= 0x45
SET-RAM-X-ADDRESS-154_             ::= 0x4e
SET-RAM-Y-ADDRESS-154_             ::= 0x4f
NOP-154_                           ::= 0xff

// For panel setting on 3-color panels.
_2-COLOR                           ::= 0x10
_3-COLOR                           ::= 0x00

// For panel setting on 7.5 inch 2 color panel
RESOLUTION-640-480_                ::= 0x00
RESOLUTION-600-450_                ::= 0x40
RESOLUTION-640-448_                ::= 0x80
RESOLUTION-600-448_                ::= 0xc0

LUT-FROM-FLASH_                    ::= 0x00
LUT-FROM-REGISTER_                 ::= 0x20

FLIP-Y_                            ::= 0x08
FLIP-X_                            ::= 0x04

DC-DC-CONVERTER-OFF_               ::= 0x00
DC-DC-CONVERTER-ON_                ::= 0x02

SOFT-RESET_                        ::= 0x00
NO-SOFT-RESET_                     ::= 0x01

// For PLL control on 7.5 inch 2 color panel
FRAME-RATE-100-HZ_                 ::= 0x3a
FRAME-RATE-50-HZ_                  ::= 0x3c

abstract class EPaper extends AbstractDriver:
  // Pin numbers.
  reset_ := ?         // Active low reset line.
  busy_ := ?          // From screen to device, low = busy, high = not busy.

  cmd-buffer_/ByteArray ::= ByteArray 1
  buffer_/ByteArray

  device_ := ?

  constructor .device_ .reset_ .busy_:
    // Also used for sending large repeated arrays - speed vs mem tradeoff.
    buffer_ = ByteArray 128

    if reset_:
      reset_.config --output

    if busy_:
      busy_.config --input

  send command:
    send_ 0 command

  send command data:
    send_ 0 command
    send_ 1 data

  send command data data2:
    buffer_[0] = data
    buffer_[1] = data2
    send-array command buffer_ --to=2

  send command data data2 data3:
    buffer_[0] = data
    buffer_[1] = data2
    buffer_[2] = data3
    send-array command buffer_ --to=3

  send command data data2 data3 data4:
    buffer_[0] = data
    buffer_[1] = data2
    buffer_[2] = data3
    buffer_[3] = data4
    send-array command buffer_ --to=4

  /// Send a command byte, followed by an array of data bytes.
  // TODO(anders): array should be ByteArray (needs ByteArray literals).
  send-array command array --from=0 --to=array.size:
    send_ 0 command
    if array is not ByteArray:
      array = ByteArray array.size: array[it]
    device_.transfer array --from=from --to=to --dc=1

  /// Send an array of data bytes without any preceeding command bytes.
  send-continued-array array/ByteArray --from=0 --to=array.size:
    device_.transfer array --from=from --to=to --dc=1

  send-repeated-bytes repeats byte:
    bitmap.bytemap-zap buffer_ byte
    List.chunk-up 0 repeats buffer_.size: | _ _ size |
      device_.transfer buffer_ --to=size --dc=1

  send_ dc byte:
    cmd-buffer_[0] = byte
    device_.transfer cmd-buffer_ --dc=dc

  // Send a command with a 16 bit argument, little-endian order.
  send-le command x:
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 0 x
    send-array command buffer_ --to=2

  // Send a command with two 16 bit arguments, little-endian order.
  send-le command x y:
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 0 x
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 2 y
    send-array command buffer_ --to=4

  // Send a command with four 16 bit arguments, little-endian order.
  send-le command x y w h:
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 0 x
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 2 y
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 4 w
    binary.LITTLE-ENDIAN.put-uint16 buffer_ 6 h
    send-array command buffer_ --to=8

  // Send a command with a 16 bit argument, big endian order.
  send-be command x:
    binary.BIG-ENDIAN.put-uint16 buffer_ 0 x
    send-array command buffer_ --to=2

  // Send a command with two 16 bit arguments, big endian order.
  send-be command x y:
    binary.BIG-ENDIAN.put-uint16 buffer_ 0 x
    binary.BIG-ENDIAN.put-uint16 buffer_ 2 y
    send-array command buffer_ --to=4

  // Send a command with four 16 bit arguments, big endian order.
  send-be command x y w h:
    binary.BIG-ENDIAN.put-uint16 buffer_ 0 x
    binary.BIG-ENDIAN.put-uint16 buffer_ 2 y
    binary.BIG-ENDIAN.put-uint16 buffer_ 4 w
    binary.BIG-ENDIAN.put-uint16 buffer_ 6 h
    send-array command buffer_ --to=8

  wait-for-busy value:
    if busy_:
      e := catch:
        with-timeout --ms=5_000:
          busy_.wait-for value
      if e:
        print "E-paper display timed out waiting for busy pin, which is now $busy_.get"
        throw e  // Rethrow.
    else:
      sleep --ms=5_000

  // Writes part of the canvas to the device.  The canvas is arranged as
  // height/8 strips of width bytes, where each byte represents 8 vertically
  // stacked pixels.  The displays require these be transposed so that each
  // line is represented by width/8 consecutive bytes, from top to bottom.
  dump_ xor array width height:
    byte-width := width >> 3
    transposed := ByteArray byte-width
    row := 0
    for y := 0; y < height; y += 8:
      for in-bit := 0; in-bit < 8 and y + in-bit < height; in-bit++:
        for x := 0; x < byte-width; x++:
          out := 0
          byte-pos := row + (x << 3) + 7
          for out-bit := 7; out-bit >= 0; out-bit--:
            out |= ((array[byte-pos - out-bit] >> in-bit) & 1) << out-bit
          transposed[x] = out ^ xor
        send-continued-array transposed
      row += width
