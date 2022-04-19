;uses Extra Bit: yes
;extra bit clear = vanilla sprite
;extra bit set = custom sprite

;uses Extra Bytes: yes, 8 with extra bit clear, 12 with extra bit set.
;Extra Byte 1: SCDM EYXd
;Unless otherwise noted: 0 = no, 1 = yes
;d: Draw graphic
;X: follow Mario horizontally
;Y: follow Mario Vertically
;E: Spawned sprite extra bit.
;M: Draw meter
;D: Don't despawn offscreen
;C: Shoot on coins 
;S: Single shot, only shoot a new sprite when the old one despawns. 

;Extra Byte 2: Frequency, how often to fire the sprite
;Extra Byte 3: what sprite number to spawn

;Some sprites do not call the update position routine, this sprite can if 
;bit 7 from Extra Byte 1 is set. Please note that enabling Gravity will
;enable it for both the X and Y direction and checks for block interactions
;Extra Byte 4: initial state, follows $14C8 settings and additional toggles:
;format: GxyS ****
;**** value for $14C8, it only uses the lower 4 bits so the higher 4 bits can be used for additional functionality
;G = apply position update with gravity
;x = force move in x direction
;y = force move in y direction
;S = only work with a switch active, default on/off switch
;Extra Byte 5: Initial x speed for new sprite
;Extra Byte 6: Initial y speed for new sprite

;Direction follows normal speed rules
;00-7F are Right/Down
;80-FF are Left/Up
;Extra Byte 7: X distance from Mario. Only used when Byte 1 bit 1 is set
;Extra Byte 8: Y distance from Mario. Only used when Byte 1 bit 2 is set

;Extra Bytes 9-12: Only when extra bit is set, extra bytes for spawned custom sprite

;in the event you want to change what tile the graphics pull from
!tile = #$64
!tile_prop = #$35
;or if you want to change the sound.
!SoundEffect = $09
!SFXPort = $1DFC|!Base2

!MeterSize = #$02
!MeterXOffset = #$F8
!MeterYOffset = #$F8

;You can change this to a free ram value if you have coins disabled
!coins 		  = $0DBF|!Base2
;You can also change this to be a different flag
!switch		  = $14AF|!Base2

;don't touch these
!timerRAM     = !163E
!settings1  = !1504
!frequency  = !1510
!spawn_sprite  = !151C
!settings2_and_state  = !1528
!x_speed  = !B6
!y_speed  = !AA
!x_offset  = !1602
!y_offset  = !160E
!spawned_sprite_backup  = !1626
!extrabyte_1 = !187B
!extrabyte_2 = !1570
!extrabyte_3 = !15F6
!extrabyte_4 = !1594


print "INIT ",pc
	;all of this just to set up extra bytes for easier access
	LDA !extra_byte_1,x
	STA $00
	LDA !extra_byte_2,x
	STA $01
	LDA !extra_byte_3,x
	STA $02
	LDY #$00
	LDA [$00],y
	STA !settings1,x
	INY
	LDA [$00],y
	STA !frequency,x
	STA !timerRAM,x
	INY
	LDA [$00],y
	STA !spawn_sprite,x
	INY
	LDA [$00],y
	STA !settings2_and_state,x
	INY
	LDA [$00],y
	STA !x_speed,x
	INY
	LDA [$00],y
	STA !y_speed,x
	INY
	LDA [$00],y
	STA !x_offset,x
	INY
	LDA [$00],y
	STA !y_offset,x
	INY 
	LDA [$00],y
	STA !extrabyte_1,x 
	INY
	LDA [$00],y 
	STA !extrabyte_2,x
	INY
	LDA [$00],y
	STA !extrabyte_3,x
	INY
	LDA [$00],y
	STA !extrabyte_4,x
	LDA !settings1,x		;\
	AND #$02				;| check to follow mario in X direction
	BEQ .no_follow_x		;/
	JSR MoveX
.no_follow_x
	LDA !settings1,x		;\ same as above but for the Y direction
	AND #$04				;|
	BEQ .no_follow_y		;/
	JSR MoveY
.no_follow_y
	LDA #$FF					
	STA !spawned_sprite_backup,x
	STZ !coins					
	STZ !switch
.finish_init
RTL
print "MAIN ",pc
	PHB : PHK : PLB
	JSR SpriteMain
	PLB
RTL
	
MoveX:
	STZ $01					;\
	LDA !x_offset,x		;| Get distance to move displace the sprite
	BPL +					;|
	DEC $01					;|
+							;|
	CLC						;| 
	ADC $D1					;| Set up distance to move it
	STA $00					;|
	LDA $01					;|
	ADC $D2					;|
	STA $01					;|
	LDA $00					;|
	STA !E4,x				;| add to 
	LDA $01					;|
	STA !14E0,x				;/
	RTS
	
;same as above but for Y
MoveY:
	STZ $01					
	LDA !y_offset,x		
	BPL +
	DEC $01
+
	CLC
	ADC $D3
	STA $00
	LDA $01
	ADC $D4
	STA $01
	LDA $00
	STA !D8,x
	LDA $01
	STA !14D4,x
	RTS
	
CheckAlive:
	LDY !spawned_sprite_backup,x	;\ check ram if sprite slot is set from
	BMI .not_alive					;| previous spawn
	LDA !14C8,y						;|
	BEQ .not_alive					;| 14C8 = #$00, open slot, we can fire 
	CMP #$01						;| 14C8 = #$01, just spawning, don't fire
	BEQ .alive						;|
	;LDA !14C8,y						;|
	CMP #$08						;| 14C8 < #$08, dead, go ahead and fire.
	BCC .not_alive					;|
.alive								;|
	LDA !settings2_and_state,x		;|
	AND #$80						;|
	BEQ .check_x					;|
	PHX
	TYX
	JSL $01802A						;| update x and y with gravity
	PLX
.check_x							;|
	LDA !settings2_and_state,x		;|
	AND #$40						;|
	BEQ .check_y					;|
	PHX
	TYX
	JSL $018022						;| update x without gravity + object interaction
	PLX
.check_y							;|
	LDA !settings2_and_state,x		;|
	AND #$20						;|
	BEQ .finished					;|
	PHX
	TYX
	JSL $01801A						;| update y withough gravity + object interaction
	PLX
.finished							;|
	SEC								;|
	RTS								;|
.not_alive							;|
	LDA #$FF						;|
	STA !spawned_sprite_backup,x	;|
	CLC								;|
	RTS								;/

SpriteMain:
	LDA !settings1,x		;\ check if sprite should be despawned offscreen
	AND #$20				;| sometimes doesn't respawn when mario dies by
	BNE .no_SubOffScreen	;| falling into a pit.
	LDA #$00				;|
	%SubOffScreen()			;/
.no_SubOffScreen
	LDA !settings1,x		;\ check if we should draw graphic
	AND #$01				;| 
	BEQ .no_graphics		;|
	JSR Graphics			;/
.no_graphics
	LDA $9D					;\ Don't do anything if sprites are locked
	ORA $13D4|!Base2		;|
	BEQ .continue			;/
	RTS
.continue
	JSL $019138				; interact with objects
	LDA !timerRAM,x
	INC 
	STA $0F
	LDA !settings1,x		;\
	AND #$02				;| check to follow mario in X direction
	BEQ .no_follow_x		;/
	JSR MoveX
.no_follow_x
	LDA !settings1,x		;\ same as above but for the Y direction
	AND #$04				;|
	BEQ .no_follow_y		;/
	JSR MoveY
.no_follow_y
	LDA !settings2_and_state,x	;\ check the active on switch state setting
	AND #$10					;| 
	BEQ .check_coins			;|
	LDA !switch					;|
	BEQ .check_coins			;|
	INC !timerRAM,x				;| don't decrement timer if switch set
	RTS							;/ don't do anything else
.check_coins
	LDA !settings1,x		;\ check the shoot on coin toggle
	AND #$40				;|
	BEQ .continue_checks	;|
	LDA !coins				;|
	BNE .continue_checks	;|
	LDA !timerRAM,x			;| if timer was already incremented before
	CMP #$0F				;| don't do it again
	BEQ .continue_checks	;|
	INC !timerRAM,x			;/
.continue_checks
	LDA !settings1,x		;\ check if we should wait for the shot
	AND #$80				;| sprite to despawn before spawning another
	BEQ .final_check 		;|
	JSR CheckAlive			;|
	BCC .final_check		;|
	LDA !timerRAM,x			;| if timer was already incremented before
	CMP #$0F				;| don't do it again
	BEQ .final_check		;|
	INC !timerRAM,x			;/
.final_check
	LDA !timerRAM,x			;\ time to shoot yet? 
	BEQ Shoot				;/
Return:
	RTS
	
Shoot:
	LDA !7FAB10,x			;\ check extra bit for custom or normal sprite
	AND #$04				;|
	BNE .custom				;|
	LDA !spawn_sprite,x		;|
	CLC						;| CLC = normal sprite
	BRA .spawn				;/
.custom						;\
	LDA !spawn_sprite,x		;|
	SEC						;| SEC = custom sprite
.spawn						;|
	%SpawnSprite()			;/
	BCC +					; Carry clear = sprite is spawned
	JMP .return
+
	LDA !settings1,x			;\ backup the sprite if we need to
	AND #$80					;| 
	BEQ ++			 			;|
	TYA							;|
	STA !spawned_sprite_backup,x;/
++
	LDA #!SoundEffect		;\ Play sound effect
	STA !SFXPort|!Base2		;/	
	
	TYA
	STA !spawned_sprite_backup,x
	
	LDA !settings2_and_state,x		;\ initial state
	AND #$0F				;| only need lower 4 bits
	STA !14C8,y				;/
	
	;%SpawnSprite randomly fucks with settings when spawning a custom sprite with this
	;I have no idea why
	LDA !D8,x				;\ Initial Y position 
	STA !D8,y				;| Low byte
	LDA !14D4,x				;|
	STA !14D4,y				;| High byte
	LDA !E4,x				;| initial x position
	STA !E4,y				;| low byte
	LDA !14E0,x				;|
	STA !14E0,y				;| high byte
	LDA !x_speed,x			;| initial x speed
	STA !B6,y				;|
	LDA !y_speed,x			;| initial y speed
	STA !AA,y				;/

	LDA !7FAB10,x			;\ check extra bit for custom or normal sprite
	AND #$04				;|
	BEQ .finishSpawn		;/ 
	LDA !extrabyte_1,x		;\ can't do STA !extra_byte_1,y so need to swap registers
	PHA						;| backup what we can first
	LDA !extrabyte_2,x		;|
	PHA						;|
	LDA !extrabyte_3,x		;|
	PHA						;|
	LDA !extrabyte_4,x		;|
	PHA						;|
	TYX						;|
	PLA						;| 
	STA !extra_byte_4,x		;| 
	PLA						;|
	STA !extra_byte_3,x		;| 
	PLA						;|
	STA !extra_byte_2,x		;|
	PLA						;|
	STA !extra_byte_1,x		;/
	TXY
	LDX $15E9|!Base2
	LDA !settings1,x
	AND #$08
	BEQ .finishSpawn
	TYX
	LDA #$04
	ORA !7FAB10,x
	STA !7FAB10,x
	LDX $15E9|!Base2
.finishSpawn
	;Draw smoke
	STZ $00
	STZ $01
	LDA #$1B
	STA $02
	LDA #$01
	%SpawnSmoke()
	LDA !frequency,x
	STA !timerRAM,x
	LDA !settings1,x		;\ check the shoot on coin toggle
	AND #$40				;|
	BEQ .return				;|
	LDA !coins				;|
	BEQ .return				;| don't underflow
	DEC !coins				;/
.return
RTS

;very simple 1 tile graphic to draw.
Graphics:
	%GetDrawInfo()
	LDA $00
	STA $0300|!Base2,y
	LDA $01
	STA $0301|!Base2,y
	LDA !tile
	STA $0302|!Base2,y
	LDA !tile_prop		
	STA $0303|!Base2,y
	LDY #$02
	LDA #$00
	JSL $01B7B3|!BankB
	
	LDA !settings1,x
	AND #$10
	BEQ .no_draw_meter
	JSR DrawMeter
.no_draw_meter
	RTS
	
;Thanks to Fernap
DrawMeter:
	; compute (val / max) * (8 * size) = (val * size * 8) / max for the number of filled pixels in the meter
    lda !timerRAM,x
    sta $4202               ; mult A
    lda !MeterSize : asl #3
    sta $4203               ; mult B
    nop #4                  ; wait

    lda $4216               ; mult result low
    sta $4204               ; dividend low
    lda $4217               ; mult result high
    sta $4205               ; dividend high
    lda !frequency,x
    sta $4206               ; divisor
    nop #8                  ; wait

    lda $4214               ; quotient low
	
;------
; Graphics routine
;------

; $0d - number of pixels full left to draw
; $0f - tile loop counter

; passed number of full pixels to draw in A
SpriteGraphics:
  sta $0d                                               ; set up temp stuff
  lda !MeterSize : sta $0f

  stz $01                                               ; x offset + sprite x -> tile x
  lda !MeterXOffset
  bpl +
  dec $01
+:
  clc : adc !sprite_x_low,x : sta $00
  lda $01 : adc !sprite_x_high,x : sta $01

  stz $03                                              ; ditto y
  lda !MeterYOffset
  bpl +
  dec $03
+:
  clc : adc !sprite_y_low,x : sta $02
  lda $03 : adc !sprite_y_high,x : sta $03

  rep #$20
  lda $00 : sec : sbc $1a : sta $00                    ; and minus screen boundaries
  lda $02 : sec : sbc $1c : sta $02
  sep #$20

  lda !tile_prop
  sta $05

  lda !sprite_oam_index,x
  clc : adc #$04
  tax

  ldy #$09
  lda MeterTiles,y
  sta $04
  jsr DrawTile

.Loop:
  lda $00 : clc : adc #$08 : sta $00    ; if horizontal, add 8 to x
  lda $01 : adc #$00 : sta $01
++:
  lda $0f
  beq .EndLoop

; if pixels >= 8, use 8 as the tile index, subtract 8
; if pixels <= 8, use pixels as the tile index, set to 0
  lda $0d
  cmp #$08
  bcc +
  ldy #$08                  ; pixels >= 8
  sec : sbc #$08 : sta $0d
  bra ++
+:
  tay                       ; pixels < 8
  stz $0d
++:

  lda MeterTiles,y
  sta $04

  jsr DrawTile

  dec $0f
  bra .Loop

.EndLoop:

  lda $05 : eor #$40 : sta $05    ; if horizontal, flip x
  ldy #$09
  lda MeterTiles,y
  sta $04
  jsr DrawTile                    ; draw the last cap tile

  ldx $15e9|!addr
  rts
MeterTiles:
  db $00, $01, $02, $03, $04, $10, $11, $12, $13, $14

; $00-01 - x position
; $02-03 - y position
; $04 - tile num
; $05 - yxppccct
; X - oam offset, updated by call
DrawTile:
  rep #$20
  lda $00
  cmp.w #-7
  bmi .Return       ; if x < -7
  cmp.w #256
  bpl .Return       ; if x >= 256
  lda $02
  cmp.w #-7
  bmi .Return       ; if y < -7
  cmp.w #224
  bpl .Return       ; if x >= 224
  sep #$20

  lda $00 : sta $0300|!addr,x
  lda $02 : sta $0301|!addr,x
  lda $04 : sta $0302|!addr,x
  lda $05 : sta $0303|!addr,x

  txa : lsr #2 : tax
  lda $01 : and #$01 : sta $0460|!addr,x  ; 9th bit of x

  txa : inc : asl #2 : tax         ; next OAM slot

.Return:
  sep #$20
  rts
