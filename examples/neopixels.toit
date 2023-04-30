// Copyright Ekorau LLC 2023
// Adapted from https://github.com/toitware/toit-pixel-strip/blob/main/examples/gpy.toit
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import magtag show *

/// 32 brightnesses that appear evenly spaced.
BRIGHTNESSES := get_brightnesses_

get_brightnesses_:
  result := []
  for power := 8; power > 0; power--:
    STEPS_.do:
      result.add (it * (1 << power)) >> 5
  return result

STEPS_ ::= [27, 23, 19, 16]  // Log distributed.


main:
  board := ESP32s2MagTag
  board.on
  print "Battery: $(%.3f board.battery_voltage)"

  r := ByteArray NEOPIXELS
  g := ByteArray NEOPIXELS
  b := ByteArray NEOPIXELS

  print BRIGHTNESSES.size

  // Paint all pixels with #4480ff.
  r.fill 0x44
  g.fill 0x80
  b.fill 0xff

  board.pixels.output r g b

  sleep --ms=2000


  2.repeat:
    // All pixels black.
    board.pixels.output r g b

    // Fade from white to black.
    BRIGHTNESSES.do:
      r[0] = it
      g[0] = it
      b[0] = it
      sleep --ms=100
      board.pixels.output r g b

    // Fade from red to black.
    BRIGHTNESSES.do:
      r[1] = it
      sleep --ms=100
      board.pixels.output r g b

    // Fade from green to black.
    BRIGHTNESSES.do:
      g[2] = it
      sleep --ms=100
      board.pixels.output r g b

    // Fade from blue to black.
    BRIGHTNESSES.do:
      b[3] = it
      sleep --ms=100
      board.pixels.output r g b

  board.off
  print "fin"
