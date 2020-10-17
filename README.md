# Arcade-4-Player-Pong

This is a first attempt to whatever software I am publishing.

It is supposed to be an Arcade version of a 4-player pong game, pong look alike game.

Download and install the latest version of Processing first at https://www.processing.org

Startup your Processing IDE and add the minim library and the gamecontrolplus library.

Load the pde-file into the editor. Then hit the arrow- or run-button.

Or execute at the commandline:

sudo processing-java --sketch="path where your source or pde-file is stored" --run

skip the sudo command if you are executing from within MS-Windows.

If it fails, it will show you a device list. Check the device number or device name of your keyboard, it shows on the left.
If you have a gamecontroller, which should have at least 20 keys, use that devicenumber or device name, otherwise use the keyboard.
Fill in the device number or device name in the source code, which is very important! Next, try to execute or run it again.
It should work this time...

It will be easiest if you change the devicename "Arduino Leonardo" into your particular devicename and leave KastVersie with the value 3.

Always try to maintain the following directory-structure:

FourPlayerPong/

FourPlayerPong/data

Put the pde-file in map FourPlayerPong and create your data directory there also. Next, put your mp3-files in the data-map.

Thank You!
