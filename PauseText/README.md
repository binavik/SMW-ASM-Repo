# PauseText


This code adds additional message boxes to Super Mario World levels. It currently differentiates messages using the currently playing song. 

## Inserting

- Copy all the files in the library folder to your UberASMTool's library folder. 
- Copy the GM14.asm file from the gamemode folder to your UberASMTool's gamemode folder.
- In your UberASMTool's list.txt, under the gamemode section add 
```
14  GM14.asm
```
Finally run UberASMTool.exe


Please note that if you already have something taking up your gamemode 14 slot you will need to combine the code. The included GM14.asm file provides space at the bottom for copying any additional code into.

## Optional GFX2A.bin

In Super Mario World, layer 3 tiles for message boxes are stored in GFX2A.bin in 2BPP GB format. Vanilla SMW does not included tiles for 8 and 9 so I included an optional replacement gfx file which overwrites part of the yoshi paw for the 2 missing numbers. Only insert this gfx file if you do not care for the yoshi paw and want the 8 and 9 tiles without the blue border. If you prefer the numbers with the blue border there is no need to change anything. 

## library\Text.asm

This file contains all of the configuration options and messages. Any option that you shouldn't change, unless you know what you're doing, is documented in the file. 


## Known issues

- If you have a different bit of code that disables layer 3 the box from this will show up but the message will not. 
- Pausing the game while moving sometimes causes the text to not appear


## To Do
In no particular order:
- Fix message not showing while moving
- Make this overworld compatible
