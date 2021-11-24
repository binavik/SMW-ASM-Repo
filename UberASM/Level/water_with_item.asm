;holding any item will turn the level into a water level
;causing Mario to instantly begin item swimming

main:
	LDA $148F		;mario holding item flag
	ORA $1470		;other mario holding item flag
	STA $85			;water level flag
	RTL
