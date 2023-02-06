	include "\srcALL\BasicMacros.asm"	
	

	ASSUME dpr:$C8		;SETDP on other systems $D0= Hardware Regs $C8=Ram
		
	include "\srcALL\v1_header.asm"
	
	
EnemySprite equ $C980	
EnemyScale equ $C981

EnemyX equ $C984
EnemyY equ $C986

PlayerX equ $C988
PlayerY equ $C98A

TestFlag equ $C98C
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	
	;ASSUME dpr:$C8		;SETDP on other systems $D0= Hardware Regs $C8=Ram
	
	
	jsr RandomizeEnemy
	
	ASSUME dpr:$d0		;SETDP on other systems $D0= Hardware Regs $C8=Ram
	lda #$d0
	tfr a,dp
	
	ldx #120		;X
	stx PlayerX
	ldy #120		;Y
	sty PlayerY
	lda #32
	sta EnemyScale	
InfLoop:				
	
	jsr $F192 ; FRWAIT - Wait for beginning of frame boundary (Timer #2 = $0000).									
	jsr ResetPenPos	;Center 'pen' position, scale=127
	
	
	lda TestFlag
	bne TestFlagB
	
	ldx EnemyX
	ldy EnemyY
	jsr ShowSprite
TestFlagB:	
	
	jsr ResetPenPos	;Center 'pen' position, scale=127
	ldx PlayerX
	ldY PlayerY
	lda #32		;Scale
	jsr ShowTarget		;Show our Smiley

	
	
		
	
	
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
	
	pshs x,y
		jsr RandomizeEnemy
	puls x,y
	
JoyNotF1:		
	bitb #%00100000		;Fire2 Pressed?
	bne JoyNotF2
	
JoyNotF2:	

	stX PlayerX
	stY PlayerY
	
	
	lda #$C8
	tfr a,dp
	
	jsr rangetestPlayer
	
	lda #$d0
	tfr a,dp
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
PacketBat1:			;Smiley
		;CMD,YYY,XXX
    dc.b $00,$1C,$00
    dc.b $FF,$F7,$ED
    dc.b $FF,$E3,$00
    dc.b $FF,$01,$00
    dc.b $FF,$F5,$1C
    dc.b $FF,$15,$16
    dc.b $FF,$1C,$F1
    dc.b $FF,$00,$F2
    dc.b $00,$F6,$14
    dc.b $00,$01,$00
    dc.b $FF,$13,$11
    dc.b $FF,$F5,$0A
    dc.b $FF,$06,$0B
    dc.b $FF,$E1,$02
    dc.b $FF,$13,$E9
    dc.b $FF,$F9,$F1
    dc.b $00,$00,$D4
    dc.b $FF,$10,$EE
    dc.b $FF,$F3,$F7
    dc.b $FF,$08,$F5
    dc.b $FF,$E0,$FC
    dc.b $FF,$0E,$16
    dc.b $FF,$00,$14
    dc.b $00,$0A,$0F
    dc.b $FF,$FB,$FB
    dc.b $FF,$FD,$02
    dc.b $FF,$00,$01
    dc.b $FF,$05,$06
    dc.b $FF,$03,$FB
    dc.b $00,$02,$0C
    dc.b $00,$FF,$00
    dc.b $00,$00,$01
    dc.b $FF,$00,$07
    dc.b $FF,$FB,$05
    dc.b $FF,$FE,$F8
    dc.b $FF,$07,$FB
    dc.b $00,$EF,$F2
    dc.b $00,$FC,$FE
    dc.b $00,$00,$01
    dc.b $FF,$06,$21
    dc.b $01
	
PacketBat2:			;Smiley	
    dc.b $00,$1C,$00
    dc.b $FF,$F7,$ED
    dc.b $FF,$E3,$00
    dc.b $FF,$01,$00
    dc.b $FF,$F5,$1C
    dc.b $FF,$15,$16
    dc.b $FF,$1C,$F1
    dc.b $FF,$00,$F2
    dc.b $00,$F6,$14
    dc.b $00,$01,$00
    dc.b $00,$F1,$DB
    dc.b $FF,$04,$25
    dc.b $FF,$EB,$F3
    dc.b $FF,$12,$E8
    dc.b $00,$07,$04
    dc.b $FF,$07,$05
    dc.b $FF,$FC,$07
    dc.b $00,$00,$07
    dc.b $FF,$06,$04
    dc.b $FF,$FC,$06
    dc.b $00,$05,$02
    dc.b $FF,$00,$13
    dc.b $FF,$E9,$08
    dc.b $FF,$06,$0F
    dc.b $FF,$D6,$F8
    dc.b $FF,$2D,$F0
    dc.b $FF,$0B,$ED
    dc.b $00,$F8,$D9
    dc.b $FF,$08,$F0
    dc.b $FF,$E4,$F9
    dc.b $FF,$0C,$ED
    dc.b $FF,$CF,$0E
    dc.b $FF,$30,$0E
    dc.b $FF,$09,$0E
    Packet:
    dc.b $01
	
	
PacketTarget:			;Smiley
		;CMD,YYY,XXX
    dc.b $00,$3F,$FA
    dc.b $FF,$86,$01
    dc.b $00,$40,$43
    dc.b $FF,$00,$84
    dc.b $00,$01,$10
    dc.b $FF,$1E,$0A
    dc.b $FF,$0C,$1D
    dc.b $FF,$00,$01
    dc.b $FF,$F6,$23
    dc.b $FF,$E0,$09
    dc.b $FF,$DE,$F7
    dc.b $FF,$F4,$DE
    dc.b $FF,$0B,$DF
    dc.b $FF,$22,$F8
    dc.b $01
	
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

ShowTarget:		;Draw our Smiley at (X,Y) size A
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
		LDX     #PacketTarget     ;Packet address
		jsr $F40E 	;Tpack - Draw according to ‘Packet’ style list

	puls x,y,a
ScreenInit:
	rts
	
ShowSprite:		;Draw our Smiley at (X,Y) size A
	pshs x,y,a
			tfr y,d
			tfr b,a		;Ypos->A
			pshs A
				tfr x,d	;Xpos->B
			puls A
		
			jsr $F312 	;POSITN - Set beam pos to (Y,X) A,B
		

		;B=Scale (127=normal 0=dott 255=double)
		ldb EnemyScale
		LDX #PacketBat1     ;Packet address
		
		inc EnemySprite
		lda EnemySprite
		anda #%00010000
		beq Frame1
			LDX #PacketBat2     ;Packet address
Frame1:		
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
	
	
	
	ASSUME dpr:$C8		;SETDP on other systems $D0= Hardware Regs $C8=Ram
	
	include "\SrcALL\V1_Random.asm"
	

RandomSeed equ $C900
	
	align 16
;Random number Lookup tables
Randoms1:
	dc.b $0A,$9F,$F0,$1B,$69,$3D,$E8,$52,$C6,$41,$B7,$74,$23,$AC,$8E,$D5
Randoms2:
	dc.b $9C,$EE,$B5,$CA,$AF,$F0,$DB,$69,$3D,$58,$22,$06,$41,$17,$74,$83

	
	
RandomizeEnemy:
	pshs dp
		lda #$C8
		tfr a,dp
		
		jsr DoRandom
		tfr a,b
		clra
		std EnemyX		;AB

		jsr DoRandom
		tfr a,b				
		clra
		std EnemyY		;AB
		
	puls dp
	rts	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;The 'RangeTest' function works with unsigned numbers, but our code uses
;Signed ones - we'll convert them to fix the problem

rangetestPlayer:
	ldd PlayerX
	addb #$80		;Convert to unsigned
	stb z_D
	ldd PlayerY
	addb #$80		;Convert to unsigned
	stb z_E
	
	
	ldd EnemyX
	addb #$80		;Convert to unsigned
	stb z_B
	ldd EnemyY
	addb #$80		;Convert to unsigned
	stb z_C
	
	lda #18			;Width
	ldB #8			;Height
	jsr rangetest
	sta TestFlag	;1=Colloded
	rts
	
;See if object XY pos zD,zE hits object zB,zC in range zH,zL
;Return A=1 Collision... A!=1 means no collision
rangetest:			
	sta z_h				;Width of range
	stb z_l      		;Height of range
	
	lda z_b				;Pos1 Xpos
	suba z_h			;Shift Pos1 by 'range' to the Left
	bcs rangetestb		;<0
	cmpa z_d			;Does it match Pos2?
	bcc rangetestoutofrange
rangetestb:
	adda z_h			;Shift Pos1 by 'range' to the Right
	adda z_h
	bcs rangetestd		;>255
	cmpa z_d			;Does it match Pos2?
	bcs rangetestoutofrange
	
rangetestd:				;Y Axis Check
	lda z_c				;Pos1 Ypos
	suba z_l			;Shift Pos1 by 'range' Up
	bcs rangetestc		;<0
	cmpa z_e			;Does it match Pos2?
	bcc rangetestoutofrange
rangetestc:
	adda z_l			;Shift Pos1 by 'range' Down
	adda z_l
	bcs rangeteste		;>255
	cmpa z_e			;Does it match Pos2?
	bcs rangetestoutofrange			
rangeteste:
	lda #1				;1=Collided
	rts
rangetestoutofrange:		
	clra				;0=No Collision
	rts
	

	
	
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\srcALL\BasicFunctions.asm"
	
	include "\srcALL\v1_Footer.asm"
	
	
	