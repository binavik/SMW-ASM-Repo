;2 bytes
!freeRAM = $1923|!addr

init:
	LDA #$FF
	STA !freeRAM
	RTL
	
main:
	LDA !freeRAM
	BPL .checkHolding
	LDX !SprSize-1
.loop
	LDA $14C8|!addr,x
	CMP #$0B
	BEQ .found
	DEX
	BPL .loop
	RTL
.found
	STX !freeRAM
	LDA $1686|!addr,x
	STA !freeRAM+1
.checkHolding
	LDX !freeRAM
	LDA $14C8|!addr,x
	CMP #$0B
	BEQ .disableInteract
	LDA !freeRAM+1
	STA $1686|!addr,x
	LDA #$FF
	STA !freeRAM
	RTL
.disableInteract
	LDA $1686|!addr,x
	ORA #%00001000
	STA $1686|!addr,x
.return
	RTL
	