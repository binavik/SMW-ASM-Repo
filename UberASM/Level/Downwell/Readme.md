# Downwell.asm

This Uberasm attempts to recreate the gimmick from the game [Downwell](http://handlebarsjs.com/https://store.steampowered.com/app/360740/Downwell/). 

The asar patch is only required if you also want your shots to be reset upon bouncing on most sprites. It hijacks the end of the vanilla contact routine and sets the free ram address to the value specified in the file, whether the interaction ultimately kills Mario or not. Other flags can be set here as you see fit.

Basic settings are defined at the top and are easily configurable.
