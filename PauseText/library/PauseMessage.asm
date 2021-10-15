incsrc Text.asm

;HUGE shoutouts to WhiteYoshiEgg for this box opening code.
OpenBox:
	LDA #$22                ;\
    STA $41                 ;|
    LDY $13D2|!addr         ;| change the screen settings
    BEQ +                   ;| and enable HDMA
    LDA #$20                ;|
+   STA $43                 ;|
    LDA #$22                ;|
    STA $44                 ;|
    STZ $42                 ;|
    LDA #$01<<!HDMAChannel  ;|
    TSB $0D9F|!addr			;/

	LDX $04                 ;\
    LDA.l  boxWidths,x      ;| save current window with and height
    STA $00                 ;| in $00-$01
    LDA.l  boxHeights,x     ;|
    STA $01                 ;/

    LDA #$FF                ;\
    SEC : SBC $00 : LSR     ;| save horizontal start and end points
    STA $02                 ;| in $02-$03
    CLC : ADC $00           ;|
    STA $03                 ;/

    LDA #$78                ;\  determine the vertical starting point
    SEC : SBC $01           ;| (=index to the windowing HDMA table at $04A0)
    AND #$FE                ;| (making sure it's an even number too)
    TAX                     ;/  #$B0 is basically the box center's Y position times two

    REP #$10                ;\
.loop                       ;|
    LDA $02                 ;| write the horizontal start and end points to $04A0+
    STA $04A0|!addr,x       ;| using the box height as the loop counter
    LDA $03                 ;|
    STA $04A1|!addr,x       ;|
    INX #2                  ;|
    DEC $01                 ;|
    LDA $01                 ;|
    BNE .loop               ;|
    SEP #$10                ;/
RTS

Unpause:	
	REP #$30                ;\
    LDX #448                ;|
    LDA #$00FF   			;| reset HDMA table
-							;|
    STA $04A0|!addr,x       ;| (=remove all windowing)
    DEX #2                  ;|
    BPL -                   ;|
    SEP #$30                ;/

    LDA #$01<<!HDMAChannel  ;\  disable HDMA
    TRB $0D9F|!addr         ;/
	
	REP #$30
	LDA $7F837B
	TAX
	SEP #$20
.clearLoop	
	LDA.l clearTilemap,x	;\ load up the header, tile and 
	STA !stripeTable,x		;| tile property bytes into the 
	INX						;| strip image table.
	CPX #$0007				;|
	BNE .clearLoop			;| Just enough blank tiles with 
	REP #$20				;| RLE to clear all possible tiles
	TXA						;| that were written previously
	STA $7F837B				;| 
	SEP #$30				;/

if !manualBox
	STZ !freeRAM
endif
	
	RTS

Paused:
if !manualBox
	LDA !freeRAM
	BNE .checkManualUnpause
	LDA $18
	AND #%00110000
	BEQ .skip
	LDA #$3C
	STA $13D3|!addr
	INC !freeRAM
.checkManualUnpause
	LDA !freeRAM
	CMP #$3D
	BEQ .checkButton
	INC !freeRAM
	BRA .continue
.checkButton
	LDA $18
	AND #%00110000
	BEQ .continue
	JSR Unpause
endif
.continue
	LDA $13D3|!addr
	SEC
	SBC #$3C
	EOR #$FF
	INC
	CMP #$17
	BPL .continueChecks
	STA $04
	JSR OpenBox
	RTL
.continueChecks	
	LDA $13D3|!addr
	BNE .cantUnpauseYet
	LDA $16
	AND #$10
	BEQ .skip
	JSR Unpause
	RTL
.cantUnpauseYet
	LDA $1DFB|!addr 		;\ Grab the current playing song
	SEC						;| custom songs typically start at 29
	SBC #$29				;| 
	BCC .skip				;|
	REP #$30				;| 
	AND #$00FF				;| We only need the low byte
	ASL						;| 
	TAX						;| 
	LDA.l TextPtrs,x		;| set up pointer to where data is
	STA $00					;| 
	SEP #$30				;|
	LDA.b #TextPtrs>>16		;| 
	STA $02					;|
	LDY #$00				;|
	LDA [$00],y				;| If there is no data, don't bother writing anything
	CMP #$FF				;|
	BEQ .skip				;|
	JSR WriteTiles			;/ 
	.skip
	RTL

WriteTiles:
	REP #$30
	LDA $7F837B
	TAX
	LDY #$0000
	SEP #$20
	LDA !headerByte1		;\ Load up header for top row of tiles
	STA !stripeTable,x		;| 
	INX						;|
	LDA !headerTopByte2		;|
	STA !stripeTable,x		;|
	INX						;|
	LDA !headerByte3		;|
	STA !stripeTable,x		;|
	INX						;|
	LDA !headerByte4		;|
	STA !stripeTable,x		;|
	INX						;/
.topLoop
	LDA [$00],y				;\ write all 23 tiles in the top row
	STA !stripeTable,x		;| first byte is the tile
	INX						;|
	LDA !tileProp			;| 2nd byte is the properties
	STA !stripeTable,x		;|
	INX						;|
	INY						;|
	CPY #$001A				;|
	BNE .topLoop			;/
	LDA !headerByte1		;\ Load up header for middle row
	STA !stripeTable,x		;|
	INX						;|
	LDA !headerMiddleByte2	;|
	STA !stripeTable,x		;|
	INX						;|
	LDA !headerByte3		;|
	STA !stripeTable,x		;|
	INX						;|
	LDA !headerByte4		;|
	STA !stripeTable,x		;/
	INX
.middleLoop
	LDA [$00],y				;\ Same as above but for middle row
	STA !stripeTable,x		;|
	INX						;|
	LDA !tileProp			;|
	STA !stripeTable,x		;|
	INX						;|
	INY						;|
	CPY #$0034				;|
	BNE .middleLoop			;/
	LDA !headerBottomByte1	;\ One last time for the bottom row
	STA !stripeTable,x		;|
	INX						;|
	LDA !headerBottomByte2	;|
	STA !stripeTable,x		;|
	INX						;|
	LDA !headerByte3		;|
	STA !stripeTable,x		;|
	INX						;|
	LDA !headerByte4		;|
	STA !stripeTable,x		;|
	INX						;|
.bottomLoop					;|
	LDA [$00],y				;|
	STA !stripeTable,x		;|
	INX						;|
	LDA !tileProp			;|
	STA !stripeTable,x		;|
	INX						;|
	INY						;|
	CPY #$004E				;|
	BNE .bottomLoop			;/
	LDA #$FF				;\ Denote the end of the data
	STA !stripeTable,x		;|
	REP #$20				;|
	TXA 					;| Store new position in case something else needs this
	STA $7F837B				;|
	SEP #$30				;/
	STZ $24					;this actually draws the tiles to the box
RTS



		