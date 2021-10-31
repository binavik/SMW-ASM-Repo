;this makes the spike act as setting instant kill mario regardless of powerup state.
;this also makes the spike act as, the instant kill setting, available in all graphics sets
;little testing was done, use at your own risk

org $00F152
	LDX #$42
	
org $00F159
	autoclean JSL CheckInstant
	
freecode

CheckInstant:
	CPX #$42
	BEQ .killMario
	JSL $00F5B7
	RTL
.killMario
	JSL $00F606
	RTL