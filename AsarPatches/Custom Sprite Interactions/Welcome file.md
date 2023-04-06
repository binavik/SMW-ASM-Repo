# Custom Sprite Interactions

## About

This patch can enable up to 255 different interactions with the majority of SMW sprites and Mario. If a sprite uses the default interaction routine located at $01A7DC, they are more than likely affected by this patch with minor outliers. This hijacks the end of the routine, where contact between Mario and the sprite in slot X is confirmed and does something different based on the value set in !flag. !flag should be an address that is cleared on level load to keep the default interactions in other levels. Set the address in UberASM init.

## RAM Usage

- !flag must be a byte that is cleared on level load as to not have random behavior in game. 
- !additional_ram is used for multiple purposes. Some included interactions use it to change the behavior in minor ways. Others use it as a backup for the sprite that has made contact with Mario. Others still use it as a timer. Specific uses will be discussed in later sections.
- !additional_sprite_table, a contiguous chunk of ram that is either #\$0C or #\$22 bytes long based on if the ROM is LOROM or SA-1.

## Adding Interactions

There are 2 labels in the main patch were all the pointers are located, Pointers: and PointerEnd:. Simply add an additional label to jump to your own interaction. The number of pointers is calculated automatically by ASAR. After you've written your interaction routine, you can set the !flag in UberaASM init to the value of your new interaction.

## Included Interactions
Please be aware that these are included by default. If you have added or removed interactions, the values will not match.
- 00, dw Vanilla_Interact. All sprites will behave normally, the default.
- 01, dw Platform_Start. All sprite hitboxes are treated as platforms the player can stand on. By default, the platforms will be solid from all sides. To make them behave as semi-solid platforms, you will need to set the 0th bit of !additional_ram.
- 02, dw Spin_Jump. Spin jumping on sprites will cause the player to bounce off of them, as if all sprites were spineys.
- 03, dw Normal_Jump. All sprites will use the default interaction routine. Note that this is a dangerous setting, sometimes you will just get a normal bounce, sometimes you'll get a random sprite to spawn, sometimes you'll get more sprites to spawn, sometimes the game crashes. You have been warned.
- 04, dw Bumpty. All sprites will bounce you around as if they were a Bumpty. All credit go to Romi for the Bumpty sprite on SMWCentral.net
- 05, dw Water. All sprite hitboxes are areas where the player can swim. !additional_ram is used as a timer here to keep the game from automatically kicking mario out of the swimming state.
- 06, dw Carry. Mario can carry any sprite. Values have been set for the various clipping values in the game. These values should keep the sprite in the player's hands unless additional leeway was required for the sprite to interact with objects, think Chargin' Chucks breaking turn blocks. You are free to edit the offset values if you don't like the way a certain sprite is placed, but be warned that the sprite may fall out of the players hands if you offset it by too much. Sprite clipping values are noted before the tables. 
- 07, dw Nets. Sprite hitboxes are climbable areas. 

# How to use

 1. Make a backup of your ROM
 2. Make a backup of that backup.
 3. Put the files custom_sprite_interact.asm, sa1def.asm, settings.asm and tables.asm in the same directory, then patch custom_sprite_interact.asm into your ROM with ASAR.
 4. Either use one of the included files in the uberasm_level folder for whichever setting you want to apply in your levels, or make your own UberASM.

## Issues

Feel free to open an issue on github if you run into any problems. Specific setups or a video of the problem would help in coming up with a solution. You may also contact me on Discord, binavik#6554.

