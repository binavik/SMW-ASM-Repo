;Please check the readme
;;;;;;;;;;;;;;;;;Ram stuff;;;;;;;;;;;;;;;;;;;;;;;;;
if !SA1 == 0
	!additional_sprite_table = $7F828B	;12 bytes
else
	!additional_sprite_table = $406000	;22 bytes
endif
;1 byte, must be cleared on level load
!flag = $18BB
;2 additional bytes, any kind of free ram, must be consecutive
!additional_ram = $1487
;;;;;;;;;;;;;;;;;End Ram stuff;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;Water Settings;;;;;;;;;;;;;;;;;;;;
;how many frames to stay swimming after leaving a sprite hitbox
!water_frames = $08
;how high to boost up mario when the swim is almost over
!water_boost = $B0
;;;;;;;;;;;;;;;;;End Water Settings;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;Carry Settings;;;;;;;;;;;;;;;;;;;;
;how many frames to disable interaction after dropping/kicking a sprite
!disable_after_drop = $10
;how much higher up mario needs to be to normally interact with sprites
!mario_vertical_offset = $0011
!KickSFX = $03
!KickPort = $1DF9
;How much additional Y speed to give to the sprite, this is the vanilla value
;Note that sprites that update their y speed every frame will not be affected
;by this without additional work
!vertical_kick = $90

;;;;;;;;;;;;;;;;;End Carry Settings;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;Climb Settings;;;;;;;;;;;;;;;;;;;;
;how many frames to continue climbing for after mario has left a sprite's hitbox
!climbing_frames = $04
;Y-speed to give mario when jumping off "climbing"
!climb_jump = $B0
;;;;;;;;;;;;;;;;;End Climb Settings;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;Bumpty Settings;;;;;;;;;;;;;;;;;;;
;X-speed settings for bouncing can be found in tables.asm
;named MarioSpeed
;X-speed for Bumpty interaction
!BoingSFX = $08
!BoingPort = $1DFC
;;;;;;;;;;;;;;;;;End Bumpty Settings;;;;;;;;;;;;;;;

