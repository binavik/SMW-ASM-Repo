;from SSPDef\Defines.asm, must match !Freeram_SSP_EntrExtFlg
!inPipeFlag = $62		

;2 bytes
;1st byte, flag for if we entered a pipe and should store the takeoff meter
;2nd byte, value of takeoff meter when first entering the pipe and what to restore when exiting the pipe
;This could theoretically be 1 byte but issues could arise when entering a pipe with 0 takeoff meter
!freeRAM = $1869|!addr	


init:
	STZ !freeRAM
	STZ !freeRAM+1
	RTL
	
main:
	LDA !freeRAM
	BEQ .checkInPipe
	LDA !inPipeFlag
	BNE .return
	LDA !freeRAM+1
	STA $149F|!addr
	STZ !freeRAM
	RTL
.checkInPipe
	LDA !inPipeFlag
	BEQ .return
	CMP #$02
	BEQ .return
	INC !freeRAM
	LDA $149F|!addr
	STA !freeRAM+1	
.return
	RTL