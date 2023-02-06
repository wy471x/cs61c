	
	include "\srcALL\v1_header.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	;jmp Pushes
	;jmp Transfers
	;jmp MultDiv
	jmp BitTests
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

;We can't work with W/E/F with the regular push/pull commands

Pushes:
	ldq #$12345678
	jsr MonitorS
	pshsw					;Push W onto the S stack
		ldq #$FFFFFFFF
		jsr MonitorS
	pulsw					;Pull W off  the S stack
	jsr MonitorS

	jsr NewLine
	
	
	ldu #$7100
	ldq #$12345678
	jsr MonitorS
	pshuw					;Push W onto the U stack
		ldq #$FFFFFFFF
		jsr MonitorS
	puluw					;Pull W off the U stack
	jsr MonitorS
	
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	
TestData:
	dc.l $01234567		;Test Data
	dc.l $89ABCDEF
	
Transfers:
	ldy #8				;Bytes to dump
	ldx #$7100			;Address to dump
	jsr Memdump

	ldw #4
	ldx #TestData+4
	ldy #$7104
	tfm x+,y+			;Copy Ascending W bytes from X to Y
	
	ldy #8				;Bytes to dump
	ldx #$7100			;Address to dump
	jsr Memdump
	
	ldw #4
	ldx #TestData+4
	ldy #$7104
	tfm x-,y-			;Copy Descending W bytes from X to Y
	
	ldy #8				;Bytes to dump
	ldx #$7100			;Address to dump
	jsr Memdump
	
	
	
	ldw #4
	ldx #TestData+4
	ldy #$7104
	tfm x+,y			;Transfer bytes from X+ to Y
						;Useful for transfering data 
						;to hardware port?
	
	ldy #8				;Bytes to dump
	ldx #$7100			;Address to dump
	jsr Memdump
	
	ldw #4
	ldx #TestData+4
	ldy #$7104
	tfm x,y+			;Fill Y+ with byte from X
	;tfm x,y-			;This doesn't exist
	
	ldy #8				;Bytes to dump
	ldx #$7100			;Address to dump
	jsr Memdump
		
	jmp InfLoop



;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

MultDiv:
	ldd #$0FED
	jsr MonitorS
	
	muld #$100		;Signed Multiply - Q=D*Value

	jsr MonitorS
	jsr NewLine
	
	ldq #$00110023
	jsr MonitorS
	
	divq #$100 		;Signed Divide
					;W=Q/Value 	D=Remainder
	jsr MonitorS
	
	ldd #$0203			
	
	;divd #$10 		;Signed Divide B=D/Value 	A=Remainder
;Doesn't seem to compile right, compiles to: 11 8D 00 10 
							     ;Should be: 11 8D 10  ?
	dc.b $11,$8D,$10  
	
	jsr MonitorS
	
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
BitTests:	
	jsr Monitor
	
	lda #$CC
	sta $80			;Store to DP=$80
	
	clra
	ldy #8				;Bytes to dump
	ldx #$0080			;Address to dump
	jsr Memdump
	jsr MonitorS
		
	ldbt a.0,$80.0		;Reg A/B or CC
	ldbt a.1,$80.1	
	ldbt a.2,$80.2		;A and B seem to be mixed up! Emu bug?
	ldbt a.3,$80.3
	
	jsr MonitorS
	
	ldbt cc.4,$80.0		;CC and B seem to be mixed up
	ldbt cc.5,$80.1		;by the assembler!
	ldbt cc.6,$80.2
	ldbt cc.7,$80.3
	
	jsr MonitorS
	
	stbt A.0,$82.0
	stbt A.1,$82.1
	stbt A.2,$82.2
	stbt A.3,$82.3
	stbt b.4,$82.4
	stbt b.5,$82.5
	stbt b.6,$82.6
	stbt b.7,$82.7
	
	ldy #8				;Bytes to dump
	ldx #$0080			;Address to dump
	jsr Memdump
	
	
	jmp InfLoop
	

	

InfLoop:
	ifdef BuildVTX
		jsr DrawVectrexScreen	;Wait for Vsync and Redraw screen
	endif
	jmp InfLoop			;Infinite Loop

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
	
	
	