# Arcade-4-Player-Pong

This is a first attempt to whatever software I am publishing.

It is supposed to be an Arcade version of a 4-player pong game, pong look alike game.

First download and install the latest version of Processing at https://www.processing.org

Startup your Processing IDE and click on Tools in the menu and select add tool or toolmanager, then click on libraries and add the minim library and the game control plus library.

Load the pde-file into the editor. Then hit the arrow- or run-button.

Or execute at the commandline:

sudo processing-java --sketch="path where your source or pde-file is stored" --run

skip the sudo command if you are executing from within MS-Windows or on macosx.

If it fails, it will show you a device list. Check the device number or device name of your keyboard, it shows on the left.
If you have a gamecontroller, which should have at least 5, 10, 15 or 20 keys, use that devicenumber or device name, otherwise use the keyboard. In case you have less than 20 keys available, use 5, 10 or 15 as the number of keys you have on your device. Please adjust the variable called NumKeys accordingly.
Fill in the device number (no double-quotes!) or device name (in double-quotes!), and the number of keys, in the source code. Next, try to execute or run it again.
It should work this time...

It will be easiest if you change the devicename "Arduino Leonardo" into your particular devicename.

In case you want to play with a standard keyboard and translate a keyrange differently, you should run KeyChecker before the game to find out which codes are generated for the keyrange you would like to use. The keyrange should always be in ascending order and is always depending on the lowest keycode, which should be put in variable called TranslationConstance. Example: run KeyChecker and find the lowest keycode of the keyrange you want to use. Let's say you want to use keyrange 1 to 0. Just press the key which carries the sign '1' and remember the code it generates. Next, unload KeyChecker.pde and load the game FPP.pde. Change the variable called TranslationConstance and set it to the code you were trying to remember and you're set to go. Set to 1 for windows and linux. Set to 11 for macosx and use keys 'a' till 't' in alphabetical order. If you own the kast, there's no need to change anything!

Be carefull when using your com-ports for midi! Be selective about what ports you use for midi. You might consider disconnecting your midi-interface if you have one. This game uses a com-port to stear some lights belonging to the buttons that are pressed! It might not be of your interest, but it does a serial write at 9600 baud on the com-port as defined in the source. It actually writes an ascii string containing some parameters as shown on the debug screen.

Always try to maintain the following directory-structure:

FourPlayerPong/FPP

FourPlayerPong/FPP/data

FourPlayerPong/KeyChecker

Put the FPP.pde-file in map FourPlayerPong/FPP and create your data directory there also. Next, put your mp3-files in the data-map. Highscores are now saved in FourPlayerPong/FPP/data/highscores.csv !

KeyChecker.pde should be in map FourPlayerPong/KeyChecker.

Thank You!
