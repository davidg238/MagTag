// Copyright Ekorau LLC 2023
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import gpio
import esp32
import system.storage as storage


import magtag show *

main:
  board := ESP32s2MagTag
  board.on

  print "Start button test"

  400.repeat:
  // b-a.wait-for 1
    print "Button A / B / C $(board.button-a.get) $(board.button-b.get) $(board.button-c.get)"
    sleep --ms=100
  
  print "Done"
  