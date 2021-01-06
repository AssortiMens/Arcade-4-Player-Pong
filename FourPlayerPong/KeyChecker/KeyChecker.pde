
import org.gamecontrolplus.*;

ControlIO control;
ControlDevice stick;

int NumKeys = 120; /* Maximum 120! */

void setup() {
  size(1024,768);
//  fullScreen();
  control = ControlIO.getInstance(this);
  try {
    println(control.deviceListToText(""));
    stick = control.getDevice("Arduino Leonardo");
  }
  catch (Exception e) {
    println("No Arduino found or no Toetsenbord/Keyboard configured!");
    System.exit(0);
  }
}

int KeyCode = 0;

void draw()
{
  background(0);
  for (int i=0;i<NumKeys;i++) {
    KeyCode = i;
    fill((stick.getButton(KeyCode).pressed())?(color(255,0,0)):(color(255,255,255)));
    textSize(18);
    text(i, (i/25)*100, ((i%25)*20)+50);
    text(((stick.getButton(KeyCode).pressed())?"true":"false"),((i/25)*100)+50, ((i%25)*20)+50);
  }
}
