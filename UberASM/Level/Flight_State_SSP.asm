;from SSPDef\Defines.asm, must match !Freeram_SSP_EntrExtFlg
!inPipeFlag = $62		

;0 = no, 1 = yes
;this option conserves the takeoff_meter value when you enter the pipe
;if 0 it'll load whatever is in !takeoff_meter 
!conserve_takeoff_meter = 1

;only used if above is 0
!takeoff_meter = #$60

;2 bytes if !conserve_takeoff_meter is 1, 1 byte otherwise
;1st byte, flag for if we entered a pipe and should store the takeoff meter
;2nd byte, value of takeoff meter when first entering the pipe and what to restore when exiting the pipe
;This could theoretically be 1 byte but issues could arise when entering a pipe with 0 takeoff meter
!freeRAM = $1869|!addr	


init:
	STZ !freeRAM
	RTL
	
main:
	LDA !freeRAM
	BEQ .checkInPipe
	LDA !inPipeFlag
	BNE .return
if !conserve_takeoff_meter
	LDA !freeRAM+1
else
	LDA !takeoff_meter
endif
	STA $149F|!addr
	STZ !freeRAM
	RTL
.checkInPipe
	LDA !inPipeFlag
	BEQ .return
	CMP #$02
	BEQ .return
	INC !freeRAM
if !conserve_takeoff_meter
	LDA $149F|!addr
	STA !freeRAM+1	
endif
.return
	RTL