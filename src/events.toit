// Copyright 2021 Ekorau LLC

BUTTON_A_PRESS ::= KeyEvent.key 0x00 0x01   // Call
BUTTON_B_PRESS ::= KeyEvent.key 0x01 0x01   // Menu
BUTTON_C_PRESS ::= KeyEvent.key 0x02 0x01   // Back
BUTTON_D_PRESS ::= KeyEvent.key 0x03 0x01   // End

abstract class Event:


class KeyEvent extends Event:
  id/int
  state/int

  constructor.key .id/int .state/int: 

  operator == other:
    if other is not KeyEvent: return false
    print "$this $other"
    return (id == other.id) and (state == other.state)

  hash_code:
    /// Refer BBQ10Keyboard.read_fifo: KeyEvent.key (val & 0xFF) (val >> 8) // keycode, state
    return (state << 8) | id

  stringify -> string:
    return "key $id:$state"

class NonEvent extends Event:

