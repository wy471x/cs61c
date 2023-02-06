
	org $4000-5	
	
	db $00					;Preamble flag
	dw ProgEnd-ProgStart	;Length
	dw ProgStart			;Load address

ProgStart:	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;Text after a semicolon is comments, you don't need to type it in
CursorX equ $70				;Ram For Cursor Xpos
CursorY equ $71				;Ram For Cursor Ypos
	

	LDS $8000				;Init Stack pointer
	clr CursorX				;Zero Position of next Char
	clr CursorY
	
	ldy #txtHello				;255 terminated Message
	jsr PrintString			;Show String to screen
InfLoop:
	jmp InfLoop				;Infinite Loop
	
txtHello:						;255 terminated string
	dc.b "@HellO WORLD!?",255

PrintString:				;Print 255 terminated string from Y
	lda ,Y+
	cmpa #255	
	beq PrintStringDone		;read 255? then done
	jsr PrintChar			;Print Char to screen
	jmp PrintString
PrintStringDone:	
	rts	
	
PrintChar:
	pshs x,d				;Address= $0400 + (Ypos * 32) + Xpos
		pshs a
			lda CursorY 	;D= 16 bit AB pair
			clrb
			lsra		;128
			rorb
			lsra		;64
			rorb
			lsra		;32
			rorb
			adda #$04		;$0400 VRAM base 
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
		inc CursorX
	puls x,d
	rts	
	
NewLine:
	clr CursorX				;Clear Xpos
	inc CursorY				;Inc Ypos
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;

ProgEnd:					
	
	db $FF					;Postamble flag
	dw $0000 				;Unused
	dw ProgStart 			;Exec address
	
	