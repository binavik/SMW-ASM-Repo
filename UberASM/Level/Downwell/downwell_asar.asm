;used with the downwell uberasm to reset shots on contact with a sprite
;must match define in downwell.asm
!freeRAM = $1923
!number_of_shots = #$06

org $01A832
	autoclean JML ResetJumps
	NOP
	
freecode

ResetJumps:
;setting this address does nothing to other levels so should be fine to always do it 
	LDA !number_of_shots
	STA !freeRAM
	LDA !freeRAM+1
	BEQ .vanilla
;add your additional flags or modifiers here
	

.vanilla
;restore original code
	LDA.w $167A,x
	BPL .default_interact
	JML $01A835
.default_interact
	JML $01A83B

