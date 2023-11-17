// This code should go into the Arduino UNO !!!

// This Arduino should be connected to a 24 bits latched parallel out / serial in shift-register, comprised of 3 cascaded 5821 chips,
//  of which the lower 20 bits are used to steer 20 12V led lights which preferably are located in the buttonswitches, which are read
//  by the code in the Arduino Leonardo...

// Have fun!!

// William Senn.

#include "SimpleMessageSystem.h"

//Pin connected to ST_CP of 74HC595
int latchPin = 8;
//Pin connected to SH_CP of 74HC595
int clockPin = 12;
////Pin connected to DS of 74HC595
int dataPin = 11;

String buff = "";
int value[3];

void setup() {
  //set pins to output because they are addressed in the main loop
  pinMode(latchPin, OUTPUT);
  pinMode(clockPin, OUTPUT);
  pinMode(dataPin, OUTPUT);
  Serial.begin(115200); // Set baudrate to 115200 preferably.
}

void loop() {
  if (messageBuild() > 0) { // Checks to see if the message is complete and erases any previous messages
    switch (messageGetChar()) { // Gets the first word as a character
      case 'w': // Read pins (analog or digital)
        for (int n = 0; n < 3; n++) {
          value[n] = messageGetInt();
        }
    }
  }



  //ground latchPin and hold low for as long as you are transmitting
  digitalWrite(latchPin, LOW);
  for (int n = 0; n < 3; n++) {
    shiftOut(dataPin, clockPin, MSBFIRST, value[n]);
  }
  //return the latch pin high to signal chip that it
  //no longer needs to listen for information
  digitalWrite(latchPin, HIGH);
 // delay(10);
}
