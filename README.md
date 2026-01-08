## Arcade-4-Player-Pong

![Pong](./20230208-Pong.jpg)

This is supposed to be an Arcade version of a 4-player pong game, pong look alike game.

First download and install the latest version of Processing at https://www.processing.org

Startup your Processing IDE and click on Tools in the menu and select add tool or toolmanager, then click on libraries and add the minim library and the game control plus library.

Load the pde-file into the editor. Then hit the arrow- or run-button.

Or execute at the commandline:

processing cli --sketch="path where your source or pde-file is stored" --run

Standard keyboard is selected automatically when no other input device (Arduino Leonardo) is found.

In case you want to play with a standard keyboard and translate a keyrange differently, you should run KeyChecker before the game to find out which codes are generated for the keyrange you would like to use. The keyrange should always be in ascending order and is always depending on the lowest keycode, which should be put in variable called TranslationConstance. You do not need to change TranslationConstance anymore, just leave it 0.

Use keys 'a' till 't' in alphabetical order to control the game and the menues. This will only work if your gamewindow or gamescreen has the focus! So click the screen or window in which your game is running before trying any key...

If you own the kast, there's no need to change anything!

Be careful when using your com-ports for midi! You might consider disconnecting your midi-interface if you have one. This game uses a com-port to steer some lights belonging to the buttons that are pressed! It might not be of your interest, but it does a serial write at 115200 baud on the com-port as defined in the source. It actually writes an ascii string containing some parameters to your Arduino Uno if you have one.

Always try to maintain the following directory-structure:

FourPlayerPong/FPP

FourPlayerPong/FPP/data

FourPlayerPong/KeyChecker

Put the FPP.pde-file in map FourPlayerPong/FPP and create your data directory there also. Next, put your mp3-files in the data-map. Highscores are now saved in FourPlayerPong/FPP/data/highscores.csv !

KeyChecker.pde should be in map FourPlayerPong/KeyChecker.

Thank You!

# How to play

If the game starts, click the screen or window in which the game is running to give it the focus.

Use keys 'a' till 'e' for player 1...
Use keys 'f' till 'j' for player 2...
Use keys 'k' till 'o' for player 3...
Use keys 'p' till 't' for player 4...

Try to reach 30000 points as soon as possible, which can be accomplished by shooting (press 'b' to shoot when a ball is touching your bat.) an opponent. This will enable your power up and down. Use keys 'd' or 'e' to use them. 'd' will cost you 30000 points every time you use it, but leave you with a screenwide bat. 'e' will earn you 10000 points but leave you with a small bat. After some time the bat will return to its normal size. You can move your bat left ('a') or right ('c').
After you have reached 30000 points you should try catching as many white balls as possible, which will earn you 1000 points each. When the rotating counter in the middle of the screen goes below 2000, try shooting all your opponents, which will earn you 100000 points each and try to survive.

# Highscore

If you have a highscore, the game will recognise this, you may put your name (10 chars max) in the table.
Use keys 'a' and 'c' to move the virtual cursor left or right. Use keys 'd' or 'e' to increment or decrement the character under the virtual cursor. Once your entire name is complete, you can press fire ('e') to acknowledge the save of the highscorelist and reset the game.

Have fun!

Cheers,

William.
