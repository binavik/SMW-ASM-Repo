;checks if a sprite is dying, and if so also kills mario

;0 for hurt, 1 for kill
!kill = 1

init:
	STZ $18D2|!addr
	RTL

kill:
if !kill == 0
	JSL $00F5B7|!bank
else
	JSL $00F606|!bank
endif
	
	RTL

main:
	LDX #!sprite_slots-1
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
	