;checks if a sprite is dying, and if so also kills mario

init:
	STZ $18D2|!addr
	RTL

kill:
	JSL $00F5B7|!bank
	RTL

main:
	LDX #!sprite_slots
	LDA $18D2|!addr
	BNE kill
.loop
	LDA !14C8,x
	BEQ .next
	CMP #$01
	BEQ .next
	CMP #$06
	BPL .next
	BRA kill
.next
	DEX
	BPL .loop
	RTL
	