/*********************************/
/*      Pong voor 4 spelers      */
/*                               */
/*      Geprogrammeerd door      */
/*                               */
/*         William  Senn         */
/*          Bas  Timmer          */
/*        Arjan  Boeijink        */
/*                               */
/*   AssortiMens (C) 2018-2020   */
/*********************************/
/*          Kast-Versie          */
/*********************************/

int KastVersie = 3; /* 3 = true, 0 = false */

import org.gamecontrolplus.*;

import ddf.minim.*;

Minim minim;

AudioPlayer titlesong;
AudioSample ping;
AudioSample pong;
AudioSample uit;

ControlIO control;
ControlDevice stick;

int TextOrientation = 0;

int TextSize = 1;

Joystick joy1 = null;
Joystick joy2 = null;
Joystick joy3 = null;
Joystick joy4 = null;

int joySpeed = 10;

int NumBalls = 30;
Ball ball[] = {null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null,null};

int ballSpeed = 9;

int NumKeys = 20;
int NumKeysPerPlayer = 5;

int Player;
int Key;
int keysPressed[] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
boolean buttonPressed = false;

boolean XRepKeys[] = {false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false};

boolean HumanPlayer[] = {false,false,false,false};
int NumHumanPlayers = 0;

int Dirs[] = {-1,1};

int frameCounter = 0;
int Kleur = -1;
boolean Opkomst = true;

Table table = null;
int NumRows = 8;

void setup() {
//  size(1024,768);
  fullScreen();
  control = ControlIO.getInstance(this);
  try {
    println(control.deviceListToText(""));
    stick = control.getDevice((KastVersie==3)?("Arduino Leonardo"):("AT Translated Set 2 keyboard"));
  }
  catch (Exception e) {
    println("No Arduino found or no Toetsenbord/Keyboard configured!");
    System.exit(0);
  }
  try {
    minim = new Minim(this);
    ping = minim.loadSample("data/ping.mp3");
    pong = minim.loadSample("data/pong.mp3");
    uit = minim.loadSample("data/uit.mp3");
    titlesong = minim.loadFile("data/12-dreams.mp3");
  }
  catch (Exception e) {
    println("No sounds found!");
    System.exit(0);
  }

  loadHighscores();
  saveHighscores();

  TextOrientation=0;
  
  titlesong.loop();
  
  demoMode();
  initGame();
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
  TextSize = 1;

  NumCollectedFireButtons = 0;
  NumHumanPlayers = 0;

  for (int k=0;k<4;k++) {
    HumanPlayer[k] = false;
    CollectedFireButtons[k] = false;
   }

  buttonPressed = false;
  for (int j=0;j<NumKeys;j++)
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

  joy1 = new Joystick(30,30,1,0,color(255,0,255));
  joy2 = new Joystick(30,30,0,1,color(255,0,0));
  joy4 = new Joystick(width-30,height-30,0,-1,color(0,255,0));
  joy3 = new Joystick(width-30,height-30,-1,0,color(0,0,255));
  
  for (int i=0;i<NumBalls;i++)
  {
    ball[i] = new Ball(width/2,height/2,int(random(ballSpeed))+1,int(random(ballSpeed))+1,Dirs[int(random(2))],Dirs[int(random(2))],color(255,255,255));
  }
}

int millis1 = 0;
int millis2 = 0;
int verschil = 0;

void draw() {
/* frame tijd achterhalen */
  millis1 = millis2;
  millis2 = millis();
  verschil = millis2 - millis1;
//  println(verschil);

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
      for (int i=0;i<NumKeys;i++) {
        Key=keysPressed[i];
        keysPressed[i]=0;
        if (Key>0) {
          Player = (Key-1) / NumKeysPerPlayer;
          Key = (Key-1) % NumKeysPerPlayer;

          background(0);
          text("Player=",100,100);
          text(Player,180,100);
          text("Key=",100,150);
          text(Key,150,150);

          HumanPlayer[Player]=true;
          NumHumanPlayers = 0;

          for(int j=0;j<4;j++) {
            text("HumanPlayer[j]=", 100,(200+50*j));
            text(((HumanPlayer[j])?"true":"false"), 260,(200+50*j));
            NumHumanPlayers = ((HumanPlayer[j])?(NumHumanPlayers+1):(NumHumanPlayers));
           }
          text("NumHumanPlayers = ", 100,400);
          text(NumHumanPlayers, 260, 400);
        }
      }
    }

    if ((frameCounter>=11000)&&(frameCounter<20000)){
      background(0);
      perFrameGame();
    }
    frameCounter++;
    if (frameCounter>=20000) {
      background(0);
      if (frameCounter==20000) {
        joy3.Highscore = new Highscore(joy3.Score,0);
        joy4.Highscore = new Highscore(joy4.Score,1);
        joy1.Highscore = new Highscore(joy1.Score,2);
        joy2.Highscore = new Highscore(joy2.Score,3);
       }
      if (frameCounter>=21000) {

        joy3.Highscore.Display();    // Magenta
//        if (joy4.y <= joy2.y) {
          joy4.Highscore.Display();  // Red
          joy2.Highscore.Display();  // Green
//         }
//        else {
//          joy2.Highscore.Display();  // Red
//          joy4.Highscore.Display();  // Blue
//         }
        joy1.Highscore.Display();    // Blue

        joy3.Highscore.Update();
        joy4.Highscore.Update();
        joy1.Highscore.Update();
        joy2.Highscore.Update();

        TestToResetGame();

        if (frameCounter>=31000) {
          frameCounter=0;
          resetGame = true;
          
          /* flush all keys! */
//          ButtonPressed();
//          for (int j=0;j<NumKeys;j++) {
//            keysPressed[j] = 0;
//           }
//          buttonPressed = false;
//          keyPressed = false;

//          for (int i=0;i<4;i++) {
//            HumanPlayer[i] = false;
//           }

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
         if (TextSize > 128) {
           TextSize = 128;
         }
         text("Game Over!",0,0);
//         text("Release all keys, please!",0,100);
         popMatrix();

         /* flush all keys */
//         ButtonPressed();
//         buttonPressed = false;
//         keyPressed = false;
//         for (int i=0;i<NumKeys;i++) {
//           keysPressed[i] = 0;
//         }
       }
    }
  }
  else {
    frameCounter++;
  }
  if (frameCounter>=4000) {
    if (frameCounter>=10000) {
    }
    else
      frameCounter=0;
  }
}

boolean resetGame = false;

void TestToResetGame() {
  if (resetGame == true)
   {
    ButtonPressed();
    while(buttonPressed == true)
    {
      ButtonPressed();
    }

    saveHighscores();

    initGame();
    demoMode();
    resetGame = false;
   }
}

void keyPressed() {
// Joystick Joys[] = {joy3,joy4,joy1,joy2};

// Joys[0] = joy3;
// Joys[1] = joy4;
// Joys[2] = joy1;
// Joys[3] = joy2;

 buttonPressed=false;
// keyPressed = false;
 for (int i=0;i<NumKeys;i++) {
      keysPressed[i]=0;
 }
// if (HumanPlayer[0]) {
  if (key == (LinksToetsen[0] + '1' - LinksToetsen[0])) {
   buttonPressed=true;
   keysPressed[0]=LinksToetsen[0]+1;
//   Joys[0].xDir = -1;
  }
  if (key == (VuurKnoppen[0] + '2' - VuurKnoppen[0])) {
   buttonPressed=true;
   keysPressed[1]=VuurKnoppen[0]+1;
//   Joys[0].xDir = 0;
  }
  if (key == (RechtsToetsen[0] + '3' - RechtsToetsen[0])) {
   buttonPressed=true;
   keysPressed[2]=RechtsToetsen[0]+1;
//   Joys[0].xDir = 1;
  }
  if (key == (PlusToetsen[0] + '4' - PlusToetsen[0])) {
   buttonPressed=true;
   keysPressed[3]=PlusToetsen[0]+1;
/*
   if (Joys[0]!=null) {
    if (Joys[0].Highscore!=null) {
     Joys[0].Highscore.KarCount++;
     Joys[0].Highscore.KarCount %= 78;
    }
   }
*/
  }
  if (key == (MinToetsen[0] + '5' - MinToetsen[0])) {
   buttonPressed=true;
   keysPressed[4]=MinToetsen[0]+1;
/*
   if (Joys[0]!=null) {
    if (Joys[0].Highscore!=null) {
     Joys[0].Highscore.KarCount--;
     Joys[0].Highscore.KarCount %= 78;
    }
   }
*/
  }
// }

// if (HumanPlayer[1]) {  
  if (key == (LinksToetsen[1] + 'q' - LinksToetsen[1])) {
   buttonPressed=true;
   keysPressed[(1*NumKeysPerPlayer)+0]=LinksToetsen[1]+1;
//   Joys[1].yDir = 1;
  }
  if (key == (VuurKnoppen[1] + 'w' - VuurKnoppen[1])) {
   buttonPressed=true;
   keysPressed[(1*NumKeysPerPlayer)+1]=VuurKnoppen[1]+1;
//   Joys[1].yDir = 0;
  }
  if (key == (RechtsToetsen[1] + 'e' - RechtsToetsen[1])) {
   buttonPressed=true;
   keysPressed[(1*NumKeysPerPlayer)+2]=RechtsToetsen[1]+1;
//   Joys[1].yDir = -1;
  }
  if (key == (PlusToetsen[1] + 'r' - PlusToetsen[1])) {
   buttonPressed=true;
   keysPressed[(1*NumKeysPerPlayer)+3]=PlusToetsen[1]+1;
/*
   if (Joys[1]!=null) {
    if (Joys[1].Highscore!=null) {
     Joys[1].Highscore.KarCount++;
     Joys[1].Highscore.KarCount %= 78;
    }
   }
*/
  }
  if (key == (MinToetsen[1] + 't' - MinToetsen[1])) {
   buttonPressed=true;
   keysPressed[(1*NumKeysPerPlayer)+4]=MinToetsen[1]+1;
/*
   if (Joys[1]!=null) {
    if (Joys[1].Highscore!=null) {
     Joys[1].Highscore.KarCount--;
     Joys[1].Highscore.KarCount %= 78;
    }
   }
*/
  }
// }

// if (HumanPlayer[2]) {  
  if (key == (LinksToetsen[2] + 'a' - LinksToetsen[2])) {
   buttonPressed=true;
   keysPressed[(2*NumKeysPerPlayer)+0]=LinksToetsen[2]+1;
//   Joys[2].xDir = 1;
  }
  if (key == (VuurKnoppen[2] + 's' - VuurKnoppen[2])) {
   buttonPressed=true;
   keysPressed[(2*NumKeysPerPlayer)+1]=VuurKnoppen[2]+1;
//   Joys[2].xDir = 0;
  }
  if (key == (RechtsToetsen[2] + 'd' - RechtsToetsen[2])) {
   buttonPressed=true;
   keysPressed[(2*NumKeysPerPlayer)+2]=RechtsToetsen[2]+1;
//   Joys[2].xDir = -1;
  }
  if (key == (PlusToetsen[2] + 'f' - PlusToetsen[2])) {
   buttonPressed=true;
   keysPressed[(2*NumKeysPerPlayer)+3]=PlusToetsen[2]+1;
/*
   if (Joys[2]!=null) {
    if (Joys[2].Highscore!=null) {
     Joys[2].Highscore.KarCount++; 
     Joys[2].Highscore.KarCount %= 78;
    }
   }
*/
  }
  if (key == (MinToetsen[2] + 'g' - MinToetsen[2])) {
   buttonPressed=true;
   keysPressed[(2*NumKeysPerPlayer)+4]=MinToetsen[2]+1;
/*
   if (Joys[2]!=null) {
    if (Joys[2].Highscore!=null) {
     Joys[2].Highscore.KarCount--;
     Joys[2].Highscore.KarCount %= 78;
    }
   }
*/
  }
// }
 
// if (HumanPlayer[3]) { 
  if (key == (LinksToetsen[3] + 'z' - LinksToetsen[3])) {
   buttonPressed=true;
   keysPressed[(3*NumKeysPerPlayer)+0]=LinksToetsen[3]+1;
/*
   if (Joys[3]!=null) {
    Joys[3].yDir = -1;
    if (Joys[3].Highscore!=null) {
     Joys[3].Highscore.CursorX--;
     Joys[3].Highscore.CursorX %= 10;
    }
   }
*/
  }
  if (key == (VuurKnoppen[3] + 'x' - VuurKnoppen[3])) {
   buttonPressed=true;
   keysPressed[(3*NumKeysPerPlayer)+1]=VuurKnoppen[3]+1;
//   Joys[3].yDir = 0;
  }
  if (key == (RechtsToetsen[3] + 'c' - RechtsToetsen[3])) {
   buttonPressed=true;
   keysPressed[(3*NumKeysPerPlayer)+2]=RechtsToetsen[3]+1;
/*
   if (Joys[3]!=null) {
    Joys[3].yDir = 1;
    if (Joys[3].Highscore!=null) {
     Joys[3].Highscore.CursorX++;
     Joys[3].Highscore.CursorX %= 10;
    }
   }
*/
  }
  if (key == (PlusToetsen[3] + 'v' - PlusToetsen[3])) {
   buttonPressed=true;
   keysPressed[(3*NumKeysPerPlayer)+3]=PlusToetsen[3]+1;
/*
   if (Joys[3].Highscore!=null) {
    Joys[3].Highscore.KarCount++;
    Joys[3].Highscore.KarCount %= 78;
   }
*/
  }
  if (key == (MinToetsen[3] + 'b' - MinToetsen[3])) {
   buttonPressed=true;
   keysPressed[(3*NumKeysPerPlayer)+4]=MinToetsen[3]+1;
/*
   if (Joys[3].Highscore!=null) {
    Joys[3].Highscore.KarCount--;
    Joys[3].Highscore.KarCount %= 78;
   }
*/
  }
// }
}

void ButtonPressed() {
  if (KastVersie == 3) {
    buttonPressed = false;
    for (int z=0;z<NumKeys;z++) {
      if (stick.getButton(z).pressed()) {
        buttonPressed = true;
        keysPressed[z] = (z+1);
      }
      else
       {
        keysPressed[z] = 0;
       }
    }
  }
 else
  {
   keyPressed();
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
  pushMatrix();
  fill(Kleur);
  textSize(20);
  translate(width/2,height/2);
  textAlign(CENTER,CENTER);
  rotate(radians(TextOrientation++));
  TextOrientation %= 360;
  text("AssortiMens presents",0,-50);
  text("Pong",0,0);
  text("© 2020",0,50);

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
  pushMatrix();
  fill(Kleur);
  textSize(20);
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
  pushMatrix();
  fill(Kleur);
  textSize(20);
  translate(width/2,height/2);
  textAlign(CENTER,CENTER);
  rotate(radians(TextOrientation++));
  TextOrientation %= 360;
  text("Hall of Fame",0,-160);

  for (int i=0;i<8;i++) {
    textAlign(CENTER,CENTER);
    text(Order[i],-100,(30*i)-130);
    textAlign(LEFT,CENTER);
    text(NaamLijst[i],-80,(30*i)-130);
    textAlign(RIGHT,CENTER);
    text(ScoreLijst[i],120,(30*i)-130);
  }
  fill(255);
  textAlign(CENTER,CENTER);
  text("Press a button to start",0,150);
  popMatrix();
}

void perFrameDemo4() {
  background(0);
  perFrameGame();
  pushMatrix();
  textSize(20);
  fill(255);
  translate(width/2,height/2);
  textAlign(CENTER,CENTER);
  rotate(radians(TextOrientation++));
  TextOrientation %= 360;
  text("DEMO",0,0);
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
  
  joy1.Update();
  joy2.Update();
  joy3.Update();
  joy4.Update();
  
  for (int j=0;j<NumBalls;j++)
  {
    ball[j].Update();
  }
}

class Joystick {
  int x,y;
  int xDir,yDir,xOrient,yOrient;
  int w,h;
  int Score;
  boolean collided[]={false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false};
  color Color = color(255,255,255);
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
    for (int i=0;i<NumBalls;i++)
      {
        collided[i] = false;
      }
    Color = tColor;
    Highscore = null;
    PNaampje = 2;
  }
  
  void Update() {
//    Joystick Joys[] = {joy1,joy2,joy3,joy4};
    
//    Joys[0] = joy1;
//    Joys[1] = joy2;
//    Joys[2] = joy3;
//    Joys[3] = joy4;

    if (HumanPlayer[2]) {
      joy1.xDir = 0;
      if ((abs(xOrient)==1)&&(joy1==this)&&((KastVersie==3)?(stick.getButton(LinksToetsen[2]).pressed()):((key == 'a')))) {
        joy1.xDir = 1;
      }
      if ((abs(xOrient)==1)&&(joy1==this)&&((KastVersie==3)?(stick.getButton(RechtsToetsen[2]).pressed()):((key == 'd')))) {
        joy1.xDir = -1;
      }
      if ((abs(xOrient)==1)&&(joy1==this)&&((KastVersie==3)?(stick.getButton(PlusToetsen[2]).pressed()):((key == 'f')))) {
        w = (110*abs(xOrient))+10;
      }
      if ((abs(xOrient)==1)&&(joy1==this)&&((KastVersie==3)?(stick.getButton(MinToetsen[2]).pressed()):((key == 'g')))) {
        w = (50*abs(xOrient))+10;
      }
    }
    else {
      joy1.x = ball[0].x;
      joy1.xDir = 0;
    }

    if (HumanPlayer[3]) {
      joy2.yDir = 0;
      if ((abs(yOrient)==1)&&(joy2==this)&&((KastVersie==3)?(stick.getButton(LinksToetsen[3]).pressed()):((key == 'z')))) {
        joy2.yDir = -1;
      }
      if ((abs(yOrient)==1)&&(joy2==this)&&((KastVersie==3)?(stick.getButton(RechtsToetsen[3]).pressed()):((key == 'c')))) {
        joy2.yDir = 1;
      }
      if ((abs(yOrient)==1)&&(joy2==this)&&((KastVersie==3)?(stick.getButton(PlusToetsen[3]).pressed()):((key == 'v')))) {
        h = (110*abs(yOrient))+10;
      }
      if ((abs(yOrient)==1)&&(joy2==this)&&((KastVersie==3)?(stick.getButton(MinToetsen[3]).pressed()):((key == 'b')))) {
        h = (50*abs(yOrient))+10;
      }
    }
    else {
      joy2.y = ball[0].y;
      joy2.yDir = 0;
    }
    
    if (HumanPlayer[0]) {
      joy3.xDir = 0;
      if ((abs(xOrient)==1)&&(joy3==this)&&((KastVersie==3)?(stick.getButton(LinksToetsen[0]).pressed()):((key == '1')))) {
        joy3.xDir = -1;
      }
      if ((abs(xOrient)==1)&&(joy3==this)&&((KastVersie==3)?(stick.getButton(RechtsToetsen[0]).pressed()):((key == '3')))) {
        joy3.xDir = 1;
      }
      if ((abs(xOrient)==1)&&(joy3==this)&&((KastVersie==3)?(stick.getButton(PlusToetsen[0]).pressed()):((key == '4')))) {
        w = (110*abs(xOrient))+10;
      }
      if ((abs(xOrient)==1)&&(joy3==this)&&((KastVersie==3)?(stick.getButton(MinToetsen[0]).pressed()):((key == '5')))) {
        w = (50*abs(xOrient))+10;
      }
    }
    else {
      joy3.x = ball[0].x;
      joy3.xDir = 0;
    }

    if (HumanPlayer[1]) {
      joy4.yDir = 0;
      if ((abs(yOrient)==1)&&(joy4==this)&&((KastVersie==3)?(stick.getButton(LinksToetsen[1]).pressed()):((key == 'q')))) {
        joy4.yDir = 1;
      }
      if ((abs(yOrient)==1)&&(joy4==this)&&((KastVersie==3)?(stick.getButton(RechtsToetsen[1]).pressed()):((key == 'e')))) {
        joy4.yDir = -1;
      }
      if ((abs(yOrient)==1)&&(joy4==this)&&((KastVersie==3)?(stick.getButton(PlusToetsen[1]).pressed()):((key == 'r')))) {
        h = (110*abs(yOrient))+10;
      }
      if ((abs(yOrient)==1)&&(joy4==this)&&((KastVersie==3)?(stick.getButton(MinToetsen[1]).pressed()):((key == 't')))) {
        h = (50*abs(yOrient))+10;
      }
    }
    else {
      joy4.y = ball[0].y;
      joy4.yDir = 0;
    }
    
    if ((x < (w/2)) || (x > (width-(w/2)))) {
      xDir = 0;
      if (x < (w/2))
        x = w/2;
      if (x > (width-(w/2)))
        x = (width-(w/2));
    }

    if ((y < (h/2)) || (y > (height-(h/2)))) {
      yDir = 0;
      if (y < (h/2))
        y = h/2;
      if (y > (height-(h/2)))
        y = (height-(h/2));
    }
    
// Joystick moves here!

    x += (joySpeed * xDir);
    y += (joySpeed * yDir);
    
// Collision Detection here!

    for (int i=0;i<NumBalls;i++) {
      int temp = ball[i].r;
      if (abs(x - ball[i].x) * 2 < (w + temp) && 
        abs(y - ball[i].y) * 2 < (h + temp)) {
        if (!(collided[i])) {
          Score++;
          ball[i].Color = Color;
          if (abs(yOrient) == 1) {
            ball[i].xDir = -ball[i].xDir;
            ping.trigger();
          }
          if (abs(xOrient) == 1) {
            ball[i].yDir = -ball[i].yDir;
            ping.trigger();
          }

          collided[i] = true;
        }
      
      }
      else {
        collided[i] = false;
      }
    }
  }

  void Display() {
    rectMode(CENTER);
    fill(Color);
    rect(x,y,w,h);

    pushMatrix();
    translate(((width/2) - (((width-30)/2) * yOrient)),((height/2) - (((height-30)/2) * xOrient)));
    fill(255,255,255);
    textSize(20);
    textAlign(CENTER,CENTER);
    rotate(radians(PlayerAngle[PNaampje&3])); // ((abs(xOrient)) == 0)?(90 * yOrient):((abs(yOrient) == 0)?((90 * xOrient) + 90):0)));
    text(Naam[(PNaampje&3)],-50,0);
    text(Score,50,0);
    popMatrix();
    PNaampje++;
    PNaampje &= 3;
  }
  
}

int PNaampje = 2;

class Ball {
  int x,y,xSpeed,ySpeed;
  int xDir,yDir;
  int r;
  color Color = color(255,255,255);
  
  Ball(int tx, int ty, int txSpeed, int tySpeed, int txDir, int tyDir, color tColor) {
    x = tx;
    y = ty;
    xSpeed = txSpeed;
    ySpeed = tySpeed;
    xDir = txDir;
    yDir = tyDir;
    r = 5;
    Color = tColor;
  }
  
  void Update() {
    x += (xSpeed * xDir);
    y += (ySpeed * yDir);
    
    if (((x-r) < 0) || ((x+r) > width)) {
      xDir = -xDir;
      if (Color == joy1.Color) {
        joy1.Score += 100;
        pong.trigger();
      }
      else
      if (Color == joy2.Color) {
        joy2.Score += 100;
        pong.trigger();
      }
      else
      if (Color == joy3.Color) {
        joy3.Score += 100;
        pong.trigger();
      }
      else
      if (Color == joy4.Color) {
        joy4.Score += 100;
        pong.trigger();
      }
      else
      {
        fill(255);
        text("Smashed out!", width/2,height/2);
        uit.trigger();
      }
    }
    if (((y-r) < 0) || ((y+r) > height)) {
      yDir = -yDir;
      if (Color == joy1.Color) {
        joy1.Score += 100;
        pong.trigger();
      }
      else
      if (Color == joy2.Color) {
        joy2.Score += 100;
        pong.trigger();
      }
      else
      if (Color == joy3.Color) {
        joy3.Score += 100;
        pong.trigger();
      }
      else
      if (Color == joy4.Color) {
        joy4.Score += 100;
        pong.trigger();
      }
      else
      {
        fill(255);
        text("Smashed out!", width/2,height/2);
        uit.trigger();
      }
    }
  }
  
  void Display() {
    rectMode(CENTER);
    fill(Color);
    rect(x,y,2*r,2*r);
  }

}

int ScoreLijst[] = {100,90,80,70,60,50,40,30};
String NaamLijst[] = {"William_S.","Bas_______","_Arijan B_","_Edwin 13_","Michel t B","_Janru K._","Henri_____","Willeke___"};
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

int LinksToetsen[] = {0,5,10,15};
int VuurKnoppen[] = {1,6,11,16};
int RechtsToetsen[] = {2,7,12,17};
int PlusToetsen[] = {3,8,13,18};
int MinToetsen[] = {4,9,14,19};

class Highscore {
  int Score = 0;
  int playerX = 0;
  int CursorX = 0;
  int CursorY = 0;
  int KarCount = 64;
  char Cursor = '_';
  char chars[] = {' ',' ',' ',' ',' ',' ',' ',' ',' ',' ',' '};

  boolean RepKey[] = {false,false,false,false,false};
  
  Highscore(int tScore, int tplayerX) {

   Score = tScore;
   playerX = tplayerX;
   CursorX = 0;
   CursorY = 0;
   KarCount = 0;
   Cursor = KarakterSet[KarCount];

   for (int i=0;i<NumKeysPerPlayer;i++) {
     RepKey[i] = XRepKeys[((NumKeysPerPlayer * playerX) + i)];
   }
   Once[playerX] = false;
   CollectedFireButtons[playerX] = false;
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
          ScoreLijst[j+1]=ScoreLijst[j];
          NaamLijst[j+1]=NaamLijst[j];
        }
        ScoreLijst[i]=Score;
        NaamLijst[i]=Naam[playerX];
        CursorY = i;
        for (int k=0;k<playerX;k++) {
          if ((Joys[k].Highscore != null)&&((CursorY) <= (Joys[k].Highscore.CursorY))) {
            Joys[k].Highscore.CursorY += 1;
          }
        }
        return; // early out, or continue; ??
      }
    }
    CursorY = 8; // force to 8 if way below the lowest highscore!
  }

 void Display() {
  int i;
  Joystick Joys[] = {joy3,joy4,joy1,joy2};
  
  Joys[0] = joy3;
  Joys[1] = joy4;
  Joys[2] = joy1;
  Joys[3] = joy2;
  for (i=0;i<8;i++) {
    pushMatrix();
    translate(((width/2)-(((width-320)/2)*(Joys[playerX].yOrient))),((height/2)-(((height-320)/2)*(Joys[playerX].xOrient))));
    rotate(radians(PlayerAngle[playerX]));

//    fill(255,255,255);
//    fill(((Joys[playerX].Highscore.CursorY) == i)?(Joys[playerX].Color):(color(255,255,255)));
    fill(((HumanPlayer[playerX] == true)&&(Joys[playerX].Highscore != null)&&((CursorY) == i))?(Joys[playerX].Color):(color(255,255,255)));

    textSize(20);
    textAlign(CENTER,CENTER);
    text(Order[i],-100,20*i);
    text(NaamLijst[i],0,20*i);
    text(ScoreLijst[i],100,20*i);
    popMatrix();
  }
 }

 void Update()
 {
  int      i,j,k;
  Joystick Joys[] = {joy3,joy4,joy1,joy2};

  Joys[0] = joy3;
  Joys[1] = joy4;
  Joys[2] = joy1;
  Joys[3] = joy2;
  if ((CursorY < 8)&&(Joys[playerX].Highscore != null)&&(HumanPlayer[playerX] == true)) {
   for (j=0;j<NumKeysPerPlayer;j++)
    {
     RepKey[j] = XRepKeys[((playerX * NumKeysPerPlayer) + j)];
    }

   playerX %= 4;
   chars = Naam[playerX].toCharArray();
   CursorX %= 10;
   Cursor = chars[CursorX];

   if ((KastVersie==3)?(stick.getButton(PlusToetsen[playerX]).pressed()):(key == 'r'))
     {
       if (!(RepKey[3])) {
         for (i=0;i<78;i++) {
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

   if ((KastVersie==3)?(stick.getButton(MinToetsen[playerX]).pressed()):(key == 't'))
     {
       if (!(RepKey[4])) {
         for (i=0;i<78;i++) {
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

   if ((KastVersie==3)?(stick.getButton(LinksToetsen[playerX]).pressed()):(key == 'q'))
     {
       if (!(RepKey[0])) {
         CursorX--;

         if (CursorX < 0)
           CursorX = 0;
         if (CursorX > 9)
           CursorX = 9;
         CursorX %= 10;

         Cursor = chars[CursorX];
         
         for (i=0;i<78;i++) {
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

   if ((KastVersie==3)?(stick.getButton(RechtsToetsen[playerX]).pressed()):(key == 'e'))
     {
       if (!(RepKey[2])) {
         CursorX++;

         if (CursorX < 0)
           CursorX = 0;
         if (CursorX > 9)
           CursorX = 9;
         CursorX %= 10;

         Cursor = chars[CursorX];

         for (i=0;i<78;i++) {
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

   if ((KastVersie==3)?(stick.getButton(VuurKnoppen[playerX]).pressed()):(key == 'w'))
     {
       if (!(RepKey[1])) {
         for (i=0;i<NumKeys;i++) {
           keysPressed[i]=0;
          }
         buttonPressed = false;
         CollectedFireButtons[playerX] = HumanPlayer[playerX];  // true;
         NumCollectedFireButtons = 0;

         for (j=0;j<4;j++) {
           NumCollectedFireButtons = ((CollectedFireButtons[j])?(NumCollectedFireButtons + 1):(NumCollectedFireButtons));
          }
         if (NumCollectedFireButtons == NumHumanPlayers) {
           resetGame = true;
          }
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

   for (k=0;k<NumKeysPerPlayer;k++)
    {
     XRepKeys[((NumKeysPerPlayer * playerX) + k)] = RepKey[k];
    }
  }

// Do strcpy(NaamLijst[CursorY],Naam[playerX]); here!
//   memcpy(NaamLijst[CursorY],Naam[playerX],10);
// This is your double buffering!

  chars = Naam[playerX].toCharArray();
  if (CursorY > 7) {
    if (!(Once[playerX])) {
      println(Naam[playerX],", you dropped off the highscorelist!");
      Once[playerX] = true;
    }
    else {
      Once[playerX] = false;
    }
  }
  else {
    NaamLijst[CursorY] = String.valueOf(chars);
  }
 }
}
