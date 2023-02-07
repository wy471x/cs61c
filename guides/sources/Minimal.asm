	
	include "\srcALL\v1_header.asm"
	
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	ldD #$1234			#;Test Value
	jsr Monitor			#;Show the Register
	
	ldy #32				#;Bytes to dump
	ldx #$C000			#;Address to dump
	jsr Memdump
	
	ldy #Hello			#;255 terminated Message
	jsr PrintString		#;Show String to screen
	
InfLoop:
	ifdef BuildVTX
		jsr DrawVectrexScreen	#;Wait for Vsync and Redraw screen
	endif
	jmp InfLoop			#;Infinite Loop
	
PrintString:			#;Print 255 terminated string
	lda ,Y+
	cmpa #255
	beq PrintStringDone
	jsr printchar
	jmp PrintString
PrintStringDone:	
	rts	
	
Hello:
	dc.b "HellO WORLD!?",255
	
#;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	
	include "\srcALL\v1_Footer.asm"
	
	
	