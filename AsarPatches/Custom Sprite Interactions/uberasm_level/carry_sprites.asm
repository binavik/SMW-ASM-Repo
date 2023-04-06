incsrc "uber_settings.asm"

init:
	LDA #$06
	STA !flag|!addr
	LDA #$FF
	STA !additional_ram|!addr
	LDA #$00
	LDX #!sprite_slots-1
.reset_loop
	STA !additional_sprite_table,x
	DEX
	BPL .reset_loop
	STA !additional_ram|!addr+1
	RTL

main:
	LDA !additional_ram|!addr+1
	BEQ +
	DEC !additional_ram|!addr+1
+
	LDA $1499|!addr
	BEQ +
	LDA #!turn_timer
	STA !additional_ram|!addr+1
+
	LDX #!sprite_slots-1
.dec_loop
	LDA !additional_sprite_table,x
	BEQ .next
	DEC A
	STA !additional_sprite_table,x
.next
	DEX
	BPL .dec_loop
	LDA $148F|!addr
	ORA $1470|!addr
	BNE .return
	LDA #$FF
	STA !additional_ram|!addr
.return
	RTL
	