
	Padding off			;Dont pad to even boundaries
	org $C000			;Start of our cartridge

ProgStart:	
	LDS $8000			;Init Stack pointer
	
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
	
;Clear Vram
	ldy #$1800			;Screen Bytes
ClsAgain:	
	clr $3FF,y			;Destination
	leay -1,y			;Dec Y
	bne ClsAgain		;Repeat
	
	
	ldx #1				;Xpos
	ldy #0				;Ypos
	jsr ShowSprite		;Show initial sprite position
	
InfLoop:	
	jsr ReadJoystick	;Read in the Joystick	%---FUDLR
	andb #%00011111
	cmpb #%00011111		;Wait for keypress
	beq InfLoop
	
	pshs b
		jsr ShowSprite	;Remove old sprite
	puls b
	bitb #%00000001
	bne JoyNotUp		;Up Pressed?
	cmpY #0		
	beq	JoyNotUp		;At top of screen?
	leay -4,y		;Y=Y+4
JoyNotUp:	
	bitb #%00000010		;Down pressed?
	bne JoyNotDown
	cmpY #192-8			;At bottom of screen?
	beq	JoyNotDown
	leay 4,y		;Y=Y+4
JoyNotDown:	
	bitb #%00000100		;Left pressed?
	bne JoyNotLeft
	cmpX #0				;At far left of screen?
	beq	JoyNotLeft
	leax -1,x		;X=X-1
JoyNotLeft:	
	bitb #%00001000		;Right pressed?
	bne JoyNotRight
	cmpX #32-2			;At far right of screen?
	beq	JoyNotRight
	leax 1,x		;X=X+1
JoyNotRight:	

	jsr ShowSprite		;Show new sprite pos
	
	lda #32
Delay:	
	decb
	bne Delay			;Delay loop
	deca
	bne Delay		
	
	jmp InfLoop			;Repeat
	
	
	
ShowSprite:
	pshs y,x
		jsr GetScreenPos	;Calculate screen address
		ldx #Bitmap			;Bitmap source	
		ldb #8				;Height in lines
	NextLine:
		pshs b
			ldb #8/4		;Width in bytes (2 Color)
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
		bne NextLine		;Repeat for next line
	puls y,x
	rts	
	
	
GetScreenPos: 	;Y=ram address of (X,Y)
	tfr y,d
	lda #32		;Screen width	
	mul			;Ypos * ScreenWidth
	addd #$400	;Add Screen Base
	tfr d,y
	exg y,x		;X->Y
	tfr y,d		;Y->D (effectively X->B)
	abx			;Add Xpos (add B to X)
	tfr x,y	
	rts			;Result in Y
	

;$FF03 B3	$FF01 B3
	
;0			0		Right - X-axis
;0			1		Right - Y-axis
;1			0		Left - X-axis
;1			1		Left - Y-axis


	;Bit 7=Over test Value (written to FF20)
	;Bit 0=JoyR Fire
	;Bit 1=JoyL Fire

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


	;2 bit per pixel
Bitmap:
	DC.B %00000101,%01010000     ;  0
	DC.B %00010101,%01010100     ;  1
	DC.B %01011101,%01110101     ;  2
	DC.B %01010101,%01010101     ;  3
	DC.B %01010101,%01010101     ;  4
	DC.B %01011001,%01100101     ;  5
	DC.B %00010110,%10010100     ;  6
	DC.B %00000101,%01010000     ;  7

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Rom Footer - Pad to 16k

	org $FFFE
	dc.w $C000		;$FFFE		Reset Vector

	