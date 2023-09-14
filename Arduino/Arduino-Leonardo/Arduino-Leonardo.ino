/* Arduino-Leonardo code */
/* voor het uitlezen van */
/* de toetsen van de kast */
/* Door William Senn */

// Needs ArduinoJoystickLibrary by Heironimus (Arduino Leonardo Joystick Library), try searching for it on github.com
// If your compile was unsuccessfull, please consider moving or copying your Arduino map to your MyDocuments map BEFORE installing the Arduino IDE (!!) and recompile.

#include <Joystick.h>

Joystick_ Joystick;

int NumKeys = 20;
uint32_t Waarde = 0L;
uint32_t Value2 = 0L, OldValue = 0L;

uint32_t AlleToetsen[] = { 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0 };
char HexAscii[] = { '0','0','0','0','0','0','0','0','\n' };
char FastHex[] = { '0','1','2','3','4','5','6','7','8','9','a','b','c','d','e','f' };
char *Ptr;
// Serial *serial; // = null;


char *toHexAscii(uint32_t Value)
{
  uint32_t   ValX;

  ValX = Value;
  for (int j=0;j<8;j++)
  {
    HexAscii[7-j] = FastHex[(((ValX)>>(j<<2))&(0x0f))];
  }
  return((char *)(&HexAscii[0]));
}

void setup()
{
//  Serial.begin(9600); // 9600 is default for serial debugging, which is only taking up time and space.
//  while (!Serial) {

//  } 
//  Serial.print("begin setup\n");
//  Set Groep Code op de digitale poort
  pinMode(2,OUTPUT);
  pinMode(3,OUTPUT);
  pinMode(4,OUTPUT);
  pinMode(5,OUTPUT);

// Initialise Analoge Poorten

  pinMode(A0,INPUT);
  pinMode(A1,INPUT);
  pinMode(A2,INPUT);
  pinMode(A3,INPUT);
  pinMode(A4,INPUT);
  
  Joystick.begin();

//  delay(1000);
//  serial = new Serial();
//  if (serial != null)
//  {
//  }
//  else
//  {
//    pinMode(LED_BUILTIN,OUTPUT);
//    for(;;)
//    {
//      digitalWrite(LED_BUILTIN,HIGH);
//      delay(1000);
//      digitalWrite(LED_BUILTIN,LOW);
//      delay(1000);
//    }
//  }
}

void loop()
{
  digitalWrite(2,1);
  digitalWrite(3,0);
  digitalWrite(4,0);
  digitalWrite(5,0);

  if ((Waarde = digitalRead(A0)) != 0)
    AlleToetsen[0] = 1L;
  if ((Waarde = digitalRead(A1)) != 0)
    AlleToetsen[1] = 1L;
  if ((Waarde = digitalRead(A2)) != 0)
    AlleToetsen[2] = 1L;
  if ((Waarde = digitalRead(A3)) != 0)
    AlleToetsen[3] = 1L;
  if ((Waarde = digitalRead(A4)) != 0)
    AlleToetsen[4] = 1L;

  digitalWrite(2,0);
  digitalWrite(3,1);
  digitalWrite(4,0);
  digitalWrite(5,0);

  if ((Waarde = digitalRead(A0)) != 0)
    AlleToetsen[5] = 1L;
  if ((Waarde = digitalRead(A1)) != 0)
    AlleToetsen[6] = 1L;
  if ((Waarde = digitalRead(A2)) != 0)
    AlleToetsen[7] = 1L;
  if ((Waarde = digitalRead(A3)) != 0)
    AlleToetsen[8] = 1L;
  if ((Waarde = digitalRead(A4)) != 0)
    AlleToetsen[9] = 1L;
  
  digitalWrite(2,0);
  digitalWrite(3,0);
  digitalWrite(4,1);
  digitalWrite(5,0);

  if ((Waarde = digitalRead(A0)) != 0)
    AlleToetsen[10] = 1L;
  if ((Waarde = digitalRead(A1)) != 0)
    AlleToetsen[11] = 1L;
  if ((Waarde = digitalRead(A2)) != 0)
    AlleToetsen[12] = 1L;
  if ((Waarde = digitalRead(A3)) != 0)
    AlleToetsen[13] = 1L;
  if ((Waarde = digitalRead(A4)) != 0)
    AlleToetsen[14] = 1L;

  digitalWrite(2,0);
  digitalWrite(3,0);
  digitalWrite(4,0);
  digitalWrite(5,1);

  if ((Waarde = digitalRead(A0)) != 0)
    AlleToetsen[15] = 1L;
  if ((Waarde = digitalRead(A1)) != 0)
    AlleToetsen[16] = 1L;
  if ((Waarde = digitalRead(A2)) != 0)
    AlleToetsen[17] = 1L;
  if ((Waarde = digitalRead(A3)) != 0)
    AlleToetsen[18] = 1L;
  if ((Waarde = digitalRead(A4)) != 0)
    AlleToetsen[19] = 1L;

//  delay(10);
 
  Value2 = 0;
  
  for (int i = 0; i < NumKeys; i++)
  { 
    Value2 |= (((AlleToetsen[i]) & 1L) << i);
    AlleToetsen[i] = 0L;
  }
  
  if (Value2 != OldValue)
  {
   uint32_t Value3 = Value2;
   
   for (int i=0;i<NumKeys;i++)
   {
    Joystick.setButton(i,((Value3)>>i)&(1L));
   }
   
//   Ptr = toHexAscii(Value2);
//   for (int k=0;k<9;k++)
//    {
//      if (serial != null)
//        Serial.write((byte)Ptr[k]);
//    }
//      pinMode(LED_BUILTIN,OUTPUT);
//      digitalWrite(LED_BUILTIN,HIGH);
//      delay(1);
//      digitalWrite(LED_BUILTIN,LOW);
//      delay(1);
//    }
  }
 OldValue = Value2;
}
