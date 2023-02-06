
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	

	include "\srcALL\BasicMacros.asm"	
	include "\srcALL\v1_header.asm"
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;We Read from Joy 1
	LDB #15 				;AY Reg 15 (Joy select)
	lda #$2F				;$2F (Joy1) $5F (Joy2)
	jsr FMRegWrite			;JoySelect
	

	ldu #BcdHiScore
	ldx #0
	stx u++				;Clear the highscore
	stx u++
	
ShowTitle:
	jsr CLS
	jsr WaitForRelease	;Wait for fire to be released

	lda #0
	jsr ChibiSound		;Silence sound
	
	ldd #$0F04		;XXYY
	ldy #txtSuckShoot		;Show Title
	jsr LocateAndPrintString

	ldd #$100E		;XXYY
	ldy #txtHiscore			;Show Highscore Text
	jsr LocateAndPrintString
	
	ldd #$100F		;XXYY
	jsr Locate
	ldb #4
	ldx #BcdHiscore			;Show Highscore
	jsr BCD_Show	
	
	lda #80-4		;X
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
	
	lda #80
	
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
	
	lda #8				;Move Speed
	
	bitb #%00100000		;Fire2 Pressed?
	bne JoyNotF2
	lda #16				;Fast Move Speed
JoyNotF2:	
	
	bitb #%00000010
	bne JoyNotDown		;Down Pressed?
	cmpY #192-16			;At top of screen?
	bge	JoyNotDown
	leay a,y			;Y=Y+8
JoyNotDown:	
	bitb #%00001000	
	bne JoyNotRight		;Right Pressed?
	cmpX #160-8			;At Right of screen
	bge	JoyNotRight
	leax a,x			;X=X+2
JoyNotRight:		
	nega				;Negative movement
	bitb #%00000001
	bne JoyNotUp		;Up Pressed?
	cmpY #16			;At bottom of screen?
	blt	JoyNotUp
	leay a,y			;Y=Y-8
JoyNotUp:	
	bitb #%00000100
	bne JoyNotLeft		;Left Pressed?
	cmpX #16				;At left of screen
	blt	JoyNotLeft
	leax a,x			;X=X-2
JoyNotLeft:	
	
	
	bitb #%00010000		;Fire1 Pressed?
	bne JoyNotF1
	
	pshs x,y
		lda #%11000001
		jsr ChibiSound		;Make sound A
		lda #2
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
		lda #2
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
	
	ldd #$2500		;XXYY
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
	
	ldd #$0F08		;XXYY
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
	ldd #$0E0C		;XXYY
	ldy #txtGotHiScore		;Show Highscore Message
	jsr LocateAndPrintString
GameOver_Wait:
	jsr ReadJoystick		;Read in the Joystick	%---1UDLR
	bitb #%00010000			;Fire1 Pressed?
	bne GameOver_Wait
	jmp ShowTitle
	
GameOver_NoScore:			;No highscore, we officially suck!
	ldd #$0F0C		;XXYY
	ldy #txtNoHiScore		;Show Suck Message
	jsr LocateAndPrintString
	jmp GameOver_Wait	

txtGameOver:
	dc.b "GAME OVER",255
txtGotHiScore:	
	dc.b "NEW HISCORE",255
txtNoHiScore:				;Test string (Ucase only)
	dc.b "YOU SUCK!",255	

	
	
;Read in the Joystick	%---FRLDU
ReadJoystick:
	LDB #14
	jsr FMRegRead			;A= %--21RLDU
	tfr a,b
	rts	
	
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
	std TestLocate_End-2
	pshs d,x,y
		ldx #TestLocate					;Source
		LDB #(TestLocate_End-TestLocate)/2	;length (Words)
		jsr SubCpu_DoCmdFull			;Send it to $FC80
	puls d,x,y
	rts
	
TestLocate:
	dc.b $0		;128=Continue last string
	dc.b $0		;Ignored
	dc.b $3		;3=PUT
	dc.b 3		;ByteCount
	dc.b $12,5,5	;$12=Locate X,Y
TestLocate_End:	


	
NewLine:
	lda #13		;NewLine 
PrintChar:			;Send Text To screen
	sta TestPut_End-1
	pshs d,x,y
		ldx #TestPut					;Source
		LDB #(TestPut_End-TestPut)/2	;length (Words)
		jsr SubCpu_DoCmdFull			;Send it to $FC80
	puls d,x,y
	rts

TestPut:
	dc.b $0		;128=Continue last string
	dc.b $0		;Ignored
	dc.b $3		;3=PUT
	dc.b 1		;ByteCount
	dc.b " "	
TestPut_End:	


	
	
CLS:		;Clear the screen
	ldx #TestCLS					;Source
	LDB #(TestCLS_End-TestCLS)/2	;length (Words)
	jsr SubCpu_DoCmd				;Send it to $FC82
	RTS

TestCLS:
	dc.b $02	;02=Erase 
	dc.b 0,0	;(Mode All/Scroll/Page1/Page2), Color
TestCLS_End:		

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Transfer Command data without first two bytes			
SubCpu_DoCmd:			;Transfer $FC82-$FCFF / $D382-$D3FF
	incb
	jsr SubCpu_Halt		;Stop SubCPU (Shared Ram Accessible)
	jsr SubCpu_Send		;Transfer data to shared Ram
	jsr SubCpu_Release	;Release SubCPU (SubCPU will process command)
	rts

;Transfer Command data with first two bytes	
SubCpu_DoCmdFull:		;Transfer $FC80-$FCFF / $D380-$D3FF
	incb
	jsr SubCpu_Halt		;Stop SubCPU (Shared Ram Accessible)
	jsr SubCPU_SendAlt	;Transfer data to shared Ram
	jsr SubCpu_Release	;Release SubCPU (SubCPU will process command)
	rts

;Transfer command daya from X (B = WORDS to send) to the shared ram
SubCpu_send:	
	ldu #$FC82	;First two bytes unused (Error code / Status)
	bra SubCPU_SendAltB
SubCPU_SendAlt:
	ldu #$FC80	;$FC80/D380 - Use Full range
SubCPU_SendAltB:
	ldy X++
	sty U++
	decb		;2 Bytes per transfer
	bne SubCPU_SendAltB
	rts

;Stop SubCPU - Main CPU can now Read/Write $FCxx/$D3xx range
SubCpu_Halt:			;Halt the SubCPU
	LDA $FD05			
	BMI SubCpu_Halt		;Wait for Not Busy
	LDA #$80			;Bit7 = Busy Flag.
	STA $FD05			;Set Halt
SubCpu_HaltWait			
	LDA $FD05
	BPL SubCpu_HaltWait	;Wait For Busy (halt to happen)
	RTS	

;Release SubCPU - Sub CPU will start to try processing 
SubCpu_Release:			;the command at $FC82/$D382
	PSHS A
	LDA #0
	STA $FD05			;Release the SubCpu
	PULS A,PC

;Wait for SubCPU to finish processing it's commands
SubCpu_Wait:
	PSHS	A
SubCpu_Wait2:
	LDA $FD05		 ;Wait for SubCpu to be ready (Bit7 1=busy)
	BMI SubCpu_Wait2 ;Bit7 = Busy Flag.
	PULS A,PC						
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

FMRegRead:	;A=Returned Value B=Regnum
	stb $FD16	;RegNum
	ldb #3
	stb $FD15	
	clr $FD15	;Write #0
	
	lda #9
	sta $FD15
	
	lda $FD16	;Value
	
	clr $FD15	;Write #0
	rts
	
FMRegWrite:	;A=New Value B=Regnum
	stb $FD16	;RegNum
	ldb #3
	stb $FD15	
	clr $FD15	;Write #0
		
	sta $FD16	;Value
	lda #2
	sta $FD15
	
	clr $FD15	;Write #0
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
EnemySprite: dc.b 0
EnemyScale: dc.b 0
EnemySpeed: dc.b 0
EnemySpeedb: dc.b 0
	
EnemyX: dc.w 0
EnemyY: dc.w 0

PlayerX: dc.w 0
PlayerY: dc.w 0

SoundTimeOut: dc.b 0
RandomSeed: dc.w 0


BcdHiscore: ds 4
BcdScore: ds 4
BcdLives: dc.b 0

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
		lda #16
		ldb #160-16
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
	
PixelsPerByte equ 8 ; 3 bitplanes

SpriteData:
    dc.w ($0000/PixelsPerByte)*3 + SpriteBase ;SpriteAddr 0 - Cursor
     dc.b 16,16                            ;XY 
    dc.w ($0100/PixelsPerByte)*3 + SpriteBase ;SpriteAddr 1 - Large 1
     dc.b 32,24                            ;XY 
    dc.w ($0400/PixelsPerByte)*3 + SpriteBase ;SpriteAddr 2 - Large 2
     dc.b 32,32                            ;XY 
    dc.w ($0800/PixelsPerByte)*3 + SpriteBase ;SpriteAddr 3 - Mid 1
     dc.b 24,16                            ;XY 
    dc.w ($0980/PixelsPerByte)*3 + SpriteBase ;SpriteAddr 4 - Mid 2
     dc.b 24,24                            ;XY 
    dc.w ($0BC0/PixelsPerByte)*3 + SpriteBase ;SpriteAddr 5 - Small 1
     dc.b 16,8                             ;XY 
    dc.w ($0C40/PixelsPerByte)*3 + SpriteBase ;SpriteAddr 6 - Small 2
     dc.b 16,16                            ;XY 

	

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
	
	
ShowSprite:	
	ldx #SendCMDPutPos		;Dest Command
	
	lda #0			
	ldb z_b 
	aslb			;X*4
	rola
	aslb
	rola
	std 0,x			;Xpos

	addb 2,y		
	bcc ShowSpriteT
	inca
ShowSpriteT:			
	subd #1
	std 4,x			;Xend
	
	lda #0
	ldb z_c			
	std 2,x			;Ypos
	
	addb 3,y		
	subd #1		
	std 6,x			;Yend
	
	ldx y			;Source Address
		
	ldb #3			;96 bytes per block 4 blocks=32x32 px max
					;We're sending too much data for small sprites
					;But FM7 firmware doesn't care!
	pshs b
		pshs x
			ldx #SendCMDPut						;Source
			LDB #(SendCMDPut_End-SendCMDPut)/2	;length (Words)
			jsr SubCpu_Halt		;Stop Sub CPU
			jsr SubCpu_SendAlt	;Send it to $FC80
		puls x
		LDB #48					;Words to Send
		jsr SubCPU_SendAltB		;Send 48 Words from X
		jsr SubCpu_Release		;Release Sub CPU
	puls b
	
SendAgain:			;Send Other blocks
	pshs b
		pshs x
			ldx #SendCMDContinue	;Continue sprite
			LDB #(SendCMDContinue_End-SendCMDContinue)/2
			jsr SubCpu_Halt		;Stop Sub CPU
			jsr SubCpu_SendAlt	;Send it to $FC80
		puls x
		LDB #48					;Words to Send
		jsr SubCPU_SendAltB		;Send 48 Words from X
		jsr SubCpu_Release		;Release Sub CPU
	puls b
	decb						;Repeat until all blocks sent
	bne SendAgain				;More Blocks to send
	rts
	
SendCMDPut:
	dc.b 0,128		;(128=Multiblock)
	dc.b $1E		;$1E=PUT BLOCK2
SendCMDPutPos:	dc.w 10,10,10+15,10+15;(x,y)-(x,y)
	dc.b 0			;unused
	dc.b 4			;Func (0=PSET / 4=XOR)
	dc.b 96			;Bytes
SendCMDPut_End:	
	
SendCMDContinue:
	dc.b 0,128	;More Data
	dc.b $64	;$64=CONTINUE
	dc.b 96		;Bytes
SendCMDContinue_End:


SpriteBase:
	binclude "\ResAll\SuckShootFm7.raw"
	
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