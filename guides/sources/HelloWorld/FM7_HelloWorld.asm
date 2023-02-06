
;2b0 file header

	PADDING off
	
	ORG $2000-21
	DC.B $50,$52,$4f,$47,$00,$00,$00,$00 ;Asci FileName "PROG____"
	dc.b $00,$00,$02,$00,$00		;0,0,2,0,0
	dc.b $58,$4d,$37				;Ascii: "XM7" (fixed)
	dc.b 0
	DC.W ProgramEnd-ProgramStart	;Size
	DC.W ProgramStart 				;Load Addr
	
	
;Pointers to Basic ROM function
printchar equ $D08E		

ProgramStart: 			;Program starts at $2000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	
	ldy #Hello			;255 terminated Message
	jsr PrintString		;Show String to screen
	
InfLoop:
	jmp InfLoop			;Infinite Loop
	
Hello:					;255 terminated string
	dc.b "HellO WORLD!?",255
	

PrintString:			;Print 255 terminated string from Y
	lda ,Y+
	cmpa #255	
	beq PrintStringDone	;read 255? then done
	jsr printchar		;Print Char to screen
	jmp PrintString
PrintStringDone:	
	rts	
	
NewLine:		;Start A new Line
	pshs d
		lda #13				;Print Chr 13 (CR)
		jsr printchar
		lda #10				;Print Chr 10 (NL)
		jsr printchar
	puls d,pc				;Return
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
ProgramEnd:

;Program Footer
	dc.b $FF,0
	dc.b $00
	dc.w ProgramStart	;Exec Address
	dc.b $1a 			;EOF
	