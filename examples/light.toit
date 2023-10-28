// Copyright Ekorau LLC 2023
// Use of this source code is governed by a Zero-Clause BSD license that can
// be found in the EXAMPLES_LICENSE file.

import magtag show ESP32s2MagTag

main:
  board := ESP32s2MagTag
  board.on
  print "Light: $(%.3f board.light)"
  board.off
  print "end"