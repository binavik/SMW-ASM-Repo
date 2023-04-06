incsrc "uber_settings.asm"


init:
	LDA #$01
	STA !flag|!addr
	LDA #!platform_settings
	STA !additional_ram|!addr
	RTL
