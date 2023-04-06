incsrc "uber_settings.asm"


!sprite_climb_flag = $18BE

init:
	LDA #$07
	STA !flag|!addr
	LDA #$FF
	STA !additional_ram|!addr
	LDA #$00
	LDX #!sprite_slots-1
.reset_loop
	STA !additional_sprite_table,x
	DEX
	BPL .reset_loop
	RTL
	
main:
	LDY #$00
	LDX #!sprite_slots-1
.loop
	LDA !additional_sprite_table,x
	BEQ .next
	DEC A
	STA !additional_sprite_table,x
	INY
.next
	DEX
	BPL .loop
	TYA
	BNE +
	STZ $18BE|!addr
	LDA #$FF
	STA !additional_ram|!addr
+
	RTL
	
	