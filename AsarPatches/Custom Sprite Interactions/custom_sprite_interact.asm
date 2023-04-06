incsrc "sa1def.asm"
;Please check the readme
incsrc "settings.asm"

;no touch
!pointers = #((PointerEnd-Pointers)/2)

;note that this patch relies on the frame rules patch to work correctly
;this hex edit makes the game check contact between mario and sprites
;every frame rather than every other frame
org $01A7EF
	db $00

;mario in water check
org $00EA45
	autoclean JML check_water

;contact between mario and sprite
org $01A832
	autoclean JML check_flag
	NOP

;additional check for carriable sprites	
org $01A88B
	autoclean JML check_spin_flag
	NOP
	
;update sprite position no grav
org $01ABD8
	autoclean JML check_update_position
	
org $019035
	autoclean JML check_grav_position
	NOP
	
org $01AC07
	autoclean JSL update_mario_pos
	NOP

freecode
prot Kick_Speed_X
prot MarioSpeed
prot Custom_Gravity_Table
prot Vanilla_Gravity_Table
prot Clipping_X_Right_Offset
prot Clipping_X_Left_Offset
prot Clipping_X_Forward_Offset
prot Clipping_Y_Offset_Table

;restore original code and jump based on condition	
Vanilla_Interact:
	LDA.w !167A,x
	BPL .default
	JML $01A837
.default
	JML $01A83B


check_flag:
	LDA $0100|!addr				;\ don't run unless in level
	CMP #$14					;| I have no idea if this or something else fixed the bug
	BNE Vanilla_Interact		;/ where post patch the title screen would fail to load
	LDA !flag|!addr				;\ if flag > number of pointers
	CMP.b !pointers				;|
	BCS Vanilla_Interact		;/ return

	JSL $0086DF					;jump to pointer based on flag
Pointers:	
	dw Vanilla_Interact
	dw Platform_Start
	dw Spin_Jump
	dw Normal_Jump
	dw Bumpty
	dw Water
	dw Carry
	dw Nets
PointerEnd:						;needed for above calculation


Platform_Start:
	LDA !190F,x					;\ backup platform solid flag
	PHA 						;/
	LDA !additional_ram|!addr	;\ don't bother checking the setting
	AND #$01					;| 0 = solid sprite platform
	ORA !190F,x					;| 1 = semi-solid
	STA !190F,x					;/
	PHK							;\
	PEA Check_Jump-1			;| JSL to RTS trick
	PEA.w $0180CA-1				;|
	JML $01B45C					;/
Check_Jump:
	PLA							;\ restore backup
	STA !190F,x					;/
	LDA $16						;\ if jump not pressed
	ORA $18						;|
	AND #$80					;|
	BEQ Add_Grav				;/ apply additional downward speed to mario, helps keep him attached to sprites
Platform_Return:
	JML $01A7F5					;CLC:RTS, "no contact" so sprite doesn't run its own interaction

Add_Grav:
;I've completely forgotten what this was for
;	LDA !additional_ram|!addr	
;	AND #$02					
;	BNE +
;	LDA $77
;	AND #$04
;	ORA $1471|!addr
;	BEQ Platform_Return
+
	STX $00							;\ add some downward speed to mario 
	LDA !7FAB10,x					;| based on what sprite it is and what 
	AND #$08						;| value is set for that sprite in the table
	BNE .custom						;|
	LDA !9E,x						;| truthfully, I could probably just replace this 
	TAX								;| with 
	LDA.l Vanilla_Gravity_Table,x	;| LDA #$30
	BMI .ignore						;| STA $7D
	BRA .done						;| and save 2 FF tables of space
.custom								;|
	LDA !7FAB9E,x					;|
	TAX								;|
	LDA.l Custom_Gravity_Table,x	;|
	BMI .ignore						;|
.done								;|
	STA $7D							;|
.ignore								;|
	LDX $00							;|
	JML $01A7F5						;/


;this was just copied from the Bumpty sprite on smwcentral
;all credits go to Romi, shout them out in your hack if you
;end up using this
Bumpty:
	LDA !additional_sprite_table,x
	BNE Platform_Return
	JSR SubVertPos
	LDA $0F
	PHA
	LDA $187A|!addr
	BEQ +

	PLA
	CLC
	ADC #$10
	BRA ++

+
	PLA
++
	CMP #$EB
	BPL TouchesSides
	LDA $7D
	BMI TouchesSides

	LDA $187A|!addr
	BEQ +

	LDA #$2C
	BRA ++
+
	LDA #$1C
++
	STA $00
	STZ $01

	LDA !14D4,x
	XBA
	LDA !D8,x
	REP #$20

	SEC
	SBC $00
	STA $96
	SEP #$20

	LDA #$B8
MARIO_Y_SPEED:		
	STA $7D
	LDA #!BoingSFX
	STA !BoingPort|!addr
InteractReturn:		
	LDA #$08
	STA !additional_sprite_table,x
	JML $01A7F5

TouchesSides:		
	JSR SubHorzPos
	PHY
	PHX
	TYX
	LDA.l MarioSpeed,x
	STA $7B
	PLX
	PLY
	LDA #!BoingSFX
	STA !BoingPort|!addr
	BRA InteractReturn


Spin_Jump:
;spin jump only
	LDA !1656,x			;\ backup sprite's settings
	PHA					;|
	AND #%11101111		;| flip the spin bit
Generic_Interact:		;|
	STA !1656,x			;|
	PHK					;|
	PEA Spin_Return-1	;| JSL to RTS trick to the 
	PEA.w  $0180CA-1	;| generic interact routine
	JML $01A83B			;|
Spin_Return:			;|
	PLA					;|
	STA !1656,x			;|
	BRA Re				;/


Normal_Jump:
	LDA !1656,x				;\ same as above but flip the bit
	PHA						;|
	ORA #%00010000			;|
	BRA Generic_Interact	;/


Water:
	LDA #!water_frames			;\ We just need to set a timer
	STA !additional_ram|!addr	;| a separate hijack below handles making mario swim
	BRA Re						;|

Nets:
	LDA $1470|!addr					;\ if holding something
	ORA $187A|!addr					;| or riding yoshi
	BNE Re							;/ don't climb
	LDA !additional_ram|!addr		; skip ahead of flag is clear
	BMI +
	CPX !additional_ram|!addr		;\ if mario is climbing on another sprite
	BNE Re							;/ return
+
	LDA !additional_sprite_table,x	;\ if already climbing on this sprite
	BNE Skip_button_check			;/ skip button check
	LDA $15							;\ if up or down not pressed this frame
	AND #%00001100					;|
	BEQ Re							;/ return
	LDA #!climbing_frames			;\
	STA !additional_sprite_table,x	;|
	STA $18BE|!addr					;| otherwise start climbing
	TXA								;|
	STA !additional_ram|!addr		;/
Skip_button_check:
	LDA $16							;\ jump off if B is pressed
	AND #$80						;/ 
	BEQ .climb
	LDA #!climb_jump
	STA $7D
	LDA #$00
	STA !additional_sprite_table,x
	STA $18BE|!addr
	LDA #$FF
	STA !additional_ram|!addr
	BRA Re
.climb
	LDA #!climbing_frames			;\
	STA !additional_sprite_table,x	;|
	STA $18BE|!addr					;| continue climbing
	TXA								;|
	STA !additional_ram|!addr		;/
Re:
	JML $01A7F5
	
Vanilla_Interact1:
	JMP Vanilla_Interact
Carry:
	LDA !additional_sprite_table,x	;\ if release timer isn't over
	BNE Re							;/ don't interact
	LDA $187A|!addr					;\ if riding yoshi
	BNE Vanilla_Interact1			;|
	LDA !14C8,x						;| 
	CMP #$09						;| or sprite is carriable
	BEQ Vanilla_Interact1			;| 
	CMP #$0A						;| or kicked
	BEQ Vanilla_Interact1			;/ normal interaction
	STX $00							
	LDA !additional_ram|!addr
	BMI .check_holding			;if negative, not holding anything
	CMP $00						;if slots are different, holding something else
	BEQ .continue		;non-vanilla holding something else
.check_holding
	LDA $148F|!addr					;\ check for vanilla carriable sprites
	ORA $1470|!addr					;|
	BNE Vanilla_Interact1			;/
	LDA $15							;\ if not holding run
	AND #$40						;|
	BEQ Vanilla_Interact1			;/
;Bit of code to make sprite act normally if mario is above it
;still a heavy wip
;	LDA !D8,x
;	STA $0E
;	LDA !14D4,x
;	STA $0F
;	LDA Clipping_Y_Offset_Table,x
;	STA $0C
;	STZ $0D
;	REP #$30
;	LDA $0E
;	CLC
;	ADC #!mario_vertical_offset
;	SEC
;	SBC $96
;	SBC $0C
;	SEP #$30
;	BCS Vanilla_Interact1
.continue
	PHX									;\ grab the values for the sprite's 
	LDA !1662,x							;| clipping from the clipping tables
	AND #$3F							;|
	TAX									;|
	LDA.l Clipping_X_Right_Offset,x		;|
	LDY $76								;|
	BNE .no_invert						;|
	LDA.l Clipping_X_Left_Offset,x		;|
.no_invert								;|
	STA $04								;|
	LDA.l Clipping_Y_Offset_Table,x		;|
	STA $05								;/
Checks:
	LDA !additional_ram|!addr+1			;\ if we're facing forward
	ORA $1499|!addr						;| or our additional turn timer isn't over
	;ORA $74							;| replace the X offset from above
	BEQ Offset							;| with the one in the forward table
	LDA.l Clipping_X_Forward_Offset,x	;| this helps keep sprites on mario 
	STA $04								;/ when turning at high speeds
Offset:
;set sprite's position to mario's next frame +/- the offset from above
	PLX
	STZ $01
	LDA $04
	BPL +
	DEC $01
+
	CLC
	ADC $94		;$d1, this frame. $94, next frame
	STA $00
	LDA $01
	ADC $95
	STA $01
	LDA $00
	STA !E4,x
	LDA $01
	STA !14E0,x
	
	STZ $01
	LDA $05
	BPL +
	DEC $01
+
	CLC
	ADC $96		;$d3, this frame, $96, next frame.
	STA $00
	LDA $01
	ADC $97
	STA $01
	LDA $00
	STA !D8,x
	LDA $01
	STA !14D4,x
	
	LDA #$01					;\ set mario is carrying something flag
	STA $148F|!addr				;|
	STA $1470|!addr				;/
	LDA $76						;\ flip other sprite's direction
	STA !157C,x					;/ usually...
	STX !additional_ram|!addr	;backup the sprite we're holding for next frame
	LDA $15						;\ if run is still being held
	AND #$40					;|
	BNE Carry_Return			;| return
	JSR handle_release			;/ otherwise release
Carry_Return:					
	JML $01A7F5					;CLC:RTS, no contact return to sprite code


handle_release:
	LDA $15						;\ up throw if holding up
	AND #$08					;|
	BNE Toss_Up					;/
	LDA $15						;\ if no direction is held, drop
	AND #$03					;| like non-shell items
	BEQ Drop					;/
;CODE_01A090:        B9 6B 9F      LDA.W ShellSpeedX,Y       ; \ Sprite X speed = Value from table
	JSR kick_gfx_and_sound
;in the vanilla routine, the game sets $C2,x to whatever
;value is currently in $1540,x. This will more than likely
;crash several sprites. As will setting $14C8,x to #$0A
;this was mostly taken from all.log
	PHX								
	LDX $76							
	LDA.l Kick_Speed_X,x			
	PLX								
	STA !B6,x						
	EOR $7B							 
	BMI Finish_Release				 
	LDA $7B							 
	STA $00							 
	ASL $00							 
	ROR								 
	CLC								 
	ADC !B6,x						 
	STA !B6,x						
	BRA Drop						
Toss_Up:
	JSR kick_gfx_and_sound
	LDA #!vertical_kick
	STA !AA,x
	LDA $7B
	STA !B6,x
	ASL
	ROR !B6,x
	BRA Finish_Release
Drop:
	STZ !AA,x
Finish_Release:
	LDA #!disable_after_drop
	STA !additional_sprite_table,x
	LDA #$0C
	STA $149A|!addr
	RTS

kick_gfx_and_sound:
	LDA #!KickSFX
	STA !KickPort|!addr
	LDA !15A0,x
	ORA !186C,x
	BNE .return
	PHY
	LDY #$03
.loop
	LDA $17C0|!addr,y
	BEQ .found
	DEY
	BPL .loop
	INY
.found
	LDA #$02
	STA $17C0|!addr,y
	LDA !E4,x
	STA $17C8|!addr,y
	LDA !D8,x
	STA $17C4|!addr,y
	LDA #$08
	STA $17CC|!addr,y
	PLY
	RTS
.return
	RTS
	

check_spin_flag:
	LDA $0100|!addr			;\ small hijack to make 
	CMP #$14				;| normally carriable sprites function
	BNE Vanilla_Spin		;| 
	LDA !flag|!addr			;| 
	BEQ Vanilla_Spin		;| 
	CMP #$06				;| 
	BEQ Vanilla_Spin		;| 
	JML $01A897				;/
	
;restore vanilla code
Vanilla_Spin:
	LDA.w !14C8,x
	CMP.b #$09
	JML $01A890

;don't clear swimming flag if timer is set
check_water:
	LDA $0100|!addr
	CMP #$14
	BNE Vanilla_Water
	LDA !flag|!addr
	CMP #$05
	BNE Vanilla_Water
	LDA !additional_ram|!addr
	BEQ Vanilla_Water
	DEC
	STA !additional_ram|!addr
	STA $75
	CMP #$01			;if we're about to be out of water
	BNE +
	LDA $72
	CMP #$0B			;and mario is airborne, and rising
	BNE +				
	LDA #!water_boost	;then add the small boost out of water
	STA $7D
+
	JML $00EAA5
Vanilla_Water:
	LDA $85
	BNE Vanilla_Branch
	JML $00EA49
Vanilla_Branch:
	JML $00EA5E
	
	
SubHorzPos:
	LDY #$00
	LDA $94
	SEC
	SBC !E4,x
	STA $0E
	LDA $95
	SBC !14E0,x
	STA $0F
	BPL +
	INY
+
	RTS

SubVertPos:
	LDY #$00
	LDA $96
	SEC
	SBC !D8,x
	STA $0F
	LDA $97
	SBC !14D4,x
	BPL +
	INY
+
	RTS

No_Move:
	LDA #$00
	JML $01AC0C

;don't update X/Y position if mario is holding the sprite
check_update_position:
	LDA $0100|!addr
	CMP #$14
	BNE .vanilla
	LDA !flag|!addr
	CMP #$06
	BNE .vanilla
	CPX !additional_ram|!addr
	BEQ No_Move
;vanilla uses the same routine to update both x/y positions without gravity
;they simply add an additional #$0C to the index to get the X speed.
	TXA 
	SEC
	SBC #!SprSize
	CMP !additional_ram|!addr
	BEQ No_Move
	
;restore original and return
.vanilla
	LDA !AA,x
	BEQ .Code_01AC09
	JML $01ABDC
.Code_01AC09
	JML $01AC09

;don't apply gravity if mario is holding the sprite
check_grav_position:
	LDA $0100|!addr
	CMP #$14
	BNE .vanilla
	LDA !flag|!addr
	CMP #$06
	BNE .vanilla
	CPX !additional_ram|!addr
	BNE .vanilla
;don't do position update, just return
	JML $019084
;restore original code
.vanilla
	LDY.b #$00
	LDA.w !164A,x
	BEQ CODE_019049
	JML $01903C
CODE_019049:
	JML $019049
	
	
;move mario along with sprite if mario is climbing on the sprite
update_mario_pos:
	ADC.B #$00				;\ restore vanilla code
	STA.W $1491|!addr		;/
	LDA $0100|!addr
	CMP #$14
	BEQ +
	RTL
+
	LDA !flag|!addr
	CMP #$07
	BEQ .check_climbing
	RTL
.check_climbing
	STX $0F
	LDY #$02			;y = 02, Y position update. y = 00, X position update
	TXA					;\ Check current sprite slot, Nintendo reuses
	CMP #!SprSize		;| the same routine for Y and X position update.
	BMI +				;| They simply add #$0C to the X register to
	DEY					;| get the routine to update the X position.
	DEY					;| We need the the value between 0 and SprSize
	SEC					;| so we can check the additional ram. 
	SBC #!SprSize		;|
	TAX					;/
+
	CMP !additional_ram|!addr
	BNE .reset_and_return
	TYX
	LDY #$00
	LDA $1491|!addr
	BPL +
	DEY
+
	CLC 
	ADC $94,x
	STA $94,x
	INX
	TYA
	ADC $94,x
	STA $94,x
.reset_and_return
	LDX $0F
	RTL
	
	
	
	
freedata
incsrc "tables.asm"