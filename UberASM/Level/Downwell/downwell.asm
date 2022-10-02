; requires 2 bytes
!freeRAM = $1923

;0 = no, 1 = yes. This will determine if the status bar is drawn to or not
!Draw_shots = 1

;0 = no, 1 = yes. This will only shoot if Mario is falling
!only_shoot_while_falling = 0

;00 to start with A/B shot, 01 to start with L/R shot
!start_type = #$00

!number_of_shots = #$06
; for the fireball
!y_speed = #$5F				;from #$01-#$7F, closer to #$7F = faster
!x_offset = #$0004
!y_offset = #$0018

!extended_sprite = 11		;05 for mario fireball, 11 for yoshi fireball

!mario_push = #$F0

; vanilla fireball shoot sound, might need to change if using amk
!sfx = #$09
!sfx_bank = $1DFC

;YXPCCCTT, NOT THE SPRITE STUFF, for the shots tile
!tile_prop  = #$38
;select which tile you'd like to use, uses Layer 3 tiles
;some editing in YYCHR might be necessary
!tile_num = #$20
!blank_tile = #$FC

!A = #$0A
!B = #$0B
!L = #$15
!R = #$1B

;no touch
!header_byte_1 = #$50
!header_byte_2 = #$41
!header_byte_3 = #$00

!stripe_table = $7F837D
;end no touch

init:
	LDA !freeRAM+1
	BMI +
	LDA !start_type
	STA !freeRAM+1
+
	LDA !number_of_shots
	STA !freeRAM
	RTL

if !Draw_shots
DrawShots:
	LDA !freeRAM
	STA $00
	LDA !number_of_shots
	STA $01
;stripe image upload
	REP #$30
	LDA $7F837B
	TAX
	SEP #$20
	LDA !header_byte_1
	STA !stripe_table,x
	INX
	LDA !header_byte_2
	STA !stripe_table,x
	INX
	LDA !header_byte_3
	STA !stripe_table,x
	INX
;last byte = ((Total Shots + 3) * 2) - 1 to account for drawing the last space and either LR or AB
	LDA !number_of_shots
	CLC
	ADC #$03
	ASL
	DEC
	STA !stripe_table,x
	INX
.shots_loop
	LDA $00
	BEQ .blank_loop
	DEC $00
	DEC $01
	LDA !tile_num
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
	BRA .shots_loop
.blank_loop
	LDA $01
	BEQ .finished
	DEC $01
	LDA !blank_tile
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
	BRA .blank_loop
.finished
	LDA !blank_tile
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
	LDA !freeRAM+1
	AND #$01
	BNE .LR
	LDA !A
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
	LDA !B
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
	BRA .done
.LR
	LDA !L
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
	LDA !R
	STA !stripe_table,x
	INX
	LDA !tile_prop
	STA !stripe_table,x
	INX
.done
	LDA #$FF
	STA !stripe_table,x
	REP #$20
	TXA
	STA $7F837B
	SEP #$30
	STZ $24
.return
	RTS
endif

main:
	LDA $16
	AND #$20
	BEQ .no_swap
	LDA !freeRAM+1
	INC
	AND #$81
	STA !freeRAM+1
.no_swap
if !DrawShots
	JSR DrawShots
endif
	LDA $9D
	ORA $13D4|!addr
	BNE .return
	LDA $77
	AND #$04
	BNE .reset_shots
	LDA !freeRAM+1
	AND #$01
	BEQ .AB
	LDA $18
	AND #%00110000
	BRA .check_shots
.AB
	LDA $16
	ORA $18
	AND #%10000000
.check_shots
	BEQ .return
	LDA !freeRAM	;no remaining shots, no shooting
	BEQ .return
	LDA $74			;don't shoot while climbing.
	BNE .return
if !only_shoot_while_falling
	LDA $7D
	BMI .return
if !extended_sprite == 05
	LDX #$0A
else
	LDX #$08
endif
.loop
	LDA $170B,x
	BEQ .found
	DEX 
	BPL .loop
	RTL
.found
	DEC !freeRAM
	LDA !sfx
	STA !sfx_bank
	LDA #$!extended_sprite
	STA $170B,x
	LDA !y_speed
	STA $173D,x
	STZ $1747,x
	REP #$30
	LDA $94
	CLC
	ADC !x_offset
	STA $02
	LDA $96
	CLC
	ADC !y_offset
	STA $00
	SEP #$30
	LDA $02
	STA $171F,x
	LDA $03
	STA $1733,x
	LDA $00
	STA $1715,x
	LDA $01
	STA $1729,x
	LDA !mario_push
	STA $7D
	RTL
.reset_shots
	LDA !freeRAM            ;how many shots you have
	CMP !number_of_shots    ;max shots
	BEQ .no_sound           ;if how many you have left - max shots == 0, you have not used any shots so don't play any sound
	LDA #$10                ;otherwise it will play sounds because you've used something
	STA $1DF9
.no_sound
	LDA !number_of_shots
	STA !freeRAM
	RTL

.return
	RTL
	
