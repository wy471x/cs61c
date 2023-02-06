
CursorX equ $7000		;Ram For Cursor Routines
CursorY equ $7001
	
	org $C000			;Cartridge Start Address
	
	LDS $8000			;Init Stack pointer
	
	clr CursorX			;Zero Position of next Char
	clr CursorY
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	ldy #Hello			;255 terminated Message
	jsr PrintString		;Show String to screen

InfLoop:
	jmp InfLoop			;Infinite Loop
	
Hello:						;255 terminated string
	dc.b "@HellO WORLD!?",255

	
PrintString:			;Print 255 terminated string from Y
	lda ,Y+
	cmpa #255	
	beq PrintStringDone	;read 255? then done
	jsr printchar		;Print Char to screen
	jmp PrintString
PrintStringDone:	
	rts	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Address= $0400 + (Ypos * 32) + Xpos
printchar:
	pshs x,d
		pshs a
			lda CursorY 
			clrb
			ANDCC #%11111110	;Clear Carry
			lsra		;128
			rorb
			lsra		;64
			rorb
			lsra		;32
			rorb
			adda #$04
			addb CursorX 
			exg x,d			;X now contains address
		puls a
		cmpa #"`"
		blt CharOK2
		suba #32			;We have no lowercase!
		bra CharOK
CharOK2:
		cmpa #"@"
		bge CharOK
		adda #64			;Fix chars <64 so they aren't inverted
CharOK:
		sta X				;Store to address X
		lda CursorX
		inca
		sta CursorX
		cmpa #32
		bne NoNewLine
		jsr NewLine
NoNewLine:
	puls x,d
	rts	
	
NewLine:
	clr CursorX				;Clear Xpos
	inc CursorY				;Inc Ypos
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Rom Footer - Pad to 16k

	org $FFFE
	dc.w $C000		;$FFFE		Reset Vector 
