	ORG     $0000
	Padding Off
	DC.B      "g GCE 1983", $80       ;(C) GCE 1983	- Don't Change
	DC.W      $FD0D 				  ;Music File
    DC.B      $F8, $50, $20, -$46     ;Title Pos H,W,Y,X
    DC.B      "LEARNASM.NET",$80		;Cart Title (length can change)
    DC.B      0                       ;Header Ends

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ASSUME dpr:$d0		;SETDP on other systems $D0= Hardware Regs $C8=Ram
	lda #$d0
	tfr a,dp
		
	ldx #40		;X
	ldy #40		;Y
	lda #8		;Scale
	
InfLoop:				
	pshs x,y,a
		jsr $F192 ; FRWAIT - Wait for beginning of frame boundary (Timer #2 = $0000).									
		jsr ResetPenPos	;Center 'pen' position, scale=127

	puls x,y,a

	jsr ShowSprite		;Show our Smiley

	jsr ReadJoystick	;Read in the Joystick	%4321UDLR
	
	bitb #%00000001
	bne JoyNotUp		;Up Pressed?
	cmpY #127			;At top of screen?
	beq	JoyNotUp
	leay 1,y		;Y=Y+1
JoyNotUp:	
	bitb #%00000010
	bne JoyNotDown		;Down Pressed?
	cmpY #-128			;At bottom of screen?
	beq	JoyNotDown
	leay -1,y		;Y=Y-1
JoyNotDown:	
	bitb #%00000100
	bne JoyNotLeft		;Left Pressed?
	cmpX #-128			;At left of screen
	beq	JoyNotLeft
	leax -1,x		;X=X-1
JoyNotLeft:	
	bitb #%00001000
	bne JoyNotRight		;Right Pressed?
	cmpX #127			;At Right of screen
	beq	JoyNotRight
	leax 1,x		;X=X+1
JoyNotRight:	
	bitb #%00010000		;Fire1 Pressed?
	bne JoyNotF1
	cmpa #0				;Min Size?
	beq	JoyNotF1
	deca			;Shrink sprite
JoyNotF1:		
	bitb #%00100000		;Fire2 Pressed?
	bne JoyNotF2
	cmpa #255			;Max size?
	beq	JoyNotF2
	inca			;Grow Sprite
JoyNotF2:	

	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
PacketSmile:			;Smiley
		;CMD,YYY,XXX
    dc.b $00,$32,$E9	;00=Move
    dc.b $FF,$00,$26	;FF=Line
    dc.b $FF,$E1,$1D
    dc.b $FF,$D2,$02
    dc.b $FF,$FF,$00
    dc.b $FF,$E7,$DE
    dc.b $FF,$02,$CE
    dc.b $FF,$2A,$EE
    dc.b $FF,$29,$0B
    dc.b $FF,$13,$15
    dc.b $00,$E6,$02
    dc.b $FF,$F7,$F8
    dc.b $FF,$EF,$0C
    dc.b $FF,$FF,$00
    dc.b $FF,$12,$0C
    dc.b $FF,$0A,$F1
    dc.b $00,$00,$1C
    dc.b $FF,$F6,$0F
    dc.b $FF,$F2,$F7
    dc.b $FF,$09,$F5
    dc.b $FF,$0F,$05
    dc.b $00,$D6,$D0
    dc.b $FF,$EB,$18
    dc.b $FF,$00,$18
    dc.b $FF,$1E,$1B
    dc.b $01			;01=END
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ResetPenPos:
	pshs x,d
;Zero the integrators only 		
		jsr $F36B	;ZERO - Zero the integrators only
;Reset Pos /Scale 
		ldx #PositionList	;Position Vector (Y,X)
		ldb #127	;Scale (127=normal 64=half 255=double)
		jsr $F30E	;POSITB - Release integrators and position beam
	puls x,d,pc

PositionList:
	dc.b 0,0				

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

ShowSprite:		;Draw our Smiley at (X,Y) size A
	pshs x,y,a
		pshs a
			tfr y,d
			tfr b,a		;Ypos->A
			pshs A
				tfr x,d	;Xpos->B
			puls A
		
			jsr $F312 	;POSITN - Set beam pos to (Y,X) A,B
		puls b

		;B=Scale (127=normal 0=dott 255=double)
		LDX     #PacketSmile     ;Packet address
		jsr $F40E 	;Tpack - Draw according to ‘Packet’ style list

	puls x,y,a
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

ReadJoystick:
	pshs x,y,a			
	;Set up Joystick setting
		ldd #$0103 		;Enable Joy 1
		std $C81F		;Epot0/1	
		
		ldd #$0000		;Disable Joy 2 (Doesn't work?)
		std $C821		;Epot2/3
		
		jsr $F1F8		;JOYBIT - Read Up, Down, Left, Right

		lda #255		;Direct response mask
		jsr $F1B4		;DBNCE - Read Buttons 1234 (A=Response mask)
		
	;Convert to 1 bit per button digital (in B)
		ldb $C80F		;4 Fire buttons %----4321
		
		;$C81B - Controller #1: Right / left joystick pot value
		lda $C81B		;LR
		jsr TestOneAxis	
		
		;$C81C - Controller #1: Up / down joystick pot value
		lda $C81C		;UD
		nega			;Flip Y axis so our test works
		jsr TestOneAxis
		
		comb			;Flip bits of B
		tfr b,a
	puls x,y,a
	rts
	
TestOneAxis:	;Test an Axis, and convert to two bits in B
	lslb
	lslb
	cmpa #$40
	bcs TestOneDone
	cmpa #$C0
	bcs TestOneDoneB
	orb #%00000001
	rts
TestOneDoneB:
	orb #%00000010
TestOneDone:	
	rts
	
	
	
