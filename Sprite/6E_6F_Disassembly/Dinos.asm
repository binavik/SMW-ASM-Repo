

; first 2 for Dino Rhino, last 2 for Dino Torch
DinoSpeed: db $08, $F8, $10, $F0

!jump_height = #$C0

; how long to wait before spitting fire again
!fire_delay = #$40

; change these if you want the dino to play a different effect when it spits
; should be the same whether you use amk or not
!fire_sfx = #$17
!sfx_bank = $1DFC

print "INIT ",pc
	LDA #$04				;\ set initial graphics
	STA !151C,x				;/
	LDA #$FF				;\ set flame timer
	STA !1540,x				;/
	%SubHorzPos()			;\ 
	TYA						;| face mario
	STA !157C,x				;/
	RTL


;vanilla smw combines the main routine pointer for both the Dino and
;the invisible solid sprite block.... I'm just going to ignore the 2nd
print "MAIN ",pc
	PHB
	PHK
	PLB
	JSR DinoMain
	PLB
return:
	RTL

DinoMain:
	JSR Graphics
	LDA $9D					;\ leave if sprites are locked
	BNE .return				;|
	LDA !14C8,x				;| or status is anything other than normal
	CMP #$08				;|
	BNE .return				;/
	%SubOffScreen()
	JSL $01A7DC				;mario interaction
	JSL $01802A				;update position w/t gravity + block interaction
	LDA !C2,x	
	JSL $0086DF				;go to pointer based on state

	dw Grounded
	dw Spitting_Fire
	dw Spitting_Fire
	dw Airborne
	
.return
	RTS
	
; based on blocked status from left to right:
; not touching anything, right only, left only
; technically, a 4th value is possible if the dino is stuck inside a block
; in this case the commented value is used, uncomment to specify those yourself
x_lo_shift: db $00, $FE, $02		;, $00
x_hi_shift: db $00, $FF, $00		;, $B5

Airborne:
	LDA !AA,x				;\ branch if still moving up
	BMI in_air				;/
	STZ !C2,x				;\ reset state
	LDA !1588,x				;| branch if still in the air
	AND #$03				;| 
	BEQ in_air				;/
	LDA !157C,x				;\
	EOR #$01				;| otherwise flip direction
	STA !157C,x				;/
in_air:
	STZ !1602,x				;\ reset graphics frame
	LDA !1588,x				;| shift x position based on blocked status
	AND #$03				;|
	TAY						;|
	LDA !E4,x				;| 
	CLC						;|
	ADC x_lo_shift,y		;|
	STA !E4,x				;|
	LDA !14E0,x				;|
	ADC x_hi_shift,y		;| this will pull garbage if you can get it blocked from
	STA !14E0,x				;/ the left, right and below at once
	RTS


Grounded:
	LDA !1588,x				;\ checks if sprite is airborne
	AND #$04				;|
	BEQ in_air				;/
	LDA !1540,x				;\ check fire timer
	BNE .no_fire			;|
	LDA !9E,x				;| don't set if big dino
	CMP #$6E				;|
	BEQ .no_fire			;|
	LDA #$FF				;| set and change state
	STA !1540,x				;/
	JSL $01ACF9				;\ set state based on random number
	AND #$01				;| you might notice that the only 2 choices it can be jump to 
	INC A					;| the same code, well !C2 later determines if the small dino should
	STA !C2,x				;/ fire horizontally or vertically. 
.no_fire
	TXA						;\ semi randomly
	ASL #4					;| based on sprite slot
	ADC $14					;| and frame counter
	AND #$3F				;| 
	BNE .no_face			;| 
	%SubHorzPos()			;|
	TYA						;| face mario
	STA !157C,x				;/
.no_face
	LDA #$10				;\ baby bounce
	STA !AA,x				;/
	LDY !157C,x				;\ set speed based on direction
	LDA !9E,x				;|
	CMP #$6E				;| and which sprite we are
	BEQ .dino_rhino_speed	;| 
	INY #2					;|
.dino_rhino_speed			;|
	LDA DinoSpeed,y			;|
	STA !B6,x				;/
	JSR SetGraphicsFrame
	LDA !1588,x				;\ if not touching something from left/right/below
	AND #$03				;| 
	BEQ .Grounded_return	;| return
	LDA !jump_height		;| otherwise
	STA !AA,x				;| big jump
	LDA #$03				;| and change state
	STA !C2,x				;/
.Grounded_return
	RTS


DinoFlameTable:
	db $41,$42,$42,$32,$22,$12,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$02
	db $02,$02,$02,$02,$02,$02,$02,$12
	db $22,$32,$42,$42,$42,$42,$41,$41
	db $41,$43,$43,$33,$23,$13,$03,$03
	db $03,$03,$03,$03,$03,$03,$03,$03
	db $03,$03,$03,$03,$03,$03,$03,$13
	db $23,$33,$43,$43,$43,$43,$41,$41

Spitting_Fire:
	STZ !B6,x					;  stop moving	
	LDA !1540,x					;\ if not finished 
	BNE .still_spitting			;| keep spitting fire
	STZ !C2,x					;| otherwise change state
	LDA !fire_delay				;| and reset timer
	STA !1540,x					;| 
	LDA #$00					;/
.still_spitting				
	CMP #$C0					;\ only play the sfx for the first 3F frames
	BNE .no_sfx					;|
	LDY !fire_sfx				;|
	STY !sfx_bank				;/
.no_sfx
	LSR #3						;\ shoot horizontal or vertical based
	LDY !C2,x					;| on the randomly generated state from 
	CPY #$02					;| before
	BNE +						;|
	CLC							;|
	ADC #$20					;/
+
	TAY							;\ set gfx frame for spitting fire
	LDA DinoFlameTable,y		;| as well as clipping for the contact routine
	PHA 						;|
	AND #$0F					;|
	STA !1602,x					;/
	PLA 						;\ set direction
	LSR #4						;| 
	STA !151C,x					;| skip over hitbox if expanding/retracting 
	BNE .Spitting_Fire_return	;/
	LDA !9E,x					;\ 
	CMP #$6E					;| skip over hitbox if Dino Rhino
	BEQ .Spitting_Fire_return	;/
	TXA							;\ check for contact based on sprite slot
	EOR $13						;| and frame counter
	AND #$03					;| 
	BNE .Spitting_Fire_return	;/
	JSR DinoFlameClipping		;\ get flame clipping
	JSL $03B664					;| get mario clipping
	JSL $03B72B					;| check for contact
	BCC .Spitting_Fire_return	;| skip if no contact
	LDA $1490					;| or mario has star
	BNE .Spitting_Fire_return	;|
	JSL $00F5B7					;/ hurt otherwise
.Spitting_Fire_return
	RTS

DinoFlame1:
	db $DC,$02,$10,$02

DinoFlame2:
	db $FF,$00,$00,$00

DinoFlame3:
	db $24,$0C,$24,$0C

DinoFlame4:
	db $02,$DC,$02,$DC

DinoFlame5:
	db $00,$FF,$00,$FF

DinoFlame6:
	db $0C,$24,$0C,$24	


DinoFlameClipping:
	LDA !1602,x					;\ hitbox size determined by
	SEC							;| how long the dino has been 
	SBC #$02					;| spitting flames
	TAY							;|
	LDA !157C,x					;| and which direction it's 
	BNE .no_iny					;| currently facing
	INY #2						;|
.no_iny							;/
	LDA !E4,x
	CLC
	ADC DinoFlame1,y
	STA $04
	LDA !14E0,x
	ADC DinoFlame2,y
	STA $0A
	LDA DinoFlame3,y
	STA $06
	LDA !D8,x
	CLC
	ADC DinoFlame4,y
	STA $05
	LDA !14D4,x
	ADC DinoFlame5,y
	STA $0B
	LDA DinoFlame6,y
	STA $07
	RTS

SetGraphicsFrame:
	INC !1570,x
	LDA !1570,x
	AND #$08
	LSR #3
	STA !1602,x
	RTS

DinoTorchTileDispX:
	db $D8,$E0,$EC,$F8,$00,$FF,$FF,$FF
	db $FF,$00

DinoTorchTileDispY:
	db $00,$00,$00,$00,$00,$D8,$E0,$EC
	db $F8,$00

DinoFlameTiles:
	db $80,$82,$84,$86,$00,$88,$8A,$8C
	db $8E,$00

DinoTorchGfxProp:
	db $09,$05,$05,$05,$0F

DinoTorchTiles:
	db $EA,$AA,$C4,$C6

DinoRhinoTileDispX:
	db $F8,$08,$F8,$08,$08,$F8,$08,$F8

DinoRhinoGfxProp:
	db $2F,$2F,$2F,$2F,$6F,$6F,$6F,$6F

DinoRhinoTileDispY:
	db $F0,$F0,$00,$00

DinoRhinoTiles:
	db $C0,$C2,$E4,$E6,$C0,$C2,$E0,$E2
	db $C8,$CA,$E8,$E2,$CC,$CE,$EC,$EE

;ok here we go
Graphics:
	%GetDrawInfo()
	LDA !157C,x		;store sprite direction
	STA $02
	LDA !1602,x		;and graphics frame
	STA $04
	LDA !9E,x		;branch if we're the dino torch
	CMP #$6F
	BEQ .dino_torch
	PHX				;preserve sprite slot
	LDX #$03		;set up loop to draw 4 tiles
.Dino_Rhino_loop
	STX $0F
	LDA $02			;\shift which tiles to load based on direction
	CMP #$01		;|
	BCS +			;|
	TXA				;|
	CLC				;|
	ADC #$04		;|
	TAX				;/
+
	LDA DinoRhinoGfxProp,x
	STA $0303,y
	LDA DinoRhinoTileDispX,x	;\ set up and store x position of current tile
	CLC							;|
	ADC $00						;|
	STA $0300,y					;/
	LDA $04						;\ check the graphics frame but don't do anything with it
	CMP #$01					;/ why is this? 
	LDX $0F						;\ set up and store y position of current tile
	LDA DinoRhinoTileDispY,x	;|
	ADC $01						;|
	STA $0301,y					;/
	LDA $04						;\ load tile based on graphics frame
	ASL #2						;|
	ADC $0F						;|
	TAX							;|
	LDA DinoRhinoTiles,x		;|
	STA $0302,y					;/
	INY #4						; next oam slot
	LDX $0F						;\ 
	DEX							;| continue if not already done
	BPL .Dino_Rhino_loop		;/
	PLX							;restore sprite slot
	LDA #$03					;\ draw 4
	LDY #$02					;| 16x16 tiles
	JSL $01B7B3					;/
	RTS

.dino_torch
	LDA !151C,x					; store flame clipping
	STA $03
	LDA !1602,x					; and graphics frame
	STA $04						; which we did earlier
	PHX							; preserve sprite slot
	LDA $14
	AND #$02					;\ toggle flame properties 
	ASL #5						;| every 3 frames
	LDX $04						;|
	CPX #$03					;|
	BEQ +						;|
	ASL							;|
+								;|
	STA $05						;/
	LDX #$04					;set up loop to draw up to 5 tiles
.torch_dino_loop
	STX $06
	LDA $04						;\ a copy of 1602 is stored in 04
	CMP #$03					;| this value swaps between 0 and 1 every 8 frames during the normal movement routine
	BNE +						;|
	TXA							;| it's only not 0 or 1 when the dino torch is spitting fire
	CLC							;|
	ADC #$05					;|
	TAX							;|
+								;|
	PHX							;/
	LDA DinoTorchTileDispX,x
	LDX $02
	BNE ++
	EOR #$FF
	INC A
++
	PLX
	CLC 
	ADC $00
	STA $0300,y
	LDA DinoTorchTileDispY,x
	CLC
	ADC $01
	STA $0301,y
	LDA $06
	CMP #$04
	BNE +++
	LDX $04
	LDA DinoTorchTiles,x
	BRA ++++
+++
	LDA DinoFlameTiles,x
++++
	STA $0302,y
	LDA #$00
	LDX $02
	BNE +
	ORA #$40
+
	LDX $06
	CPX #$04
	BEQ ++
	EOR $05
++
	ORA DinoTorchGfxProp,x
	ORA $64
	STA $0303,y
	INY #4
	DEX
	CPX $03
	BPL .torch_dino_loop
	PLX
	LDY !151C,x
	LDA DinoTilesWritten,y
	LDY #$02
	JSL $01B7B3
	RTS

DinoTilesWritten:
	db $04, $03, $02, $01, $00