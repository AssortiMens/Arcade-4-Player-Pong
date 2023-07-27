/*********************************/
/*      Pong voor 4 spelers      */
/*                               */
/*      Geprogrammeerd door      */
/*                               */
/*                               */
/*         William  Senn         */
/*                               */
/*                               */
/*   (C) 2018-2023 AssortiMens   */
/*********************************/
/*          Kast-Versie          */
/*********************************/

import org.gamecontrolplus.*;
import ddf.minim.*;
import processing.serial.*;

Serial serial;
Minim minim;

int Lampjes = 0;

AudioPlayer titlesong;
AudioSample ping;
AudioSample pong;
// AudioSample uit;

ControlIO control;
ControlDevice stick;

int TextOrientation = 0;

int TextSize = 1;

Joystick joy1 = null;
Joystick joy2 = null;
Joystick joy3 = null;
Joystick joy4 = null;

int joySpeed = 10;

int NumBalls = 50;
Ball ball[] = {null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null};

int ballSpeed = 10;

int NumKeys = 20; /* 20 voor de kast / Arduino */
int TotalNumKeys = 120; // Normal keyboard, use 20 out of 120
int TranslationConstance = 0; // 0 for no translation and kast / Arduino. 1 for PC. 11 for macosx.
int NumKeysPerPlayer = 5;

int LinksToetsen[] =  {TranslationConstance+0,TranslationConstance+5,TranslationConstance+10,TranslationConstance+15};
int VuurKnoppen[] =   {TranslationConstance+1,TranslationConstance+6,TranslationConstance+11,TranslationConstance+16};
int RechtsToetsen[] = {TranslationConstance+2,TranslationConstance+7,TranslationConstance+12,TranslationConstance+17};
int PlusToetsen[] =   {TranslationConstance+3,TranslationConstance+(int)8,TranslationConstance+13,TranslationConstance+18};
int MinToetsen[] =    {TranslationConstance+4,TranslationConstance+9,TranslationConstance+14,TranslationConstance+19};

int Player;
int Key;
int keysPressed[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
                     0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};

boolean buttonPressed = false;

boolean XRepKeys[] = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
                      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
                      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
                      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
                      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,
                      false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false};

boolean HumanPlayer[] = {false,false,false,false};
int NumHumanPlayers = 0;

int Dirs[] = {-1,1};

int frameCounter = 0;
int Kleur = -1;
boolean Opkomst = true;

Table table = null;
int NumRows = 8;

//AudioOutput out;
//AudioInput in;

void setup() {
//  size(500,500);
  fullScreen();
  noCursor();
  frameRate(100);

  control = ControlIO.getInstance(this);
  try {
    println(control.deviceListToText(""));
    stick = control.getDevice("Arduino Leonardo"); // devicename (inside double-quotes!) or device number (without the double-quotes!) here.
  }
  catch (Exception e) {
    println("No Arduino found or no Toetsenbord/Keyboard configured!");
    System.exit(0);
  }
  try {
    minim = new Minim(this);
    ping = minim.loadSample("data/ping.mp3");
    pong = minim.loadSample("data/pong.mp3");
//    uit = minim.loadSample("data/uit.mp3");
    titlesong = minim.loadFile("data/12-dreams.mp3");
  }
  catch (Exception e) {
    println("No sounds found!");
    System.exit(0);
  }

// /*

  try {
    printArray(Serial.list());
    serial = new Serial(this, Serial.list()[2], 115200); // This should connect to the Arduino UNO for the lights!!
    serial.bufferUntil('\0');
  }
  catch (Exception e) {
    println("Could not open serial device!");
    System.exit(0);
  }

// */

  Lampjes = 0;
  ser_Build_Msg_String_And_Send(Lampjes);
 
  loadHighscores();
  saveHighscores();

  TextOrientation=0;
  
  titlesong.loop();
  
  demoMode();
  initGame();
}


String TestBuffer = "w 255 255 255\n\r";
String TestBuffer2 = "w 255 255 255\n\r";
int OldCode = 0;

void ser_Build_Msg_String_And_Send(int tCode)
{
  char msgchars[] = {'w',' ','2','5','5',' ','2','5','5',' ','2','5','5','\n','\r','\0'};
  char FastHex[] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
  char header = 'w';
  char delimiter = ' ';
  int  msb = 0;
  int  hsb = 0;
  int  lsb = 0;
  char eos1 = '\n';
  char eos2 = '\r';
  char eos3 = (char)'\0';
  int numKars = 0;
  boolean msbwasgroter = false;
  boolean hsbwasgroter = false;
  boolean lsbwasgroter = false;
  int len = 0;

  if (tCode != OldCode) {
    msgchars = TestBuffer.toCharArray();
    msb = ((((tCode)&0xff0000)>>16));
    hsb = ((((tCode)&0x00ff00)>>8));
    lsb = ((((tCode)&0x0000ff)>>0));
    numKars = 0;
    msgchars[numKars++] = header;
    msgchars[numKars++] = delimiter;
    if ((msb) >= 0x64) {
      msgchars[numKars++] = FastHex[msb / 0x64];
      msbwasgroter = true;
    }
    else {
      msbwasgroter = false;
    }
    msb %= 0x64;
    if (((msb) >= 0x0a) || (msbwasgroter)) {
      msgchars[numKars++] = FastHex[msb / 0x0a];
    }
    msb %= 0x0a;
    msgchars[numKars++] = FastHex[msb];
    msgchars[numKars++] = delimiter;
    if ((hsb) >= 0x64) {
      msgchars[numKars++] = FastHex[hsb / 0x64];
      hsbwasgroter = true;
    }
    else {
      hsbwasgroter = false;
    }
    hsb %= 0x64;
    if (((hsb) >= 0x0a) || (hsbwasgroter)) {
      msgchars[numKars++] = FastHex[hsb / 0x0a];
    }
    hsb %= 0x0a;
    msgchars[numKars++] = FastHex[hsb];
    msgchars[numKars++] = delimiter;
    if ((lsb) >= 0x64) {
      msgchars[numKars++] = FastHex[lsb / 0x64];
      lsbwasgroter = true;
    }
    else {
      lsbwasgroter = false;
    }
    lsb %= 0x64;
    if (((lsb) >= 0x0a) || (lsbwasgroter)) {
      msgchars[numKars++] = FastHex[lsb / 0x0a];
    }
    lsb %= 0x0a;
    msgchars[numKars++] = (char)FastHex[lsb];
    msgchars[numKars++] = (char)eos1;
    msgchars[numKars++] = (char)eos2;
    msgchars[numKars] = (char)eos3;

    len = numKars;

    TestBuffer = (String.valueOf(msgchars));
    TestBuffer2 = TestBuffer.substring(0,len);
//    print(TestBuffer2); //.substring(0,len));
    for (int i = 0; i < len; i++) {
//      print(msgchars[i]);

// /*

      serial.write((byte)(msgchars[i]));

// */

    }
    OldCode = tCode;
  }
}

void loadHighscores() {
  try {
    table = loadTable("data/highscores.csv","header");
    if (table != null) {
      NumRows = table.getRowCount();
      for (int i=0;i<NumRows;i++) {
        TableRow row = table.getRow(i);
        NaamLijst[i] = row.getString("name");
        ScoreLijst[i] = row.getInt("score");
        CrownLijst[i] = row.getString("crown");
      }
    }
    else {
      println("table was null!");
    }
  }
  catch (Exception e) {
    println("Loading data/highscores.csv failed!");
    System.exit(0);
  }
}

void saveHighscores() {
  try {
    if (table != null) {
      NumRows = 8;
      table.setRowCount(NumRows);
      for (int i=0;i<NumRows;i++) {
        TableRow row = table.getRow(i);
        row.setString("name", NaamLijst[i]);
        row.setInt("score", ScoreLijst[i]);
        row.setString("crown",CrownLijst[i]);
      }
      saveTable(table, "data/highscores.csv");
    }
    else {
      println("table == null! Try loading first!");
    }
  }
  catch (Exception e) {
    println("Error trying to save data/highscores.csv !");
    System.exit(0);
  }
}

void demoMode() {
  Kleur = -1;
  Opkomst = true;

  frameCounter=0;
}

void initGame() {
  NumBalls = 50; // Force to 50 balls max
  
  TextSize = 1;

  NumCollectedFireButtons = 0;
  NumHumanPlayers = 0;

  for (int k=0;k<4;k++) {
    HumanPlayer[k] = false;
    CollectedFireButtons[k] = false;
   }

  buttonPressed = false;
  for (int j=(0+TranslationConstance);j<(NumKeys+TranslationConstance);j++)
   {
    keysPressed[j] = 0;
    XRepKeys[j] = false;
   }

  if (joy1 != null) {
    if (joy1.Highscore != null) {
      joy1.Highscore.Score = 0;
      joy1.Highscore = null;
    }
    joy1.Score = 0;
    joy1 = null;
  }
  if (joy2 != null) {
    if (joy2.Highscore != null) {
      joy2.Highscore.Score = 0;
      joy2.Highscore = null;
    }
    joy2.Score = 0;
    joy2 = null;
  }
  if (joy3 != null) {
    if (joy3.Highscore != null) {
      joy3.Highscore.Score = 0;
      joy3.Highscore = null;
    }
    joy3.Score = 0;
    joy3 = null;
  }
  if (joy4 != null) {
    if (joy4.Highscore != null) {
      joy4.Highscore.Score = 0;
      joy4.Highscore = null;
    }
    joy4.Score = 0;
    joy4 = null;
  }

  for (int i=0;i<NumBalls;i++) {
     if (ball[i] != null) {
       ball[i] = null;
     }
  }

  joy1 = new Joystick(width/2,30,1,0,color(255,0,255));
  joy2 = new Joystick(30,height/2,0,1,color(255,0,0));
  joy4 = new Joystick(width-30,height/2,0,-1,color(0,255,0));
  joy3 = new Joystick(width/2,height-30,-1,0,color(0,0,255));
  
  for (int i=0;i<NumBalls;i++)
  {
    ball[i] = new Ball(width/2,height/2,int(random(ballSpeed))+1,int(random(ballSpeed))+1,Dirs[int(random(2))],Dirs[int(random(2))],color(255,255,255));
  }
}

int CalcLicht() {
  int LichtCode;

  LichtCode = CyclicBuffer[(frameCounter / 4) % 80];
//  LichtCode = int(random(1048576));
  LichtCode &= 1048575;
  return LichtCode;
}

int CyclicBuffer[] = {1,2,4,8,16,32,64,128,256,512,1024,2048,4096,8192,16384,
                      32768,65536,131072,262144,524288,
                      524288,262144,131072,65536,32768,16384,8192,4096,2048,1024,
                      512,256,128,64,32,16,8,4,2,1,
                      1,3,7,15,31,63,127,255,511,1023,2047,4095,8191,16383,
                      32767,65535,131071,262143,524287,1048575,
                      -1,-2,-4,-8,-16,-32,-64,-128,-256,-512,-1024,-2048,-4096,-8192,
                      -16384,-32768,-65536,-131072,-262144,-524288,-1048576};

int millis1 = 0;
int millis2 = 0;
int verschil = 0;

void draw() {
/* frame tijd achterhalen */
  millis1 = millis2;
  millis2 = millis();
  verschil = millis2 - millis1;
//  println(verschil);

  if (frameCounter < 10000)
    Lampjes = CalcLicht(); //int(random(1048576));
  else
    Lampjes = 0;
 
  if (frameCounter<1000) {
    perFrameDemo1();
  }
  else
  if (frameCounter<2000) {
    perFrameDemo2();
  }
  else
  if (frameCounter<3000) {
    perFrameDemo3();
  }
  else
  if (frameCounter<4000) {
    perFrameDemo4();
  }
  
  if (frameCounter<10000) {
    ButtonPressed();
  }
  
  if ((buttonPressed)&&(frameCounter<10000)) {
    initGame();
    frameCounter=10000;
    buttonPressed=false;
    for (int i=0;i<4;i++) {
      HumanPlayer[i]=false;
    }
  }

  if (frameCounter>=10000) {
    if (frameCounter<11000) {
      ButtonPressed();

      background(0);
      Joystick Joys[] = {joy3,joy4,joy1,joy2};

      Joys[0] = joy3;
      Joys[1] = joy4;
      Joys[2] = joy1;
      Joys[3] = joy2;
      pushMatrix();
      translate(width/2,height/2);
      rotate(radians(TextOrientation++));
      TextOrientation %= 360;
      textSize(20);
      fill(255);
      textAlign(CENTER,CENTER);
      text("Players Logged in", 0, -50);
      for (int k=0;k<4;k++) {
        if (HumanPlayer[k]) {
          fill(Joys[k].Color);
          text(Naam[k], 0, (k*25)-25);
        }
        else {
          fill(Joys[k].Color);
          text("Hit a key to log in!", 0, (k*25)-25);
        }
      }
      popMatrix();

      for (int i = TranslationConstance; i < (NumKeys + TranslationConstance); i++) {
        Key = keysPressed[((i) % TotalNumKeys)];
        keysPressed[((i) % TotalNumKeys)] = 0;
        if (Key > 0) {
          Player = ((((Key - 1) - TranslationConstance) % TotalNumKeys) / NumKeysPerPlayer);
          Key = ((((Key - 1) - TranslationConstance) % TotalNumKeys) % NumKeysPerPlayer);

          Lampjes |= (1L << (((Player & 3) * NumKeysPerPlayer) + Key));

          HumanPlayer[(Player & 3)] = true;
          NumHumanPlayers = 0;

          for(int j=0;j<4;j++) {
            NumHumanPlayers = ((HumanPlayer[j])?(NumHumanPlayers+1):(NumHumanPlayers));
          }
        }
      }
    }

    if (((frameCounter>=11000)&&(frameCounter<=21000))&&(!(GameOver))) {
      background(0);
      
      NumBalls = int(((frameCounter-11000)/200)%50)+1; // Building up a level once per 200 frames => 50 balls max.
      
      perFrameGame();
      DisplayCountdown(21000 - frameCounter);
      GameOver = TestGameOver();
      if (GameOver) {
        frameCounter=21000;
        if ((joy1.Opacity)==255) { // Opacity==255)
          println("joy1/HumanPlayer 3 is the winner! Earlier GameOver");
          string = Naam[2];
          joy1.Crown = true;
        }
        if ((joy2.Opacity)==255) { // Opacity==255)
          println("joy2/HumanPlayer 4 is the winner! Earlier GameOver!");
          string = Naam[3];
          joy2.Crown = true;
        }
        if ((joy3.Opacity)==255) { // Opacity==255)
          println("joy3/HumanPlayer 1 is the winner! Earlier GameOver!");
          string = Naam[0];
          joy3.Crown = true;
        }
        if ((joy4.Opacity)==255) { // Opacity==255)
          println("joy4/HumanPlayer 2 is the winner! Earlier GameOver!");
          string = Naam[1];
          joy4.Crown = true;
        }
      }
      else {
        if (frameCounter == 21000) {
          println("Time's up! We have no winner, yet!");
          string = "Time's up! Nobody";
          joy1.Crown = false;
          joy2.Crown = false;
          joy3.Crown = false;
          joy4.Crown = false;
        }
      }
    }
    
    if (frameCounter>=21000) {
      background(0);
      if (frameCounter==21000) {
        joy3.Highscore = new Highscore(joy3.Score,0,joy3.Crown);
        joy4.Highscore = new Highscore(joy4.Score,1,joy4.Crown);
        joy1.Highscore = new Highscore(joy1.Score,2,joy1.Crown);
        joy2.Highscore = new Highscore(joy2.Score,3,joy2.Crown);
       }
      if (frameCounter>=22000) {

        joy1.Highscore.Display(); //joy3.Highscore.Display();    // Magenta
        joy2.Highscore.Display(); //joy4.Highscore.Display();    // Red
        joy4.Highscore.Display(); //joy2.Highscore.Display();    // Green
        joy3.Highscore.Display(); //joy1.Highscore.Display();    // Blue

        DisplayCountdown(32000 - frameCounter);

        joy3.Highscore.Update();
        joy4.Highscore.Update();
        joy1.Highscore.Update();
        joy2.Highscore.Update();

        TestToResetGame();

        if (frameCounter>=32000) {
          frameCounter=0;
          resetGame = true;
          
          TestToResetGame();
         }
       }
     else
       {
         pushMatrix();
         translate(width/2,height/2);
         textAlign(CENTER,CENTER);
         rotate(radians(TextOrientation++));
         TextOrientation %= 360;
         fill(255);
         textSize(TextSize++);
         if (TextSize > 64) {
           TextSize = 64;
         }
         text("Game Over!",0,-75);
         text(string,0,0);
         text("wins!",0,75);
         popMatrix();

       }
    }
  }

  ser_Build_Msg_String_And_Send(Lampjes);

  frameCounter++;
  
  if (frameCounter>=4000) {
    if (frameCounter>=10000) {
    }
    else
      frameCounter=0;
  }
} // End of draw()

void DisplayCountdown(int CountDown)
{
  pushMatrix();
  translate(width/2,height/2);
  rotate(radians(TextOrientation));
  TextOrientation++;
  TextOrientation %= 360;
  textAlign(CENTER,CENTER);
  textSize(20);
  fill(255);
  text(CountDown,0,0);
  popMatrix();
}

String string = ""; // Game Over, naam van de winnaar als die er is

boolean resetGame = false;

void TestToResetGame() {
  if (resetGame == true)
   {
    do {
      ButtonPressed();
    }
    while(buttonPressed == true);

    saveHighscores();

    initGame();
    demoMode();
    resetGame = false;
   }
}

void ButtonPressed() {
  buttonPressed = false;
  for (int z=TranslationConstance;z<(NumKeys+TranslationConstance);z++) {
    if (stick.getButton(z % TotalNumKeys).pressed()) {
      buttonPressed = true;
      keysPressed[z] = (int)(z + 1);
    }
    else
    {
      keysPressed[z] = 0;
    }
  }
}

void perFrameDemo1() {
  background(0);
  if (Opkomst) {
    Kleur++;
    if (Kleur>255)
      Kleur=255;
    if ((frameCounter % 1000) == 1000-255) {
      Opkomst=false;
    }
  }
  else {
    Kleur--;
    if (Kleur<0) {
      Kleur=0;
      Opkomst=true;
    }
  }
  int Afmeting = Kleur/2;
  if (Afmeting > 19)
    Afmeting = 19;
  if (Afmeting < 0)
    Afmeting = 0;
  pushMatrix();
  fill(Kleur);
  textSize(Afmeting+1);
  translate(width/2,height/2);
  textAlign(CENTER,CENTER);
  rotate(radians(TextOrientation++));
  TextOrientation %= 360;
  text("AssortiMens presents",0,-50);
  text("Four Player Pong",0,0);
  text("© 2018-2023",0,50);

  fill(255);
  text("Press a button to start",0,150);
  popMatrix();
}

void perFrameDemo2() {
  background(0);
  if (Opkomst) {
    Kleur++;
    if (Kleur>255)
      Kleur=255;
    if ((frameCounter % 1000) == 1000-255) {
      Opkomst=false;
    }
  }
  else {
    Kleur--;
    if (Kleur<0) {
      Kleur=0;
      Opkomst=true;
    }
  }
  int Afmeting = Kleur/2;
  if (Afmeting > 19)
    Afmeting = 19;
  if (Afmeting < 0)
    Afmeting = 0;
  pushMatrix();
  fill(Kleur);
  textSize(Afmeting+1);
  translate(width/2,height/2);
  textAlign(CENTER,CENTER);
  rotate(radians(TextOrientation++));
  TextOrientation %= 360;
  text("Programming",0,-50);
  text("William Senn",0,-25);
  text("Titlemusic",0,50);
  text("Longzijun",0,75);

  fill(255);
  text("Press a button to start",0,150);
  popMatrix();
}

void perFrameDemo3() {
  background(0);
  if (Opkomst) {
    Kleur++;
    if (Kleur>255)
      Kleur=255;
    if ((frameCounter % 1000) == 1000-255) {
      Opkomst=false;
    }
  }
  else {
    Kleur--;
    if (Kleur<0) {
      Kleur=0;
      Opkomst=true;
    }
  }
  int Afmeting = Kleur/2;
  if (Afmeting > 19)
    Afmeting = 19;
  if (Afmeting < 0)
    Afmeting = 0;
  pushMatrix();
  fill(Kleur);
  textSize(Afmeting+1);
  translate(width/2,height/2);
  textAlign(CENTER,CENTER);
  rotate(radians(TextOrientation++));
  TextOrientation %= 360;
  text("Hall of Fame",0,-160);

  for (int i=0;i<8;i++) {
    textAlign(LEFT,CENTER);
    text(Order[i],-120,(30*i)-130);
    textAlign(LEFT,CENTER);
    text(NaamLijst[i],-90,(30*i)-130);
    textAlign(RIGHT,CENTER);
    text(ScoreLijst[i],120,(30*i)-130);
    textAlign(CENTER,CENTER);
    text(CrownLijst[i],140,(30*i)-130);
  }
  fill(255);
  textAlign(CENTER,CENTER);
  text("Press a button to start",0,150);
  popMatrix();
}

void perFrameDemo4() {
  background(0);

//  NumBalls = 50; // Force to 50!
//  NumBalls = int(((frameCounter-3000)/200)%50)+1; // Building up a level every 200 frames => 50 balls max.

  perFrameGame();
  if (Opkomst) {
    Kleur++;
    if (Kleur>255)
      Kleur=255;
    if ((frameCounter % 1000) == 1000-255) {
      Opkomst=false;
    }
  }
  else {
    Kleur--;
    if (Kleur<0) {
      Kleur=0;
      Opkomst=true;
    }
  }
  int Afmeting = Kleur/2;
  if (Afmeting > 19)
    Afmeting = 19;
  if (Afmeting < 0)
    Afmeting = 0;
  pushMatrix();
  fill(Kleur);
  textSize(Afmeting+1);
  translate(width/2,height/2);
  textAlign(CENTER,CENTER);
  rotate(radians(TextOrientation++));
  TextOrientation %= 360;
  text("DEMO",0,0);
  fill(255);
  text("Press a button to start",0,150);
  popMatrix();
}

void perFrameGame() {
  joy1.Display();
  joy2.Display();
  joy3.Display();
  joy4.Display();
  
  for (int i=0;i<NumBalls;i++)
  {
    ball[i].Display();
  }

  if (joy1.Opacity==255)
    joy1.Update();
  if (joy2.Opacity==255)
    joy2.Update();
  if (joy3.Opacity==255)
    joy3.Update();
  if (joy4.Opacity==255)
    joy4.Update();
  
  for (int j=0;j<NumBalls;j++)
  {
    ball[j].Update();
  }
}

int NumOpacity = 0; // There can only be 1, it's global and static.
boolean GameOver = false; // There can only be 1, it's global and static.

boolean TestGameOver() {
  Joystick Joys[] = {joy3,joy4,joy1,joy2};
  boolean GameOver2;

  Joys[0] = joy3;
  Joys[1] = joy4;
  Joys[2] = joy1;
  Joys[3] = joy2;
  GameOver2 = false;
  NumOpacity = 0;
  for (int i=0;i<4;i++) {
    if ((Joys[i].Opacity)==0) {
            NumOpacity++;
            if (NumOpacity == 3) { // we have a winner!
              GameOver2 = true;
            }
    }
  }
 return GameOver2;
}

class Joystick {
  int x,y;
  int xDir,yDir,xOrient,yOrient;
  int w,h;
  int Score;
  int dtime = 500;  // 500 frames = delta time
  int ffc_time = 0; // future frameCounter time
  int Opacity = 255;
  boolean collided[]={false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false};
  boolean HalfSize=false;
  boolean DoubleSize=false;
  boolean Charged = false;
  boolean Crown = false;
  color Color = color(255,255,255);
  boolean FirstTime = true;
  Highscore Highscore = null;
  
  Joystick(int tx, int ty, int txDir, int tyDir, color tColor) {
    x = tx;
    y = ty;
    xDir = txDir;
    yDir = tyDir;
    xOrient = xDir;
    yOrient = yDir;
    w = (50*abs(xOrient))+10;
    h = (50*abs(yOrient))+10;
    Score = 0;
    Opacity = 255;
    NumOpacity = 0; // warning, this one is global and static and there's only 1
    GameOver = false; // warning, this one is global and static and there's only 1
    for (int i=0;i<NumBalls;i++)
      {
        collided[i] = false;
      }
    Color = tColor;
    Highscore = null;
    PNaampje = 2; // warning, this one is global and static and there's only 1
    HalfSize = false;
    DoubleSize = false;
    Charged = false;
    dtime = 500;
    ffc_time = 0;
    Crown = false;
    FirstTime = true; // Explosion animation start...
  }
 
  void Update() {

    Charged = false;

    if (HumanPlayer[2]) {
      joy1.xDir = 0;

      if ((abs(xOrient)==1)&&(joy1==this)&&(stick.getButton(LinksToetsen[2]%TotalNumKeys).pressed())) {
        joy1.xDir = 1;
        Lampjes |= (1L<<(LinksToetsen[2]-TranslationConstance));
      }

      if ((abs(xOrient)==1)&&(joy1==this)&&(stick.getButton(RechtsToetsen[2]%TotalNumKeys).pressed())) {
        joy1.xDir = -1;
        Lampjes |= (1L<<(RechtsToetsen[2]-TranslationConstance));
      }

      if ((abs(xOrient)==1)&&(joy1==this)&&(stick.getButton((int)(PlusToetsen[2]%TotalNumKeys)).pressed())) {
        Lampjes |= (1L<<(int)(PlusToetsen[2]-TranslationConstance));
        if ((!DoubleSize)&&(!HalfSize)) {
          if (Score >= 30000) {
            Score -= 30000;
            DoubleSize = true;
            w = ((width-10)*abs(xOrient))+10; // h = (110*abs(yOrient))+10;
            ffc_time = (frameCounter + dtime);
          }
        }
      }

      if ((!HalfSize)&&(DoubleSize)&&(abs(xOrient)==1)&&(joy1==this)&&((frameCounter == ffc_time))) {
        DoubleSize = false;
        w = (50*abs(xOrient))+10; // h = (50*abs(yOrient))+10;
      }

      if ((abs(xOrient)==1)&&(joy1==this)&&(stick.getButton(MinToetsen[2]%TotalNumKeys).pressed())) {
        Lampjes |= (1L<<(MinToetsen[2]-TranslationConstance));
        if ((!HalfSize)&&(!DoubleSize)) {
          if (Score >= 30000) {
            Score += 10000;
            HalfSize = true;
            w = (20*abs(xOrient))+10; // h = (20*abs(yOrient))+10;
            ffc_time = (frameCounter + dtime);
          }
        }
      }

      if ((!DoubleSize)&&(HalfSize)&&(abs(xOrient)==1)&&(joy1==this)&&(frameCounter == ffc_time)) {
        HalfSize = false;
        w = (50*abs(xOrient))+10; // h = (50*abs(yOrient))+10;
      }

      if ((abs(xOrient)==1)&&(joy1==this)&&(stick.getButton(VuurKnoppen[2]%TotalNumKeys).pressed())) {
        Lampjes |= (1L<<(VuurKnoppen[2]-TranslationConstance));
        Charged = true;
      }
//      else if ((abs(xOrient)==1)&&(joy1==this)) {
//        Charged = false;
//      }
    }
    else {
      joy1.x = ball[0].x;
      joy1.xDir = 0;
    }

    if (HumanPlayer[3]) {
      joy2.yDir = 0;

      if ((abs(yOrient)==1)&&(joy2==this)&&(stick.getButton(LinksToetsen[3]%TotalNumKeys).pressed())) {
        joy2.yDir = -1;
        Lampjes |= (1L<<(LinksToetsen[3]-TranslationConstance));
      }

      if ((abs(yOrient)==1)&&(joy2==this)&&(stick.getButton(RechtsToetsen[3]%TotalNumKeys).pressed())) {
        joy2.yDir = 1;
        Lampjes |= (1L<<(RechtsToetsen[3]-TranslationConstance));
      }

      if ((abs(yOrient)==1)&&(joy2==this)&&(stick.getButton((int)(PlusToetsen[3]%TotalNumKeys)).pressed())) {
        Lampjes |= (1L<<(int)(PlusToetsen[3]-TranslationConstance));
        if ((!DoubleSize)&&(!HalfSize)) {
          if (Score >= 30000) {
            Score -= 30000;
            DoubleSize = true;
            h = ((height-10)*abs(yOrient))+10; // w = (110*abs(xOrient))+10;
            ffc_time = (frameCounter + dtime);
          }
        }
      }
      
      if ((!HalfSize)&&(DoubleSize)&&(abs(yOrient)==1)&&(joy2==this)&&(frameCounter == ffc_time)) {
        DoubleSize = false;
        h = (50*abs(yOrient))+10; // w = (50*abs(xOrient))+10;
      }

      if ((abs(yOrient)==1)&&(joy2==this)&&(stick.getButton(MinToetsen[3]%TotalNumKeys).pressed())) {
        Lampjes |= (1L<<(MinToetsen[3]-TranslationConstance));
        if ((!HalfSize)&&(!DoubleSize)) {
          if (Score >= 30000) {
            Score += 10000;
            HalfSize = true;
            h = (20*abs(yOrient))+10; // w = (20*abs(xOrient))+10;
            ffc_time = (frameCounter + dtime);
          }
        }
      }

      if ((!DoubleSize)&&(HalfSize)&&(abs(yOrient)==1)&&(joy2==this)&&(frameCounter == ffc_time)) {
        HalfSize = false;
        h = (50*abs(yOrient))+10; // w = (50*abs(xOrient))+10;
      }

      if ((abs(yOrient)==1)&&(joy2==this)&&(stick.getButton(VuurKnoppen[3]%TotalNumKeys).pressed())) {
        Lampjes |= (1L<<(VuurKnoppen[3]-TranslationConstance));
        Charged = true;
      }
//      else if ((abs(yOrient)==1)&&(joy2==this)) {
//        Charged = false;
//      }
    }
    else {
      joy2.y = ball[0].y;
      joy2.yDir = 0;
    }
    
    if (HumanPlayer[0]) {
      joy3.xDir = 0;

      if ((abs(xOrient)==1)&&(joy3==this)&&(stick.getButton(LinksToetsen[0]%TotalNumKeys).pressed())) {
        joy3.xDir = -1;
        Lampjes |= (1L<<(LinksToetsen[0]-TranslationConstance));
      }

      if ((abs(xOrient)==1)&&(joy3==this)&&(stick.getButton(RechtsToetsen[0]%TotalNumKeys).pressed())) {
        joy3.xDir = 1;
        Lampjes |= (1L<<(RechtsToetsen[0]-TranslationConstance));
      }

      if ((abs(xOrient)==1)&&(joy3==this)&&(stick.getButton((int)(PlusToetsen[0]%TotalNumKeys)).pressed())) {
        Lampjes |= (1L<<(int)(PlusToetsen[0]-TranslationConstance));
        if ((!DoubleSize)&&(!HalfSize)) {
          if (Score >= 30000) {
            Score -= 30000;
            DoubleSize = true;
            w = ((width-10)*abs(xOrient))+10; // h = (110*abs(yOrient))+10;
            ffc_time = (frameCounter + dtime);
          }
        }
      }

      if ((!HalfSize)&&(DoubleSize)&&(abs(xOrient)==1)&&(joy3==this)&&(frameCounter == ffc_time)) {
        DoubleSize = false;
        w = (50*abs(xOrient))+10; // h = (50*abs(yOrient))+10;
      }

      if ((abs(xOrient)==1)&&(joy3==this)&&(stick.getButton(MinToetsen[0]%TotalNumKeys).pressed())) {
        Lampjes |= (1L<<(MinToetsen[0]-TranslationConstance));
        if ((!HalfSize)&&(!DoubleSize)) {
          if (Score >= 30000) {
            Score += 10000;
            HalfSize = true;
            w = (20*abs(xOrient))+10; // h = (20*abs(yOrient))+10;
            ffc_time = (frameCounter + dtime);
          }
        }
      }

      if ((!DoubleSize)&&(HalfSize)&&(abs(xOrient)==1)&&(joy3==this)&&(frameCounter == ffc_time)) {
        HalfSize = false;
        w = (50*abs(xOrient))+10; // h = (50*abs(yOrient))+10;
      }

      if ((abs(xOrient)==1)&&(joy3==this)&&(stick.getButton(VuurKnoppen[0]%TotalNumKeys).pressed())) {
        Lampjes |= (1L<<(VuurKnoppen[0]-TranslationConstance));
        Charged = true;
      }
//      else if ((abs(xOrient)==1)&&(joy3==this)) {
//        Charged = false;
//      }
    }
    else {
      joy3.x = ball[0].x;
      joy3.xDir = 0;
    }

    if (HumanPlayer[1]) {
      joy4.yDir = 0;

      if ((abs(yOrient)==1)&&(joy4==this)&&(stick.getButton(LinksToetsen[1]%TotalNumKeys).pressed())) {
        joy4.yDir = 1;
        Lampjes |= (1L<<(LinksToetsen[1]-TranslationConstance));
      }

      if ((abs(yOrient)==1)&&(joy4==this)&&(stick.getButton(RechtsToetsen[1]%TotalNumKeys).pressed())) {
        joy4.yDir = -1;
        Lampjes |= (1L<<(RechtsToetsen[1]-TranslationConstance));
      }

      if ((abs(yOrient)==1)&&(joy4==this)&&(stick.getButton((int)(PlusToetsen[1]%TotalNumKeys)).pressed())) {
        Lampjes |= (1L<<(int)(PlusToetsen[1]-TranslationConstance));
        if ((!DoubleSize)&&(!HalfSize)) {
          if (Score >= 30000) {
            Score -= 30000;
            DoubleSize = true;
            h = ((height-10)*abs(yOrient))+10; // w = (110*abs(xOrient))+10;
            ffc_time = (frameCounter + dtime);
          }
        }
      }

      if ((!HalfSize)&&(DoubleSize)&&(abs(yOrient)==1)&&(joy4==this)&&(frameCounter == ffc_time)) {
        DoubleSize = false;
        h = (50*abs(yOrient))+10; // w = (50*abs(xOrient))+10;
      }

      if ((abs(yOrient)==1)&&(joy4==this)&&(stick.getButton(MinToetsen[1]%TotalNumKeys).pressed())) {
        Lampjes |= (1L<<(MinToetsen[1]-TranslationConstance));
        if ((!HalfSize)&&(!DoubleSize)) {
          if (Score >= 30000) {
            Score += 10000;
            HalfSize = true;
            h = (20*abs(yOrient))+10; // w = (20*abs(xOrient))+10;
            ffc_time = (frameCounter + dtime);
          }
        }
      }

      if ((HalfSize)&&(!DoubleSize)&&(abs(yOrient)==1)&&(joy4==this)&&(frameCounter == ffc_time)) {
        HalfSize = false;
        h = (50*abs(yOrient))+10; // w = (50*abs(xOrient))+10;
      }

      if ((abs(yOrient)==1)&&(joy4==this)&&(stick.getButton(VuurKnoppen[1]%TotalNumKeys).pressed())) {
        Lampjes |= (1L<<(VuurKnoppen[1]-TranslationConstance));
        Charged = true;
      }
//      else if ((abs(yOrient)==1)&&(joy4==this)) {
//        Charged = false;
//      }
    }
    else {
      joy4.y = ball[0].y;
      joy4.yDir = 0;
    }

// Joystick moves here!

    x += (joySpeed * xDir);
    y += (joySpeed * yDir);
    
    if ((x < (w/2)) || (x > (width-(w/2)))) {
      xDir = 0;
      if (x < (w/2))
        x = (w/2);
      if (x > (width-(w/2)))
        x = (width-(w/2));
    }

    if ((y < (h/2)) || (y > (height-(h/2)))) {
      yDir = 0;
      if (y < (h/2))
        y = (h/2);
      if (y > (height-(h/2)))
        y = (height-(h/2));
    }
    
// Collision Detection here!

    for (int i=0;i<NumBalls;i++) {
      int temp = ball[i].r;
      if (abs(x - ball[i].x) * 2 < (w + temp) && 
        abs(y - ball[i].y) * 2 < (h + temp)) {
        if (!(collided[i])) {
          Score++;
//          ball[i].Color = Color;
          if (abs(yOrient) == 1) {
            ball[i].xDir = -ball[i].xDir;
            ball[i].xSpeed = int(random(ballSpeed))+1;

            int dy = abs(y - ball[i].y);
            if ((y<ball[i].y) && (ball[i].yDir<0)) {
              ball[i].yDir = -ball[i].yDir;
            }
            else {
            if ((y>ball[i].y) && (ball[i].yDir>0)) {
              ball[i].yDir = -ball[i].yDir;
            }}
            ball[i].ySpeed = (int((float((dy)) / float(h/2)) * float(ballSpeed)) % ballSpeed) + 1; //can be 0! int(random(ballSpeed))+1;
          }
          if (abs(xOrient) == 1) {
            ball[i].yDir = -ball[i].yDir;
            ball[i].ySpeed = int(random(ballSpeed))+1;
            
            int dx = abs(x - ball[i].x);
            if ((x<ball[i].x) && (ball[i].xDir<0)) {
              ball[i].xDir = -ball[i].xDir;
            }
            else {
            if ((x>ball[i].x) && (ball[i].xDir>0)) {
              ball[i].xDir = -ball[i].xDir;
            }}
            ball[i].xSpeed = (int((float((dx)) / float(w/2)) * float(ballSpeed)) % ballSpeed) + 1; //can be 0! int(random(ballSpeed))+1;
          }
          ping.trigger();
          collided[i] = true;
          if ((ball[i].Loaded)&&(!Charged)) {
            ball[i].Loaded = false;
//            Opacity = 0; // explosie, game over voor deze speler!
            if ((Opacity==255)&&(ball[i].Color == joy1.Color))
              joy1.Score += 100000;
            else
            if ((Opacity==255)&&(ball[i].Color == joy2.Color))
              joy2.Score += 100000;
            else
            if ((Opacity==255)&&(ball[i].Color == joy3.Color))
              joy3.Score += 100000;
            else
            if ((Opacity==255)&&(ball[i].Color == joy4.Color))
              joy4.Score += 100000;
            Opacity = 0; // explosie, game over voor deze speler!
          }
//          else {
//            if (Opacity != 0) {
//              Opacity = 255;
//            }
//          }
          if ((Opacity==255)&&(Charged)) {
            ball[i].Loaded = ((ball[i].Loaded)?(false):(true));
            Score += 10;
          }
//          else {
//            ball[i].Loaded = false;
//          }
          if ((Opacity==255)&&(ball[i].Color == color(255,255,255))) {
            Score += 1000; // White balls are worth an extra 1000 points!
          }
          ball[i].Color = Color;
        }
      }
      else {
        collided[i] = false;
      }
    }
  }

  void Display() {
    rectMode(CENTER);
    stroke(Color,(Opacity==0)?(0):(160));
    strokeWeight(2);
    strokeJoin(BEVEL); // BEVEL, MITER, ROUND
    fill(Color,(Opacity==0)?(0):(255));
    if (Opacity==255) {
      rect(x,y,w,h);
    }
    else {
      if (FirstTime) {
        w = h = 5; // ((frameCounter)%100)+1;
        FirstTime = false;
      }
      strokeWeight(5);
      if (w >= 255) {
        w=h=255;
        fill(Color,0);
      }
      else {
        stroke(Color,255);
        ellipse(x,y,w,h); // Radiant explosion!
        w+=3;h+=3;
      }
    }

    if (Charged) {
      stroke(Color,255);
      strokeWeight(2);
      noFill();
      ellipse(x,y,(w>h)?(w+5):(h+5),(w>h)?(w+5):(h+5));
    }

    pushMatrix();
    translate(((width/2) - (((width-30)/2) * yOrient)),((height/2) - (((height-30)/2) * xOrient)));
    fill(255,255,255);
    textSize(20);
    rotate(radians(PlayerAngle[PNaampje&3])); // ((abs(xOrient)) == 0)?(90 * yOrient):((abs(yOrient) == 0)?((90 * xOrient) + 90):0)));
    textAlign(LEFT,CENTER);
    text(Naam[(PNaampje&3)],-100,0);
    textAlign(RIGHT,CENTER);
    text(Score,100,0);
    popMatrix();
    PNaampje++;
    PNaampje &= 3;
  }
  
}

int PNaampje = 2; // There can only be 1 and this is it. It's global and static also.

class Ball {
  int x,y,xSpeed,ySpeed;
  int xDir,yDir;
  int r;
  int CorIndex = 0;
  color Color = color(255,255,255);
  boolean Loaded = false;
  
  Ball(int tx, int ty, int txSpeed, int tySpeed, int txDir, int tyDir, color tColor) {
    x = tx;
    y = ty;
    xSpeed = txSpeed;
    ySpeed = tySpeed;
    xDir = txDir;
    yDir = tyDir;
    r = 5;
    Loaded = false;
    Color = tColor;
    CorIndex = 0;
  }
  
  void Update() {
    x += (xSpeed * xDir);
    y += (ySpeed * yDir);
    
    if ((x < r) || (x > (width-r))) {
      xDir = -xDir;
      pong.trigger();
      if (x < r)
        x = r;
      if (x > (width-r))
        x = (width-r);
      if (Color == joy1.Color) {
        if (joy1.Opacity==255)
          joy1.Score += 100;
      }
      else
      if (Color == joy2.Color) {
        if (joy2.Opacity==255)
          joy2.Score += 100;
      }
      else
      if (Color == joy3.Color) {
        if (joy3.Opacity==255)
          joy3.Score += 100;
      }
      else
      if (Color == joy4.Color) {
        if (joy4.Opacity==255)
          joy4.Score += 100;
      }
      else
      {
        fill(255);
        textAlign(CENTER,CENTER);
//        text("Smashed out!", width/2,height/2);
//        uit.trigger();
      }
    }

    if ((y < r) || (y > (height-r))) {
      yDir = -yDir;
      pong.trigger();
      if (y < r)
        y = r;
      if (y > (height-r))
        y = (height-r);
      if (Color == joy1.Color) {
        if (joy1.Opacity==255)
          joy1.Score += 100;
      }
      else
      if (Color == joy2.Color) {
        if (joy2.Opacity==255)
          joy2.Score += 100;
      }
      else
      if (Color == joy3.Color) {
        if (joy3.Opacity==255)
          joy3.Score += 100;
      }
      else
      if (Color == joy4.Color) {
        if (joy4.Opacity==255)
          joy4.Score += 100;
      }
      else
      {
        fill(255);
        textAlign(CENTER,CENTER);
//        text("Smashed out!", width/2,height/2);
//        uit.trigger();
      }
    }
  }

  int HAngle = 0;
  
  void Display() {
    rectMode(CENTER);
//    fill(Color);
//    rect(x,y,2*r,2*r);

    if (Loaded) {
      stroke(CorArray[CorIndex] * r); // pen color is grey / monochrome
      noFill();
      strokeWeight(r);
      triangle(x+(cos(radians((HAngle+120)%360))*r*CorArray[CorIndex]),y+(sin(radians((HAngle+120)%360))*r*CorArray[CorIndex]),x+(cos(radians(HAngle%360))*r*CorArray[CorIndex]),y+(sin(radians(HAngle%360))*r*CorArray[CorIndex]),x+(cos(radians((HAngle-120)%360))*r*CorArray[CorIndex]),y+(sin(radians((HAngle-120)%360))*r*CorArray[CorIndex])); // rect?!
      triangle(x+(cos(radians((HAngle+60)%360))*r*CorArray[CorIndex]),y+(sin(radians((HAngle+60)%360))*r*CorArray[CorIndex]),x+(cos(radians((HAngle+180)%360))*r*CorArray[CorIndex]),y+(sin(radians((HAngle+180)%360))*r*CorArray[CorIndex]),x+(cos(radians((HAngle-60)%360))*r*CorArray[CorIndex]),y+(sin(radians((HAngle-60)%360))*r*CorArray[CorIndex])); // rect?!
      HAngle++;
      HAngle %= 360;
    }

    noStroke();
    fill(Color);
    rect(x,y,2*r,2*r); // rect?!

    CorIndex++;
    CorIndex %= 24;
  }

}

int CorArray[] = {16,15,14,13,12,11,10,9,8,7,6,5,4,5,6,7,8,9,10,11,12,13,14,15};

String CrownLijst[] = {" "," "," "," "," "," "," "," "};
int ScoreLijst[] = {100,90,80,70,60,50,40,30};
String NaamLijst[] = {"William S.","Bas ______","_Arjan ___","_Edwin ___","Michel ___","_J@nru ___","Henry ____","Willeke __"};
String Order[] = {"1. ","2. ","3. ","4. ","5. ","6. ","7. ","8. "};
int PlayerAngle[] = {0,270,180,90};

String Naam[] = {"Player 1  ","Player 2  ","Player 3  ","Player 4  "};
char KarakterSet[] = {'A','B','C','D','E','F','G','H','I','J','K','L','M',
                      'N','O','P','Q','R','S','T','U','V','W','X','Y','Z',
                      'a','b','c','d','e','f','g','h','i','j','k','l','m',
                      'n','o','p','q','r','s','t','u','v','w','x','y','z',
                      '0','1','2','3','4','5','6','7','8','9','-','+','_',
                      '=','.','(',',',')',';',':','<','>','?',' ','@','!'};

boolean Once[] = {false,false,false,false};
boolean CollectedFireButtons[] = {false,false,false,false};
int NumCollectedFireButtons = 0;
int Hulpje = 0;

class Highscore {
  int Score = 0;
  int playerX = 0;
  int CursorX = 0;
  int CursorY = 0;
  int KarCount = 64;
  char Cursor = '_';
  char chars[] = {' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '};
  boolean Crown = false;
  boolean RepKey[] = {false,false,false,false,false};
  
  Highscore(int tScore, int tplayerX, boolean tCrown) {

   Hulpje = 0;
   Score = tScore;
   playerX = tplayerX;
   CursorX = 0;
   CursorY = 0;
   KarCount = 0;
   Crown = tCrown;
   Cursor = KarakterSet[KarCount];

   for (int i=0;i<NumKeysPerPlayer;i++) {
     RepKey[i] = XRepKeys[((NumKeysPerPlayer * playerX) + i)];
   }
   Once[playerX] = false;
   for (int i=0;i<4;i++) {
     CollectedFireButtons[i] = false;
   }
   CollectedFireButtons[playerX] = false;
   NumCollectedFireButtons = 0;
   chars = Naam[playerX].toCharArray();
   Cursor = chars[CursorX];
   for (int j=0;j<78;j++) {
     if (Cursor == KarakterSet[j]) {
       KarCount = j;
       continue;
      }
    }
   KarCount %= 78;
   Cursor = KarakterSet[KarCount];
   chars[CursorX] = Cursor;
   Naam[playerX] = String.valueOf(chars);
   insert();
  }

  void insert() {
    Joystick Joys[] = {joy3,joy4,joy1,joy2};
    
    Joys[0]=joy3;
    Joys[1]=joy4;
    Joys[2]=joy1;
    Joys[3]=joy2;
    for (int i=0;i<8;i++) {
      if (Score > ScoreLijst[i]) {
        for(int j=6;j>=i;j--) {
          CrownLijst[j+1]=CrownLijst[j];
          ScoreLijst[j+1]=ScoreLijst[j];
          NaamLijst[j+1]=NaamLijst[j];
        }
        CrownLijst[i]=((Crown)?"*":" ");
        ScoreLijst[i]=Score;
        NaamLijst[i]=Naam[playerX];
        CursorY = i;
        for (int k=0;k<playerX;k++) {
          if ((Joys[k].Highscore != null)&&((CursorY) <= (Joys[k].Highscore.CursorY))) {
            Joys[k].Highscore.CursorY += 1;
          }
        }
        return; // early out!
      }
    }
    CursorY = 8; // force to 8 if below the lowest highscore!
  }

 void Display() {
  int i;
  Joystick Joys[] = {joy3,joy4,joy1,joy2};
  
  Joys[0] = joy3;
  Joys[1] = joy4;
  Joys[2] = joy1;
  Joys[3] = joy2;
  if (NumCollectedFireButtons != Hulpje) {
    for (i=0;i<8;i++) {
      pushMatrix();
      translate(((width/2)-(((width-320)/2)*(Joys[playerX].yOrient))),((height/2)-(((height-320)/2)*(Joys[playerX].xOrient))));
      rotate(radians(PlayerAngle[playerX]));

      fill(((HumanPlayer[playerX] == true)&&(Joys[playerX].Highscore != null)&&((CursorY) == i))?(Joys[playerX].Color):(color(255,255,255)));

      textSize(20);
      textAlign(LEFT,CENTER);
      text(Order[i],-120,20*i);
      textAlign(LEFT,CENTER);
      text(NaamLijst[i],-90,20*i);
      textAlign(RIGHT,CENTER);
      text(ScoreLijst[i],120,20*i);
      textAlign(CENTER,CENTER);
      text(CrownLijst[i],140,20*i);
      popMatrix();
    }
  }
 }

 void Update()
 {
//  int      i,j,k;
  Joystick Joys[] = {joy3,joy4,joy1,joy2};

  Joys[0] = joy3;
  Joys[1] = joy4;
  Joys[2] = joy1;
  Joys[3] = joy2;
  if ((CursorY < 8)&&(Joys[playerX].Highscore != null)&&(HumanPlayer[playerX] == true)) {
   for (int j=0;j<NumKeysPerPlayer;j++)
    {
     RepKey[j] = XRepKeys[((playerX * NumKeysPerPlayer) + j)];
    }

   playerX %= 4;
   chars = Naam[playerX].toCharArray();
   CursorX %= 10;
   Cursor = chars[CursorX];

   if (stick.getButton(PlusToetsen[playerX]%TotalNumKeys).pressed())
     {
       Lampjes |= (1L<<(PlusToetsen[playerX]-TranslationConstance));
       if (!(RepKey[3])) {
         for (int i=0;i<78;i++) {
           if (Cursor == KarakterSet[i]) {
             KarCount = i;
             continue;
           }
         }

         KarCount++;

         if (KarCount > 77)
           KarCount = 0;
         if (KarCount < 0)
           KarCount = 77;
         KarCount %= 78;

         Cursor = KarakterSet[KarCount];

         RepKey[3] = true;
       }
     }
   else
     {
       RepKey[3] = false;
     }

   if (stick.getButton(MinToetsen[playerX]%TotalNumKeys).pressed())
     {
       Lampjes |= (1L<<(MinToetsen[playerX]-TranslationConstance));
       if (!(RepKey[4])) {
         for (int i=0;i<78;i++) {
           if (Cursor == KarakterSet[i]) {
             KarCount = i;
             continue;
           }
         }

         KarCount--;

         if (KarCount > 77)
           KarCount = 0;
         if (KarCount < 0)
           KarCount = 77;
         KarCount %= 78;

         Cursor = KarakterSet[KarCount];

         RepKey[4] = true;
       }
     }
   else
     {
       RepKey[4] = false;
     }

   if (stick.getButton(LinksToetsen[playerX]%TotalNumKeys).pressed())
     {
       Lampjes |= (1L<<(LinksToetsen[playerX]-TranslationConstance));
       if (!(RepKey[0])) {
         CursorX--;

         if (CursorX < 0)
           CursorX = 0;
         if (CursorX > 9)
           CursorX = 9;
         CursorX %= 10;

         Cursor = chars[CursorX];
         
         for (int i=0;i<78;i++) {
           if (Cursor == KarakterSet[i]) {
             KarCount = i;
             continue;
           }
         }
         RepKey[0] = true;
       }
     }
   else
     {
       RepKey[0] = false;
     }

   if (stick.getButton(RechtsToetsen[playerX]%TotalNumKeys).pressed())
     {
       Lampjes |= (1L<<(RechtsToetsen[playerX]-TranslationConstance));
       if (!(RepKey[2])) {
         CursorX++;

         if (CursorX < 0)
           CursorX = 0;
         if (CursorX > 9)
           CursorX = 9;
         CursorX %= 10;

         Cursor = chars[CursorX];

         for (int i=0;i<78;i++) {
           if (Cursor == KarakterSet[i]) {
             KarCount = i;
             continue;
           }
         }
         RepKey[2] = true;
       }
     }
   else
     {
       RepKey[2] = false;
     }

   if (stick.getButton(VuurKnoppen[playerX]%TotalNumKeys).pressed())
     {
       Lampjes |= (1L<<(VuurKnoppen[playerX]-TranslationConstance));
       if (!(RepKey[1])) {
         for (int i=(0+TranslationConstance);i<(NumKeys+TranslationConstance);i++) {
           keysPressed[i] = 0;
         }
         buttonPressed = false;
         CollectedFireButtons[playerX] = HumanPlayer[playerX];  // true;
         RepKey[1] = true;
       }
     }
   else
     {
       RepKey[1] = false;
     }

   CursorX %= 10;
   playerX %= 4;
   KarCount %= 78;
   Cursor = KarakterSet[KarCount];
   chars[CursorX] = Cursor;
   Naam[playerX] = String.valueOf(chars);

   for (int k=0;k<NumKeysPerPlayer;k++)
    {
     XRepKeys[((NumKeysPerPlayer * playerX) + k)] = RepKey[k];
    }
    
  } // End of Update() / Main IF CursorY<8

   NumCollectedFireButtons = 0;
   for (int j=0;j<4;j++) {
     NumCollectedFireButtons = ((CollectedFireButtons[j] == true)?(NumCollectedFireButtons + 1):(NumCollectedFireButtons));
   }
   
   Hulpje = NumHumanPlayers;
   
   for (int i=0;i<4;i++) {
     if ((Joys[i] != null) && ((Joys[i].Highscore) != null)) {
       if ((HumanPlayer[i])&&(Joys[i].Highscore.CursorY) > 7) {
         Hulpje--;
         if (Hulpje < 0)
           Hulpje = 0; // NumHumanPlayers;
       }
     }
   }

   if ((NumCollectedFireButtons == Hulpje)) {
     resetGame = true;
     frameCounter = 32000; // Skip to End + saveHighscores()
   }

// Do strcpy(NaamLijst[CursorY],Naam[playerX]); here!
//    memcpy(NaamLijst[CursorY],Naam[playerX],10);
// This is your double buffering!

  chars = Naam[playerX].toCharArray();
  if (CursorY > 7) {
    if (!(Once[playerX])) {
      println(Naam[playerX],", you dropped off the highscorelist!");
      Once[playerX] = true;
    }
  }
  else {
    NaamLijst[CursorY] = String.valueOf(chars);
  }
 } // End of Update()

} // End of class Highscore
