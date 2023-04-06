incsrc "uber_settings.asm"


init:
	LDA #$05
	STA !flag|!addr
	STZ !additional_ram|!addr
	RTL