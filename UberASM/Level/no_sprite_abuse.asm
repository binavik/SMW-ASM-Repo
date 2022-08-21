;checks if a sprite is dying, and if so also kills mario

main:
	LDX #!sprite_slots
.loop
	LDA !14C8,x
	BEQ .next
	CMP #$01
	BEQ .next
	CMP #$06
	BPL .next
	JSL $00F5B7|!bank
.next
	DEX
	BPL .loop
	RTL
	