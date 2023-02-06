	
	include "\srcALL\v1_header.asm"

;Prep the joystick
	
;Select Joystick Right
	lda #%00000100	;CB2 (Bit 3=Joy 0=R / 1=L)
	sta $FF03		;P0CRB
	
;Turn of DAC sound (need for Joy Testing)
	lda #%00000100	
	sta $FF23		;Bit3: Sound Source Enable (1=on)
	
KeyTest:
	lda #0
	sta CursorX
	sta CursorY

;Read in the keyboard		
	
	lda #%11111110			;Column to read (0=selected)
NextColumn:	
	pshs a
		sta $FF02			;PIA0-B Data (Keycol)
		
		lda $FF00			;PIA0-A Data (Key Row buttons)
		
		jsr ShowBits		;Show the Register as bits
		jsr NewLine
	puls a
	rola					;Move 0 to left
	inca					;Set bottom bit 
	cmpa #255
	bne NextColumn			;Repeat until %11111111
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	jsr NewLine
	jsr NewLine
	

;$FF03 B3	$FF01 B3
	
;0			0		Right - X-axis
;0			1		Right - Y-axis
;1			0		Left - X-axis
;1			1		Left - Y-axis


	;Bit 7=Over test Value (written to FF20)
	;Bit 0=JoyR Fire
	;Bit 1=JoyL Fire

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
;Read in the Joystick	

	clrb			;We'll build up the result in B
		
	lda #%11111111	;Disable Keyboard
	sta $FF02

;X axis Tests	
	
	lda #%00000100	;Bit3=0 X-axis
	sta $ff01				;PIA0-A Control

		; 543210--	TestVal
	lda #%11100000			;Test DAC>56 (Right)
	sta $FF20				;Store test value into DAC
	lda $FF00				;Bit 7=Test Result
	
	jsr ShowBits			;Show the Register
	rora			;Fire (Bit 0)
	rolb
	lda $FF00
	rola			;Right (True if Bit 7=1)
	rolb
	
		; 543210--	TestVal
	lda #%00011100			;Test DAC>7 (Left)
	sta $FF20				;Store test value into DAC
	lda $FF00				;Bit 7=Test Result
	
	jsr ShowBits			;Show the Register
	rola			;Left (True if Bit 7=0)
	rolb
	jsr newline

;Y axis Tests	
	
	lda #%00001100	;Bit3=1 Y-axis
	sta $ff01				;PIA0-A Control
	
		; 543210--	TestVal
	lda #%11100000			;Test DAC>56 (Down)
	sta $FF20				;Store test value into DAC
	lda $FF00				;Bit 7=Test Result
	
	jsr ShowBits			;Show the Register
	rola			;Down (True if Bit 7=1)
	rolb
	
		; 543210--	TestVal
	lda #%00011100			;Test DAC>7 (Up)
	sta $FF20				;Store test value into DAC
	lda $FF00				;Bit 7=Test Result
	
	jsr ShowBits			;Show the Register
	rola
	rolb			;Up (True if Bit 7=0)
		
	eorb #%11101010			;B contains %---FUDLR
	jsr newline
	tfr b,a
	jsr ShowBits			;Show the Register
	
	jmp KeyTest
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
	
ShowBits:
	pshs d,x,cc
		sta $00
	
		ldb #8
ShowBitsAgain:
		rol $00
		bcs ShowBits1
		lda #'0'
		jsr PrintChar
		bra ShowBitsDone
ShowBits1:
		lda #'1'
		jsr PrintChar
ShowBitsDone:		
		decb 
		bne ShowBitsAgain
		lda #" "
		jsr printchar
	puls d,x,cc
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	
	include "\srcALL\v1_Footer.asm"
	
	
	