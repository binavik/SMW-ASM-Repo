incsrc "uber_settings.asm"


init:
	LDA #$03
	STA !flag|!addr
	RTL
