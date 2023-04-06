incsrc "uber_settings.asm"


init:
	LDA #$02
	STA !flag|!addr
	RTL
