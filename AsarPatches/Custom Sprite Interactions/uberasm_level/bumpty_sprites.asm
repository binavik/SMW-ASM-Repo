incsrc "uber_settings.asm"


init:
	LDA #$04
	STA !flag|!addr
	LDA #$00
	LDX #!sprite_slots-1
.reset_loop
	STA !additional_sprite_table,x
	DEX
	BPL .reset_loop
	RTL

main:
	LDX #!sprite_slots-1
.dec_loop
	LDA !additional_sprite_table,x
	BEQ .next
	DEC A
	STA !additional_sprite_table,x
.next
	DEX
	BPL .dec_loop
	RTL
	