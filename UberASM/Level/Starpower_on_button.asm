;requested by ももも#6517 on discord

;which buttons being held down to check, place a 1 for 
;yes according to format 0 to ignore that button
!buttons = #%00110000
;either $17 or $15 or buttons held down
;$15 format
;byetUDLR
;b = A or B, y = X or Y, e = select, t = Start, U = up, D = down, L = Left, R = right
;$17 format
;axlr----
;a = A, x = X, l = L, r = R, - = unused
!button_ram = $17
!star_ram = $1490

main:
	LDA !button_ram
	AND !buttons
	BEQ .reset
	;store 2 otherwise the game will disable star every 4th frame
	LDA #$02
	STA !star_ram|!addr
	RTL
.reset
	STZ !star_ram|!addr
	RTL 