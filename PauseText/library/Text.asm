;Stripe image format header, see https://www.smwcentral.net/?p=viewthread&t=14531
;for more details and see https://jsfiddle.net/ankougo/vgkb8f3m/embedded/result/
;for a tool to simplify creating the header. Shout outs to Thomas for the tool.

!headerByte1 = #$50
!headerBottomByte1 = #$51
!headerTopByte2 = #$C3
!headerMiddleByte2 = #$E3
!headerBottomByte2 = #$03
!headerByte3 = #$00
!headerByte4 = #$33

;don't touch
!stripeTable = $7F837D

!HDMAChannel = 7

;Tile properties YXPCCCTT format
;Y = Y flip
;X = X flip
;P = Priority 
;CCC = Palette number
;TT = Graphics page number
;Must be a total of 8 digits
;You typically only want to change the CCC for which palette it will use
!tileProp = #%00111001	

;0 = no, 1 = yes
;choose if the box won't be drawn until player presses L/R
!manualBox = 1

;only need this as flag for drawing box or not, 1 byte, cleared on level load
if !manualBox
	!freeRAM = $18B7|!addr
endif

;0 = you are using the vanilla GFX2A file and want the blue numbers 0-9
;1 = you are using the included GFX2A file and do not care about the yoshi paw. 
!custom2A = 0

;Don't touch
if !custom2A
	table ascii_gfx.txt
else
	table ascii_blue.txt
endif

;don't touch these
boxWidths:
        db $04,$0A,$18,$22,$2C,$36,$40,$4A,$54,$5E,$68,$72,$7C,$86,$90,$9A,$A4,$AE,$B8,$C2,$CC,$D6,$E0
boxHeights:
        db $04,$06,$08,$0A,$0C,$0E,$10,$12,$14,$16,$18,$1A,$1C,$1E,$20,$22,$24,$2C,$28,$2A,$2C,$2E,$30
		
;if you end up changing the box and text location you'll need to update the first 2 bytes of this table
;to match where the first tile written is located
clearTilemap:
		db $50,$C3,$40,$B6,$FC,$38, $FF
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Example: This is the text that will show when press start
;in a level where the song is set to 35. Note that the lines 
;must be exactly 26 characters long, if you need to terminate 
;early use empty spaces. Any first line starting with db $FF 
;will skip writing anything. 
;
;Text35:
;		db "This will show on the top "
;		db "This in the middle        "
;		db "And this on the bottom    "
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TextPtrs:
dw Text29
dw Text2A
dw Text2B
dw Text2C
dw Text2D
dw Text2E
dw Text2F
dw Text30
dw Text31
dw Text32
dw Text33
dw Text34

Text29:
		db "Battle Garegga Degeneracy "
		db "    (Arranged Version)    "
		db "Port By Lui               "
		
Text2A:
		db "Ducktales 2 - Glomgold's  "
		db "Ship                      "
		db "Port by Dippy             "
Text2B:
		db "KETSUI - No Remorse       "
		db "(Mega Man X2 Style)       "
		db "Port by JX444444          "
Text2C:
		db $FF
Text2D:
		db $FF
Text2E:
		db $FF
Text2F:
		db $FF
Text30:
		db $FF
Text31:
		db $FF
Text32:
		db $FF
Text33:
		db $FF
Text34:
		db $FF


