	include "\srcALL\v1_header.asm"
	
	jmp TestLogicalOps
	;Jmp TestRotation
	;Jmp TestSEX			;OOh er!
	;jmp TestBits
	;jmp TestDaa
	;Jmp TestMult
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
TestLogicalOps:
	lda #%11001101
	ldb #$CD
	pshs d,cc
		jsr MonitorACCBits
		anda  #%11110000	;Return 1 when both bits 1, else 0
		andb  #%11110000	;Return 1 when both bits 1, else 0
		andcc #%11110000	;Return 1 when both bits 1, else 0
		jsr MonitorACCBits
		jsr NewLine
	puls d,cc
	pshs d,cc
		jsr MonitorACCBits
		ora  #%00001111		;Return 1 when either bit 1, else 0
		orb  #%00001111		;Return 1 when either bit 1, else 0
		orcc #%00001111		;Return 1 when either bit 1, else 0
		jsr MonitorACCBits
		jsr NewLine
	puls d,cc
	pshs d,cc
		jsr MonitorACCBits
		eora #%00001111		;Return opposite when bit 1
		eorb #%00001111		;Return opposite when bit 1
		jsr MonitorACCBits
		jsr NewLine
	puls d,cc
	pshs d,cc
		jsr MonitorACCBits
		coma				;Flip bits
		comb				;Flip bits
		jsr MonitorACCBits
		jsr NewLine
	puls d,cc
	lda #10
	ldb #-10
	jsr MonitorACCBits
	nega					;Negate number
	negb					;Negate number	
	jsr MonitorACCBits
	nega					;Negate number
	negb					;Negate number
	jsr MonitorACCBits
	
	jmp InfLoop	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestRotation:				;Unrem one of the shift operations.
	lda #%10111001
	ldb #7
	pshs d
TestRotationAgain:	
		jsr MonitorACCBits

		;rora				;Rotate Right

		asra				;Arithematic Shift Right
		
		;lsra				;Logical Shift Right
		
		decb
		bne TestRotationAgain
	puls d
	jsr NewLine
TestRotationAgainB:	
	jsr MonitorACCBits
	
	;rola					;Rotate Left
	
	asla					;Aritematic Shift Left
	
	;lsla					;Logical Shift Left
	
	decb
	bne TestRotationAgainB
	
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

TestSEX:
	lda #$66
	ldb #64
	jsr MonitorD
	sex 			;Sign EXtend B->D (B->AB)
	jsr MonitorD		;Bits of A to top bit of B
	
	jsr NewLine

	lda #$66
	ldb #-64
	jsr MonitorD
	sex 			;Sign EXtend B->D (B->AB)
	jsr MonitorD		;Bits of A to top bit of B
	
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
TestBits:
	lda #%00000011
	bita #%00000001		;logical AND (only changes Flags)
	jsr MonitorACCBits	
	bita #%00000010		;logical AND (only changes Flags)
	jsr MonitorACCBits	
	bita #%00000100		;logical AND (only changes Flags)
	jsr MonitorACCBits	
	bita #%00000011		;logical AND (only changes Flags)
	jsr MonitorACCBits	
	bita #%10000000		;logical AND (only changes Flags)
	jsr MonitorACCBits	
	
	jsr NewLine
	
	lda #0
	tsta				;Set Flags From A
	jsr ShowFlagsN
	lda #1
	tsta				;Set Flags From A
	jsr ShowFlagsN
	lda #-1
	tsta				;Set Flags From A
	jsr ShowFlagsN
	
	
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		

TestDaa
	ldb #16
	lda #08
DAA_Again:
	jsr ShowAN
	
	inca				;Test #1
	;adda #2			;Test #2
	
	daa		;Decimal Adjust Accumulator (1 nibble per digit)
	
	decb 
	bne DAA_Again
	
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
TestMult:
	lda #$10
	ldb #$69
	jsr MonitorD
	
	mul					;Multiply... D=A*B
	
	jsr MonitorD


InfLoop:
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
ShowFlagsN:
	pshs d,x,cc	
		jsr ShowFlags
		jsr NewLine
	puls d,x,cc
	rts
	
ShowFlags:
	pshs d,x,cc
		pshs cc
			lda #"C"
			jsr PrintChar
			jsr ShowRegName
		puls cc	
	
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
		lda #" "
		jsr printchar
	puls d,x,cc
	rts
	
FlagLabels:
	dc.b 'C','O','Z','N','I','H','F','E'
	
ShowBits:
	pshs d,x,cc
		sta $00
	
		lda #"A"
		jsr ShowRegName
		
		
		ldb #8
		ldx #FlagLabels-1
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

ShowAN:	
	jsr ShowA
	jsr NewLine
	rts
ShowA:
	pshs d,x,cc
		tfr d,x
		lda #"A"
		jsr ShowRegName
		jsr ShowRegNibblePair
		lda #" "
		jsr printchar
		
	puls d,x,cc	
	rts
	
	
ShowB:
	pshs d,x,cc
		exg a,b
		tfr d,x
		lda #"B"
		jsr ShowRegName
		jsr ShowRegNibblePair
		lda #" "
		jsr printchar
	puls d,x,cc	
	rts
	
	
MonitorACCBits:
	pshs cc,d
		
		jsr ShowBits
		jsr ShowB
		jsr ShowFlags
		jsr NewLine
	puls cc,d
	rts	


MonitorD:
	pshs d,x,cc
			exg x,d
			lda #"D"
			jsr ShowReg
			jsr NewLine
	puls d,x,cc
	rts	
	
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	include "\srcALL\v1_Footer.asm"