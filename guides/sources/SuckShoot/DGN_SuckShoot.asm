
EnemySprite equ $7280	
EnemyScale equ $7281
EnemySpeed equ $7282
EnemySpeedb equ $7283
	
EnemyX equ $7284
EnemyY equ $7286

PlayerX equ $7288
PlayerY equ $728A

SoundTimeOut  equ $728C
RandomSeed equ $728E


BcdHiscore equ $7290
BcdScore equ $7295
BcdLives equ $7294

	include "\srcALL\BasicMacros.asm"	
	include "\srcALL\v1_header.asm"
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;Set up Pmode 3 screen 
	sta $FFC6	;Clr ScrBase Bit 0	$0200
	sta $FFCA	;Clr ScrBase Bit 2	$0800
	sta $FFCC	;Clr ScrBase Bit 3	$1000
	sta $FFCE	;Clr ScrBase Bit 4	$2000
	sta $FFD0	;Clr ScrBase Bit 5	$4000
	sta $FFD2	;Clr ScrBase Bit 6	$8000
	
	sta $FFC8+1	;Set ScrBase Bit 1	$0400
	
	sta $FFC0	;SAM V0=0
	
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%11100000
	sta $FF22
	sta $ffc4+1 ;SAM V2=1
	sta $ffc2+1	;SAM V1=1


	ldu #BcdHiScore
	ldx #0
	stx u++				;Clear the highscore
	stx u++
	
ShowTitle:
	jsr CLS
	jsr WaitForRelease	;Wait for fire to be released

	lda #0
	jsr ChibiSound		;Silence sound
	
	lda #%00000100
	sta EnemySprite

	ldd #$0300		;XXYY
	ldy #txtSuckShoot		;Show Title
	jsr LocateAndPrintString

	ldd #$0412		;XXYY
	ldy #txtHiscore			;Show Highscore Text
	jsr LocateAndPrintString
	
	ldd #$0413		;XXYY
	jsr Locate
	ldb #4
	ldx #BcdHiscore			;Show Highscore
	jsr BCD_Show	
	
	lda #16			;X
	sta EnemyX
	lda #80			;Y
	sta EnemyY
	
	lda #48					;Big Sprite
	sta EnemyScale
	lda #0					;Sprite 0
	sta EnemySprite
	
	
TitleScreen:	
	lda EnemySprite
	eora #%00000001			;Toggle Frame
	sta EnemySprite
	
	jsr ShowEnemy			;Show Bat Sprite
		
	lda #255
	jsr delay				;Pause
	
	jsr ShowEnemy			;Show Bat Sprite
	
	jsr ReadJoystick		;Read in the Joystick	%---1UDLR
	bitb #%00010000			;Fire1 Pressed?
	bne TitleScreen			;Wait until it is!
	
	
GamePlay:				;Start a new game
	jsr CLS
	jsr RandomizeEnemy
		
	lda #$04
	sta BcdLives		;Plater lives
	
	ldu #BcdScore		;Player score
	ldx #0
	stx u++
	stx u++
	
	lda #16
	
	sta PlayerX			;Center player
	lda #96
	sta PlayerY
	
	lda #32
	sta EnemySpeed		;Bat Move speed
	
	jsr UpdateScore		;Update Score/lives text


	
;Main Game Loop	
InfLoop:	
	lda SoundTimeOut		;Time till silenced
	deca
	bne ChibiSoundUpdated
	jsr ChibiSound			;Make sound A
ChibiSoundUpdated:
	sta SoundTimeOut	

	lda EnemySprite
	eora #%00000001			;Flip enemy sprite frame
	sta EnemySprite
	
	jsr ShowEnemy			;Show enemy bat
	jsr ShowTarget			;Show our cursor

	lda #64
	jsr delay
		
		
	jsr ShowEnemy			;clear enemy bat
	jsr ShowTarget			;clear our cursor
	
	lda #0
	ldb PlayerX			;Get player pos
	tfr d,x
	ldb PlayerY
	tfr d,y
	
	jsr ReadJoystick	;Read in the Joystick	%---1UDLR
	
	bitb #%00000010
	bne JoyNotDown		;Down Pressed?
	cmpY #192-8			;At top of screen?
	bge	JoyNotDown
	leay 8,y			;Y=Y+8
JoyNotDown:	
	bitb #%00001000	
	bne JoyNotRight		;Right Pressed?
	cmpX #30			;At Right of screen
	bge	JoyNotRight
	leax 2,x			;X=X+2
JoyNotRight:		
	nega				;Negative movement
	bitb #%00000001
	bne JoyNotUp		;Up Pressed?
	cmpY #12			;At bottom of screen?
	blt	JoyNotUp
	leay -8,y			;Y=Y-8
JoyNotUp:	
	bitb #%00000100
	bne JoyNotLeft		;Left Pressed?
	cmpX #4				;At left of screen
	blt	JoyNotLeft
	leax -2,x			;X=X-2
JoyNotLeft:	
	
	
	bitb #%00010000		;Fire1 Pressed?
	bne JoyNotF1
	
	pshs x,y
		lda #%11000001
		jsr ChibiSound		;Make sound A
		lda #8
		sta SoundTimeOut
	
		jsr rangetestPlayer	;1=Collided
		beq RangeTestDone	;Has player missed?
		
		lda #%11010000
		jsr ChibiSound		;Make sound A
		
		lda EnemySpeed		;Speed up enemy
		adda #1
		sta EnemySpeed
		jsr RandomizeEnemy	;Reposition enemy
		
		ldb #4
		ldx #bcdScoreAdd	;$05 00 00 00
		ldy #BcdScore		;BCD Dest
		jsr BCD_Add			;Add 5 BCD points
		
		jsr UpdateScore		;Update Score/lives text
RangeTestDone:
	puls x,y
	
	
JoyNotF1:		
	tfr x,d
	stb PlayerX				;Update player pos
	tfr y,d
	stb PlayerY
	
	lda EnemySpeedb
	adda EnemySpeed			;Enemy move time
	sta EnemySpeedb
	bcc NoEnemyHit
	
	lda EnemyScale
	adda #8					;Make enemy bigger
	sta EnemyScale
	cmpa #64				;Biggest?
	bcs NoEnemyHit
		jsr RandomizeEnemy	;Bat bit us!
		
		lda #%01111000
		jsr ChibiSound		;Make sound A
		lda #8
		sta SoundTimeOut
		
		dec BcdLives		;Player lost a life
		beq GameOver		;No lives left?
		
		jsr UpdateScore		;Update Life count text
NoEnemyHit:	
	jmp InfLoop

	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
UpdateScore:
	ldd #$0000		;XXYY
	jsr Locate
	
	ldb #4			;4 Bytes
	ldx #BcdScore	;Show Score
	jsr BCD_Show	
	
	ldd #$1E00		;XXYY
	jsr Locate
	
	ldb #1			;1 Byte
	ldx #BcdLives	;Show Lives
	jsr BCD_Show	
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	


GameOver:
	jsr WaitForRelease
	lda #0
	jsr ChibiSound			;Silence sound

	jsr cls
	
	ldd #$0408		;XXYY
	ldy #txtGameOver		;Show GameOver
	jsr LocateAndPrintString

	ldb #4					;4 bcd bytes
	ldx #BcdScore			;This score
	ldy #BcdHiscore			;Higest score
	jsr BCD_CP				;Compare the two
	bcs GameOver_NoScore	;New score higher

	ldx #BcdScore 			;We got a new highscore
	ldy #BcdHiscore 
	ldu #4
	jsr LDIR2	
		
GameOver_HiScore:			;We got a highscore!
	ldd #$030C		;XXYY
	ldy #txtGotHiScore		;Show Highscore Message
	jsr LocateAndPrintString
GameOver_Wait:
	jsr ReadJoystick		;Read in the Joystick	%---1UDLR
	bitb #%00010000			;Fire1 Pressed?
	bne GameOver_Wait
	jmp ShowTitle
	
GameOver_NoScore:			;No highscore, we officially suck!
	ldd #$020C		;XXYY
	ldy #txtNoHiScore		;Show Suck Message
	jsr LocateAndPrintString
	jmp GameOver_Wait	

txtGameOver:
	dc.b "GAME OVER",255
txtGotHiScore:	
	dc.b "NEW HISCORE",255
txtNoHiScore:				;Test string (Ucase only)
	dc.b "YOU SUCK!",255	

WaitForRelease:	
	jsr ReadJoystick	;Read in the Joystick	%---1UDLR
	bitb #%00010000		;Fire1 Pressed?
	beq WaitForRelease
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
txtSuckShoot:
	dc.b "SUCK SHOOT!",255
txtHiscore:
	dc.b "HISCORE:",255

bcdScoreAdd:	;5 points in BCD
	dc.b $05,$00,$00,$00
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
ShowTarget:
	ldy #SpriteData
	
	lda PlayerX			;Xpos
	sta z_b
	
	lda PlayerY			;Ypos
	sta z_c
	
	jmp ShowSprite		;Show new sprite pos
	
	
ShowEnemy:
	lda EnemyScale		;Scale *8
	coma
	lsra
	anda #%00011000
	sta z_b
	ldb EnemySprite
	andb #%00000001		;Frame *4
	lslb
	lslb
	orb z_b
	addb #4				;First Bat Sprite=+4 bytes

	ldx #SpriteData
	abx
	tfr x,y				;Pos in SpriteData Table
	
	lda EnemyX			;Xpos
	sta z_b
	
	lda EnemyY			;Ypos
	sta z_c
	
	jmp ShowSprite		;Show new sprite pos
	

ShowSprite:				;Show Sprite (Y) at z_B,z_C 
		ldx y			;Y=Sprite Info Table
		lda 2,y			;Width (Pixels)
		lsra 
		lsra
		sta z_h			;Width (Bytes)
		lsra
		nega
		adda z_b		;CenterX
		sta z_b
		
		lda 3,y
		sta z_l			;Height (Lines)
		lsra
		nega
		adda z_c
		sta z_c			;CenterY
ShowSpriteAlt:		
		pshs x
			jsr GetScreenPos	;Calculate screen address
		puls x
		
		ldb z_l			;Height in lines
	NextLine:
		pshs b
			ldb z_h		;Width in bytes (2 Color)
			pshs y
	NextByte:
				lda x+		;Transfer a byte
				eora y		;EOR (XOR) with screen byte
				sta y+		;Store to screen
				decb
				bne NextByte ;Repeat for next byte
			puls d
			addd #32		;Move down a line
			tfr d,y
		puls b	
		decb
		bne NextLine	;Repeat for next line
	rts	
	
	
GetScreenPos: 	;Y=ram address of (X,Y)
	ldb z_c
	lda #32		;Screen width	
	mul			;Ypos * ScreenWidth
	addd #$400	;Add Screen Base
	tfr d,x
	ldb z_b
	lda #0
	abx
	tfr x,y	
	rts			;Result in Y
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
Delay:	
	decb
	bne Delay			;Delay loop
	deca
	bne Delay	
	rts	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

LocateAndPrintString:
	jsr Locate
PrintString:			;Print 255 terminated string
	lda ,Y+
	cmpa #255	
	beq PrintStringDone	;read 255? then done
	jsr printchar		;Print Char to screen
	jmp PrintString
PrintStringDone:	
	rts		
	
	
	
	
Locate:
		sta CursorX				;Xpos
		stb CursorY				;Ypos
	rts
	
NewLine:
		clr CursorX				;Clear Xpos
		inc CursorY				;Inc Ypos
	rts	
printchar:
	pshs x,y,d
		suba #32
		tfr a,b
		lda #0
		lslb
		rola
		lslb
		rola
		lslb
		rola
		addd #Font
		pshs d
			ldd CursorX
			lsla			;X*2
			lslb			;Y*8
			lslb
			lslb
			std z_bc
			jsr GetScreenPos	;Calculate screen address
		puls x
		
		ldb #8				;Height in lines
	NextLineF:
		pshs b
			pshs y	
				ldb x+		;Transfer a byte
				
		
				jsr DoFontByte
				jsr DoFontByte
			puls d
			addd #32		;Move down a line
			tfr d,y
		puls b	
		decb
		bne NextLineF		;Repeat for next line
		inc CursorX
	puls x,y,d,pc
	
DoFontByte:
	lda #0
	rolb
	rola
	rola
	rolb
	rola
	rola
	rolb
	rola
	rola
	rolb
	rola
	rola
	sta y+		;Store to screen
	rts
	
CLS:
	ldy #$1800			;Screen Bytes
ClsAgain:	
	clr $3FF,y			;Destination
	leay -1,y			;Dec Y
	bne ClsAgain		;Repeat
	rts
	
	
;$FF03 B3	$FF01 B3
	
;0			0		Right - X-axis
;0			1		Right - Y-axis
;1			0		Left - X-axis
;1			1		Left - Y-axis


	;Bit 7=Over test Value (written to FF20)
	;Bit 0=JoyR Fire
	;Bit 1=JoyL Fire

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;The 'RangeTest' function works with unsigned numbers, but our code uses
;Signed ones - we'll convert them to fix the problem

rangetestPlayer:
	lda PlayerX
	sta z_D
	lda PlayerY
	sta z_E
	
	
	lda EnemyX
	sta z_B
	lda EnemyY
	sta z_C
	
	lda #4			;Width
	ldB #12			;Height
	jmp rangetest
	
	
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
	
RandomizeEnemy:
		lda #4
		ldb #28
		jsr dorangedrandom	
		sta EnemyX		

		lda #16
		ldb #192-16
		jsr dorangedrandom
		sta EnemyY	
		
		lda #16			;Default Enemy scale
		sta EnemyScale	
	rts		

	
dorangedrandom:			;return a value between A and B
	sta z_b
	stb z_c
dorangedrandomB:		
	jsr dorandom
	cmpa z_b
	bcs dorangedrandomB
	cmpa z_c
	bcc dorangedrandomB
	rts

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
;Read in the Joystick	%---FRLDU
ReadJoystick:
	clrb				;We'll build up the result in B
		
	lda #%11111111			;Disable Keyboard
	sta $FF02

;Fire button
	lda $FF00				;Bit 0=Fire
	rora					;Get Fire (Bit 0)
	rolb
	
;X axis Tests	
	lda #%00000100			;Bit3=0 X-axis
	sta $ff01				;PIA0-A Control
		; 543210--	TestVal
	lda #%11100000			;Test DAC>56 (Right)
	sta $FF20				;Store test value into DAC
	lda $FF00				;Bit 7=Test Result
	rola					;Right (True if Bit 7=0)
	rolb
		; 543210--	TestVal
	lda #%00011100			;Test DAC>7 (Left)
	sta $FF20				;Store test value into DAC
	lda $FF00				;Bit 7=Test Result
	rola					;Left (True if Bit 7=1)
	rolb
	
;Y axis Tests	
	lda #%00001100			;Bit3=1 Y-axis
	sta $ff01				;PIA0-A Control
		; 543210--	TestVal
	lda #%11100000			;Test DAC>56 (Down)
	sta $FF20				;Store test value into DAC
	lda $FF00				;Bit 7=Test Result
	rola					;Down (True if Bit 7=0)
	rolb
		; 543210--	TestVal
	lda #%00011100			;Test DAC>7 (Up)
	sta $FF20				;Store test value into DAC
	lda $FF00				;Bit 7=Test Result
	rola
	rolb					;Up (True if Bit 7=1)
		
;Fix results
	eorb #%11101010			;;Flip Down and Right bits
	tfr b,a					;A contains %---FRLDU
	rts	
PixelsPerByte equ 4

SpriteData:
    dc.w $0000/PixelsPerByte + SpriteBase ;SpriteAddr 0 - Cursor
     dc.b 16,16                            ;XY 
    dc.w $0100/PixelsPerByte + SpriteBase ;SpriteAddr 1 - Large 1
     dc.b 32,24                            ;XY 
    dc.w $0400/PixelsPerByte + SpriteBase ;SpriteAddr 2 - Large 2
     dc.b 32,32                            ;XY 
    dc.w $0800/PixelsPerByte + SpriteBase ;SpriteAddr 3 - Mid 1
     dc.b 24,16                            ;XY 
    dc.w $0980/PixelsPerByte + SpriteBase ;SpriteAddr 4 - Mid 2
     dc.b 24,24                            ;XY 
    dc.w $0BC0/PixelsPerByte + SpriteBase ;SpriteAddr 5 - Small 1
     dc.b 16,8                             ;XY 
    dc.w $0C40/PixelsPerByte + SpriteBase ;SpriteAddr 6 - Small 2
     dc.b 16,16                            ;XY 


	;2 bit per pixel
SpriteBase:
	binclude "\ResAll\SuckShootDGN.raw"
	
	
Font:
	binclude "\ResAll\Font96.FNT"
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\SrcALL\V1_Random.asm"
	

	align 16
;Random number Lookup tables
Randoms1:
	dc.b $0A,$9F,$F0,$1B,$69,$3D,$E8,$52,$C6,$41,$B7,$74,$23,$AC,$8E,$D5
Randoms2:
	dc.b $9C,$EE,$B5,$CA,$AF,$F0,$DB,$69,$3D,$58,$22,$06,$41,$17,$74,$83

	
	
	include "\srcALL\BasicFunctions.asm"
	
	
	include "\SrcALL\V1_ChibiSound.asm"
	
	include "\srcALL\v1_BCD.asm"
	
	
	include "\srcALL\v1_Footer.asm"