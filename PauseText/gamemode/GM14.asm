;gamemode 14.

main:
	LDA $13D4|!addr
	BEQ .next
	JSL PauseMessage_Paused
.next
	;if you have more GM14 code, you can place it here
	RTL