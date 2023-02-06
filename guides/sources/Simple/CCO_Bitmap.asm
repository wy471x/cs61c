
	Padding off			;Dont pad to even boundaries
	org $C000			;Start of our cartridge

ProgStart:	
	LDS $8000			;Init Stack pointer
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Turn On CoCo3 function 
		 ;CMIFRSr-
	lda #%01000000	;M=Enable MMU Mem Mapper C=0 Coco 3 mode
	sta $FF90
		;-MT-----m - m=Task 0/1
	lda #%00000000	;Task 0 ($FFA0-7 control bank mapping)
	sta $FF91

;Select 256x192 @ 16 color
		; P-DMFLLL		L=Lines per row / F=Freq (60/50) 
						;M=Mono D=Descender P=Planes(Text/Graphics)
	lda #%10000000	;Vmode Bitplane
	sta $FF98
	
		; -LLBBBCC	C=Colors (2=16 col) B=Bytes per row (6=128) 
	lda #%00011010		;L=Lines (0=192)
	sta $FF99		;Set Screen mode.
	
	ldx #$C000 		;Screen Base /8 = $60000/8=$C000
	stx $FF9D		;Set Screen Base

	
	jsr CLS				;Clear our screen
	
	ldx #40				;Xpos
	ldy #40				;Ypos
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
	leay -2,y		;Y=Y+2
JoyNotUp:	
	bitb #%00000010		;Down pressed?
	bne JoyNotDown
	cmpY #192-8			;At bottom of screen?
	beq	JoyNotDown
	leay 2,y		;Y=Y+2
JoyNotDown:	
	bitb #%00000100		;Left pressed?
	bne JoyNotLeft
	cmpX #0				;At far left of screen?
	beq	JoyNotLeft
	leax -1,x		;X=X-1
JoyNotLeft:	
	bitb #%00001000		;Right pressed?
	bne JoyNotRight
	cmpX #128-4			;At far right of screen?
	beq	JoyNotRight
	leax 1,x		;X=X+1
JoyNotRight:	

	jsr ShowSprite		;Show new sprite pos
			
	lda #12
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
			ldb #8/2		;Width in bytes (16 Color)
			pshs y
NextByte:
				lda x+		;Transfer a byte
				eora y		;Eor with screen byte
				sta y+		;Store new byte
				
				decb
				bne NextByte ;Repeat for next byte
			puls y
			jsr GetNextLine	;Move Down a line
		puls b	
		decb
		bne NextLine		;Repeat for next line
	puls y,x
	rts	
	
CLS:
	ldy #0
	jsr CLSB	;Clear First chunk
	ldy #64
	jsr CLSB	;Clear Second chunk
	ldy #128
				;Clear Third Chunk
CLSB:	
	ldx #0
	jsr GetScreenPos	;Page in Ram are
	lda #0
ClsAgain:
	sta y+
	cmpy #$4000			;Clear $2000 bytes 
	bne ClsAgain
	rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Note: Each Bank is $2000 / 8k (256x192 4bpp = 24k total screen)
GetNextLine:			
	tfr y,d
	addd #128			;Move down a line
	tfr d,y
	cmpy #$4000			;See if we've gone over a bank limit
	bcs GetNextLineDone
	inc $FFA1			;Move Down a line
	subd #$2000			;Move to top of bank
	tfr d,y
GetNextLineDone:	
	rts

GetScreenPos: 	;Y=ram address of (X,Y)
;Calc Bank Number
	tfr y,d
	andb #%11000000	;Bank No
	andcc #%11111110	;And doesn't set carry :-(
	rolb
	rolb
	rolb
	addb #$30 		;$60000
	stb $FFA1		;Set bank at address $2000-$4000
	
;Calc Address in bank	
	tfr y,d
	andb #%00111111
	lda #128	
	mul				;Ypos * ScreenWidth
	addd #$2000		;Add Screen Base
	tfr d,y
	exg y,x
	tfr y,d
	abx				;Add Xpos
	tfr x,y	
	rts				;Result in Y
		
	


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






Bitmap:	;1 nibble per color
	DC.B $00,$11,$11,$00     ;  0
	DC.B $01,$11,$11,$10     ;  1
	DC.B $11,$31,$13,$11     ;  2
	DC.B $11,$11,$11,$11     ;  3
	DC.B $11,$11,$11,$11     ;  4
	DC.B $11,$21,$12,$11     ;  5
	DC.B $01,$12,$21,$10     ;  6
	DC.B $00,$11,$11,$00     ;  7

	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Rom Footer - Pad to 16k

	org $FFFE
	dc.w $C000		;$FFFE		Reset Vector

	