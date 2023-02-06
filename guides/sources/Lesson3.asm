	include "\srcALL\v1_header.asm"

	;jmp TestJsrBsr
	;jmp TestAdcSbc
	
	;jmp TestCarry
	;jmp TestCmpEqNe
	;jmp TestUnsigned
	;jmp TestSigned
	;jmp TestNegativePositive
	;jmp TestOverflow
	jmp TestAlwaysNever
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	

TestJsrBsr:
	bsr SubTest		;Short distances only Branch to Sub (-128 to +127)
	
	;lbsr SubTest	;Long distance Branch to Sub (Same as JSR)
	
	jmp InfLoop
	
	;ds.b 256			;Long branch test (BSR will fail)
	
SubTest:
	lda #'!'
	jsr PrintChar
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

TestAdcSbc:
	lda #6
	sta $1			;Counter
	lda #1			;High Byte
	ldb #253		;Low  Byte
	
;Add with Carry Test
AdcRep:	
	addb #1			;Add 1 to Low Byte 
	jsr MonitorB
	jsr MonitorCC
	adca #0			;Add 0 + Carry to High byte
	jsr MonitorA
	jsr NewLine
	dec $1			;Decrease counter and repeat 
	bne AdcRep
	
	jsr NewLine
	pshs d
		lda #6		;Reset the loop counter
		sta $1
	puls d
	
;Subtract with Carry Test	
SbcRep:	
	subb #1			;Subtract 1 from the Low Byte
	jsr MonitorB
	jsr MonitorCC
	sbca #0			;Subtract 0 + Carry from High byte
	jsr MonitorA		;(Carry acts as Borrow)
	jsr NewLine
	dec $1			;Decrease counter and repeat 
	bne SbcRep
	
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
TestCarry:
	lda #253
	adda #1				;254
	jsr MonitorACC
	adda #1				;255
	jsr MonitorACC
	adda #1				;0 - Carry!
	jsr MonitorACC
	adda #1				;1 - Rem this out to cause a carry
	jsr MonitorACC
	
	bcc ShowNc			;Branch if Carry Clear (NC)
	
	bcs ShowC			;Branch if Carry Set (C)
	
	jmp InfLoop
	
ShowNc
	lda #'N'
	jsr PrintChar
ShowC
	lda #'C'
	jsr PrintChar
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
TestCmpEqNe:
	lda #1
	ldb #2
	ldx #3
	ldy #4
	ldu #5
	
	cmpa #1					;Compare A
	jsr MonitorCCNL	
	cmpb #22				;Compare B
	jsr MonitorCCNL
	cmpd #$0102				;Compare D (AB)
	jsr MonitorCCNL
	cmpx #$33				;Compare X
	jsr MonitorCCNL
	cmpy #4					;Compare Y
	jsr MonitorCCNL
	cmps #4					;Compare S
	jsr MonitorCCNL
	
	cmpu #$55				;Compare U (NE Test)
	cmpu #$5				;Compare U (EQ Test)
	jsr MonitorCCNL
	
	beq ShowEq				;Branch on Z flag Set
	bne ShowNe				;Branch on Z flag clear
	
	;lbeq ShowEq				;Long Branch on Z flag Set
	;lbne ShowNe				;Long Branch on Z flag clear
		
	jmp InfLoop
	;ds.b 2048				;Long branch test
ShowNe	
	lda #'!'
	jsr PrintChar
ShowEq	
	lda #'='
	jsr PrintChar
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
TestUnsigned:
	ldd #$7000			;28672
	
	;cmpd #$7000		;=
	;cmpd #$7800		;D < 30720
	;cmpd #$8000		;D < 32768  (-32768 Signed)
	cmpd #$6000			;D > 24576
	
	bhi ShowGreater		;Branch if Higher (Unsigned)
	bhs ShowGreater		;Branch if Higher or Same (Unsigned)
	
	bls ShowLess		;Branch if Lower or Same (Unsigned)
	blo ShowLess		;Branch if Lower (Unsigned)
	
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
TestSigned:
	ldd #$7000			;28672
	
	;cmpd #$7000		;=
	;cmpd #$7800		;D < 30720
	cmpd #$8000		;D > -32768 (32768 Unsigned)
	;cmpd #$6000		;D > 24576
	
	;If we accidentally use BLO (treating it as an unsigned number)
	;We'll get the wrong answer
	;blo ShowLess		;Branch if Lower (Unsigned)
	
	bgt ShowGreater		;Branch if Greater Than (Signed)
	bge ShowGreater		;Branch if Greater or Even (Signed)
	
	blt ShowLess		;Branch if Less Than (Signed)
	ble ShowLess		;Branch if Less or Even (Signed)
	
	jmp InfLoop
	
ShowGreater:
	lda #'>'
	jsr PrintChar
	jmp InfLoop
ShowLess:
	lda #'<'
	jsr PrintChar
	jmp InfLoop	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
	
TestNegativePositive:
	lda #-1					;Negative Number
	jsr MonitorACC
	lda #1					;Positive Number
	jsr MonitorACC
	jsr NewLine
	
	lda #6
	sta $10					;Loop Count
	lda #124
TestNegativePositiveAgain:	
	inca					;Increse A
	jsr MonitorACC
	dec $10
	bne TestNegativePositiveAgain
	
	jsr NewLine
	
	ldd #-100				;Negative Number
	jsr MonitorDCC
	ldd #100				;Positive Number
	jsr MonitorDCC
	
	bmi	BranchMinus			;Branch if top bit 1 (N flag)
	bpl	BranchPlus			;Branch if top bit 0 (N flag)
	
	jmp InfLoop
BranchMinus:
	lda #'-'
	jsr PrintChar
	jmp InfLoop
BranchPlus:
	lda #'+'
	jsr PrintChar
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
TestOverflow:
	lda #$7D			;			 125
	
	inca				;Add 1 = $7E 126
	jsr MonitorDCC
	inca				;Add 1 = $7F 127
	jsr MonitorDCC
	inca				;Add 1 = $80 -128 oVerflow!
	jsr MonitorDCC
	;inca				;Add 1 = $81 -127
	jsr MonitorDCC
	
	bvs ShowOverflow	;Branch if Overflow Set
	bvc ShowNoOverflow	;Branch if Overflow Clear
	
	jmp InfLoop
	
ShowNoOverflow:
	lda #'N'
	jsr PrintChar
	jmp InfLoop
ShowOverflow:
	lda #'V'
	jsr PrintChar
	jmp InfLoop
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
TestAlwaysNever:	
	brn ShowNever		;Branch Never
	bra	ShowBranch		;Branch Always
	jmp InfLoop

ShowNever:
	lda #'N'
	jsr PrintChar
	jmp InfLoop
ShowBranch:
	lda #'B'
	jsr PrintChar
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
InfLoop:
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
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
	puls d,x,cc
	rts
	
FlagLabels:
	dc.b 'C','V','Z','N','I','H','F','E'
	;dc.b 'E','F','H','I','N','Z','O','C'
	
MonitorMem:
	ldy #8			;Bytes to show
	ldx #$6000		;Address to show
	jmp Memdump		;Show Memory
MonitorACC:
	jsr MonitorA
	jsr MonitorCCNL
	rts
MonitorDCC:
	jsr MonitorD
	jsr MonitorCCNL
	rts
	
	
MonitorA:
	pshs d,x,cc
	
		tfr d,x
		lda #"A"
		jsr ShowRegName
		jsr ShowRegNibblePair
		lda #" "
		jsr printchar
	puls d,x,cc
	rts	

MonitorD:
	pshs d,x,cc
		exg x,d
		lda #"D"
		jsr ShowReg
	puls d,x,cc
	rts		
MonitorCC:		
	pshs d,x,cc
		jsr ShowFlags
		lda #" "
		jsr printchar
	puls d,x,cc
	rts	
	
MonitorCCNL:		
	pshs d,x,cc
		jsr ShowFlags
		jsr NewLine
	puls d,x,cc
	rts	

	
MonitorB:	
	pshs d,x,cc
		tfr b,a
		tfr d,x
		lda #"B"
		jsr ShowRegName
		jsr ShowRegNibblePair
		lda #" "
		jsr printchar
	puls d,x,cc
	rts	
	

MonitorABP:
	pshs d,x,cc
		pshs x
			exg x,d
			lda #"D"
			jsr ShowReg
		puls x
		lda #"X"
		jsr ShowReg
		
		tfr y,x
		lda #"Y"
		jsr ShowReg
		
		tfr pc,x
		lda #"P"
		jsr ShowReg

		tfr cc,a
		tfr d,x
		lda #"C"
		jsr ShowRegName
		jsr ShowRegNibblePair
	puls d,x,cc
	rts	
	
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	include "\srcALL\v1_Footer.asm"