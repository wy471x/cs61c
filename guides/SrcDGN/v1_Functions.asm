
printchar:
	pshs x,d
		pshs a
			lda CursorY 
			clrb
			ANDCC #%11111110	;Clear Carry
			lsra	;128
			rorb
			lsra	;64
			rorb
			lsra	;32
			rorb
			adda #$04
			addb CursorX 
			;lda #$04
			;pshs d
			;puls X
			exg x,d
			
		puls a
		cmpa #"`"
		blt CharOK2
		suba #32			;We have no lowercase!
		bra CharOK
	CharOK2:
		cmpa #"A"
		bge CharOK
		adda #64			;Fix characters <64 so they aren't inverted
	CharOK:
		sta ,X
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
	clr CursorX
	inc CursorY
	rts
	
Cls:
	clr CursorX
	clr CursorY
	rts