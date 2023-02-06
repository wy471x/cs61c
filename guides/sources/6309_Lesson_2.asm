	
	include "\srcALL\v1_header.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	ldq #$C42100FF
	jsr ShowFlags
	jsr MonitorS
	
	
	;jmp Rotates
	;jmp LogicalShifts
	;jmp ArithematicShifts
	;jmp TestsCompares
	jmp LogicalOps
	;jmp MathsOps
	
Rotates:	
	ldx #5
TestRor:	
		rord			;Rotate with carry Right
		jsr ShowFlags
		rorw
	jsr MonitorS
	LEAX -1,X			;Decrease X 
	bne TestRor
	
	jsr NewLine
	
	ldx #5
TestRol:	
		rolw			;Rotate with carry Left
		jsr ShowFlags
		rold	
	jsr MonitorS
	LEAX -1,X			;Decrease X 
	bne TestRol
	
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
LogicalShifts:	
	ldx #5
Testlsr:	
		lsrd			;Logical Shift Right
		jsr ShowFlags
		;lsrw
		rorw
	jsr MonitorS
	LEAX -1,X			;Decrease X 
	bne Testlsr
	
	jsr NewLine
	
	ldx #5
TestLsl:	
		addr w,w		;Effectively shift left
		jsr ShowFlags
		;lsld
		rold
	jsr MonitorS
	LEAX -1,X			;Decrease X 
	bne TestLsl
	
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
ArithematicShifts:
		ldx #5
TestAsr:	
		asrd			;Logical Shift Right
		jsr ShowFlags
		;lsrw
		rorw
	jsr MonitorS
	LEAX -1,X			;Decrease X 
	bne TestAsr
	
	jsr NewLine
	
	ldx #5
TestAsl:	
		addr w,w		;effectively shift left
		jsr ShowFlags
		;asld
		rold	
	jsr MonitorS
	LEAX -1,X			;Decrease X 
	bne TestAsl
	
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestsCompares:		
	tste				;Set Flags like CMP 0
	jsr ShowFlags	
	tstf
	jsr ShowFlags	
	jsr NewLine
	tstd				
	jsr ShowFlags	
	tstw
	jsr ShowFlags	
	;We have no tstQ
	
	jsr NewLine
	jsr NewLine
	
	cmpe #$FF
	jsr ShowFlags		;Compares register to a value
	cmpf #$FF
	jsr ShowFlags	
	jsr NewLine
	cmpd #$C421
	jsr ShowFlags	
	cmpw #$C421
	jsr ShowFlags	
	;We have no cmpQ
	
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
LogicalOps:
	ldw #$F03E
	jsr MonitorS

	eord #$F0F0		;Eor D with immediate
	eor f,e			;Eor registers. E=E eor F
	jsr MonitorS
	
	andd #$F0F0		;And D with immediate
	and f,e			;And registers E=E and F
	jsr MonitorS
	
	ord #$F0F0		;Or D with immedate
	orr f,e			;OR registers E=E eor F
	jsr MonitorS
	
	
	
	ldq #$CCCCCCCC
	stq $7100
	
	ldy #8				;Bytes to dump
	ldx #$7100			;Address to dump
	jsr Memdump
	ldx #$7100
		
	eim #$F0,0,x		;Eor Immediate $F0 with Memory (X+0)
	aim #$F0,1,x		;And Immediate $F0 with Memory (X+1)
	oim #$F0,2,x		;Oim Immediate $F0 with Memory (X+2)
	
	tim #$11,3,x		;Bit Test Immediate $11 (Set flags like AND)
	
	jsr ShowFlags
	
	ldy #8				;Bytes to dump
	ldx #$7100			;Address to dump
	jsr Memdump
	
	
	jmp InfLoop
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

MathsOps:	
	ldw #$8421
	jsr MonitorS
	
	SexW				;Sign Extend W into D (16 bit W to 32 bit Q)
	jsr MonitorS
	
	negd				;Negate D
	jsr MonitorS
		
	jsr NewLine
	
	jsr MonitorS
	come				;Complement 8 bit register E
	comf				;Complement 8 bit register F
	jsr MonitorS
	comd				;Complement 16 bit register D
	comw				;Complement 16 bit register W
	jsr MonitorS
	
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
InfLoop:
	ifdef BuildVTX
		jsr DrawVectrexScreen	;Wait for Vsync and Redraw screen
	endif
	jmp InfLoop			;Infinite Loop
	
TestMemory:
	dc.l $12345678
	
PrintString:			;Print 255 terminated string
	lda ,Y+
	cmpa #255
	beq PrintStringDone
	jsr printchar
	jmp PrintString
PrintStringDone:	
	rts	
	
MonitorS:
	
	pshs d,x,cc
			pshs x
				exg x,d
				lda #"D"
				jsr ShowReg
				ifdef CPU6309
					tfr w,x
					lda #"W"
					jsr ShowReg
				endif
								
			puls x
			lda #"X"
			jsr ShowReg
			
		jsr NewLine
	puls d,x,cc
	rts
	

ShowFlags:
	pshs d,x,cc
		tfr cc,a
		sta $00
		ldb #8
		ldx #FlagLabels-1
ShowFlagsAgain:
		rol $00
		bcs ShowFlagsY
		lda #'-'
		jsr PrintChar
		bra ShowFlagsDone
ShowFlagsY:
		lda b,x
		jsr PrintChar
ShowFlagsDone:		
		decb 
		bne ShowFlagsAgain
		
		lda #' '
		jsr PrintChar
	puls d,x,cc
	rts
	
FlagLabels:
	dc.b 'C','V','Z','N','I','H','F','E'
	;dc.b 'E','F','H','I','N','Z','O','C'
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	
	include "\srcALL\v1_Footer.asm"
	
	
	