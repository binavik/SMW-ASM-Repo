Kick_Speed_X:
	db $D2, $2E, $CC, $34 ;last 2 are for riding on yoshi, probably not needed here


;speed the bumpty setting bounces you at
MarioSpeed:		db $40,$C0

;Gravity Notes
;platform sprites add additional gravity to Mario to keep him on the sprite
;The vanilla value is $10 but other sprites require a larger amount
;if you find that Mario is acting as if he's falling every other frame or so
;while on a sprite, then you'll need to add additional gravity for that sprite.
;If you don't know whether or not you need additional gravity, set the value to either 
;$10 or $FF. Same rules apply to custom and vanilla sprites.


Custom_Gravity_Table: 
;	    00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  0A,  0B,  0C,  0D,  0E,  0F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;00-0F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;10-1F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;20-2F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;30-3F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;40-4F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;50-5F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;60-6F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;70-7F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;80-8F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;90-9F
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;A0-AF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;B0-BF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;C0-CF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;D0-DF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;E0-EF
	db $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF	;F0-FF

;example below: $20 for green shellless koopa. If you compare that with any of the other
;shellless koopas, you'll notice the other ones show Mario falling randomly
Vanilla_Gravity_Table: 
;	    00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  0A,  0B,  0C,  0D,  0E,  0F
	db $20, $20, $20, $20, $20, $20, $20, $20, $35, $35, $35, $35, $35, $35, $20, $20	;00
	db $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35	;10
	db $35, $35, $35, $35, $35, $35, $35, $35, $80, $35, $35, $35, $35, $35, $35, $35	;20
	db $10, $35, $10, $35, $35, $35, $35, $35, $35, $35, $FF, $FF, $FF, $FF, $35, $35	;30
	db $35, $FF, $FF, $FF, $35, $35, $35, $35, $35, $FF, $35, $35, $35, $35, $35, $35	;40
	db $35, $35, $FF, $FF, $35, $FF, $FF, $FF, $FF, $FF, $35, $FF, $FF, $FF, $FF, $FF	;50
	db $FF, $35, $FF, $FF, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35	;60
	db $FF, $35, $35, $35, $20, $35, $20, $10, $20, $35, $35, $35, $35, $35, $35, $35	;70
	db $FF, $35, $35, $FF, $FF, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $FF	;80
	db $35, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $FF, $35, $FF, $35, $FF, $35, $3A, $35	;90
	db $35, $35, $35, $FF, $35, $35, $10, $35, $35, $35, $35, $35, $35, $35, $35, $FF	;A0
	db $35, $FF, $35, $35, $40, $35, $35, $FF, $FF, $FF, $FF, $FF, $FF, $35, $40, $35	;B0
	db $FF, $FF, $35, $35, $35, $35, $35, $35, $FF, $35, $35, $35, $35, $35, $35, $35	;C0
	db $60, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35	;D0
	db $FF, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35	;E0
	db $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35, $35	;F0


;how much distance away from mario the sprite should be placed, change to taste
;if you notice a sprite is being released when you turn around or face a certain direction,
;change the x offset to bring that specific clipping value closer
;Y values should be positive or negative depending on if you want to shift the sprite down or up.
;all values are based on sprite <-> sprite clipping, $1662. Only the lower 6 bits are used
;
;Believe it or not this is much more preferable to 4 #$FF tables for all possible sprites and
;custom sprites. 

;1662 values AND #$3F: 3F
;	 00, 01, 02, 03, 04, 05, 06, 07, 08, 09, 0A, 0B, 0C, 0D, 0E, 0F
;	$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$0A,$00		;00
;	$00,$00,$08,$00,$00,$00,$00,$00,$00,$01,$01,$00,$00,$00,$01,$01		;10
;	$00,$00,$01,$01,$01,$01,$06,$00,$07,$06,$01,$00,$00,$00,$00,$00		;20
;	$37,$00,$37,$00,$00,$09,$01,$00,$00,$00,$0E,$0E,$0E,$00,$00,$00		;30
;	$00,$0F,$0F,$10,$14,$00,$0D,$00,$00,$1D,$00,$00,$00,$00,$00,$00		;40
;	$00,$00,$02,$0C,$03,$05,$04,$05,$04,$00,$00,$04,$05,$04,$05,$00		;50
;	$1D,$0C,$04,$04,$12,$20,$21,$2C,$34,$04,$04,$04,$04,$0C,$16,$00		;60
;	$17,$00,$00,$00,$00,$00,$00,$00,$00,$00,$00,$1E,$35,$00,$00,$00		;70
;	$0C,$00,$00,$0C,$0C,$00,$00,$3A,$08,$08,$00,$00,$00,$00,$1C,$08		;80
;	$38,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$0D,$00,$0D,$00,$1D,$00,$00,$36		;90
;	$24,$23,$3B,$1F,$22,$00,$27,$00,$00,$28,$00,$2A,$2B,$2B,$00,$00		;A0
;	$00,$0C,$00,$2D,$00,$00,$00,$2E,$2E,$0C,$1D,$2F,$0C,$00,$00,$30		;B0
;	$32,$31,$00,$00,$33,$07,$3F,$00,$0C									;C0

;how far the hitbox for the sprite should be shifted if mario is facing right
Clipping_X_Right_Offset:
;	    00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  0A,  0B,  0C,  0D,  0E,  0F
	db $09, $08, $FA, $FF, $00, $00, $0A, $03, $0B, $FF, $FF, $FF, $0A, $0E, $03, $09	;00
	db $07, $FF, $0E, $FF, $05, $FF, $0E, $07, $07, $07, $07, $07, $FF, $08, $FF, $FF	;10
	db $0C, $0C, $05, $0C, $FF, $FF, $FF, $07, $FF, $FF, $08, $07, $10, $07, $FF, $07	;20
	db $02, $06, $06, $08, $0F, $FF, $00, $0A, $00, $FF, $0A, $0A, $FF, $FF, $FF, $FF	;30

;how far the hitbox for the sprite should be shifted if mario is facing left
Clipping_X_Left_Offset:
;	    00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  0A,  0B,  0C,  0D,  0E,  0F
	db $F7, $F8, $E6, $FF, $E0, $C0, $F6, $D8, $F5, $FF, $FF, $FF, $F7, $F1, $ED, $DF	;00
	db $F9, $FF, $01, $FF, $EB, $FF, $F2, $F9, $F9, $F9, $F9, $F9, $FF, $E8, $FF, $FF	;10
	db $05, $04, $FC, $F4, $FF, $FF, $FF, $F9, $FF, $FF, $F8, $F9, $00, $F9, $FF, $E9	;20
	db $EE, $D5, $D5, $CC, $01, $FF, $D0, $F6, $DD, $FF, $F6, $F6, $FF, $FF, $FF, $FF	;30

;how far the hitbox for the sprite should be shifted if mario is facing forward
;eg. turned around, $1499 is set or the additional timer is set to help keep the sprite from falling
Clipping_X_Forward_Offset:
;	    00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  0A,  0B,  0C,  0D,  0E,  0F
	db $00, $00, $F0, $FF, $F0, $DE, $00, $EF, $00, $FF, $FF, $FF, $00, $00, $F8, $F4	;00
	db $00, $FF, $08, $FF, $F6, $FF, $00, $00, $00, $00, $00, $00, $FF, $F8, $FF, $FF	;10
	db $08, $08, $00, $00, $FF, $FF, $FF, $00, $FF, $FF, $00, $00, $08, $00, $FF, $F8	;20
	db $F9, $F0, $F0, $E8, $07, $FF, $E9, $00, $ED, $FF, $00, $00, $FF, $FF, $FF, $FF	;30

;same as the above but vertical
Clipping_Y_Offset_Table:
;	    00,  01,  02,  03,  04,  05,  06,  07,  08,  09,  0A,  0B,  0C,  0D,  0E,  0F
	db $0D, $06, $0D, $FF, $10, $11, $FF, $EC, $0F, $FF, $FF, $FF, $0B, $10, $02, $0E	;00
	db $00, $FF, $DA, $FF, $0E, $FF, $10, $C9, $C9, $C9, $C9, $C9, $FF, $0B, $FF, $FF	;10
	db $20, $FB, $0D, $12, $FF, $FF, $FF, $0C, $FF, $FF, $0F, $D0, $16, $11, $FF, $00	;20
	db $10, $0E, $0E, $12, $15, $FF, $E4, $0F, $EA, $FF, $08, $0F, $FF, $FF, $FF, $FF	;30



