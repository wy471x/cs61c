	include "\srcALL\v1_header.asm"

	;Unrem one of these test jumps
	
	;jmp TestBasics
	;jmp TestMore
	;jmp TestAddSub
	jmp TestSubroutine

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
; #= Immediate number
; $= Hex value
; %= Binary
; '= Ascii
TestBasics:
	ldD #$1234		;Load Dual Accumulator (A=High B=Low) 
					;$=Hex
					
	ldx #5678		;Load X 
					;no $=Decimal
					
	ldy #%101011110000	;Load Y
					;%=Binary
	
	ifdef BuildFM7
		lds #$70F0		;Load Stack
	endif
	ifdef BuildDGN
		lds #$7EF0		;Load Stack
	endif
	
	ldu #$DEF0		;Load User Stack
	jsr Monitor
	
	;16 bit D is made up of A and B 8 bit registers
	
	lda #'A'		;Store A (8 bit)
					;' = Ascii
	ldb #$22		;Store B (8 bit)
	jsr Monitor
	
	
;Direct page Loads

;NO # - Save to address
	std $6000		;Save D to $6000 ... 
					;A->&$6000, B->&$6001
	stx $6002		;Store X (16 bit)
	sty $6004		;Store Y (16 bit)
	sts $6006		;Store Stack
	stu $6008		;Store User Stack
	
	sta $6009		;Store A (8 bit)
	stb $600A		;Store B (8 bit)
	
	ldy #16			;Bytes to show
	ldx #$6000		;Address to show
	jsr Memdump		;Show Memory


	
;NO # - Load from address
	ldx $6000
;NO $ - Decimal value
	ldY 24576	;$6000 in decimal
	jsr Monitor
	
	ldd #$1234
	std $60			;Store in Directpage address $0060
	ldd #$FEDC
	std $62

	ldy #16			;Bytes to show
	ldx #$0060		;Address to show
	jsr Memdump		;Show Memory
	
	jsr NewLine
	
	ldd #$FEDC		;Test Value
	jsr MonitorABP
	tfr D,X			;Store D in X
	jsr MonitorABP
	exg Y,X			;Swap Y and X
	jsr MonitorABP
	
	jmp InfLoop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestMore:
	ldd #$8888		;Load A+B together
	jsr MonitorABP
	inca			;Add 1 to A
	decb 			;Subtract 1 from B
	jsr MonitorABP
	clra			;Zero A
	clrb			;Zero B
	jsr MonitorABP
	
	jsr NewLine
	
	jsr MonitorMem
	inc $6000		;Add one to value at $6000
	dec $6001		;Subtract one from value at $6000
	clr $6002		;Store Zero to $6000
	jsr MonitorMem
	
	jmp InfLoop

TestAddSub:
	ldd #$8888
	jsr MonitorABP
	adda #$4			;Add 4 to A
	addb #$4			;Add 4 to B
	jsr MonitorABP	
	suba #$4			;Sutract 4 from A
	subb #$4			;Sutract 4 from B
	jsr MonitorABP
	
	jsr NewLine

	jsr MonitorABP
	addd #$1234			;Add $1234 to D
	jsr MonitorABP
	subd #$1234			;Subtract $1234 to D
	jsr MonitorABP
	
	jsr NewLine
	ldx #$1234
	ldb #$4
	jsr MonitorABP
	abx					;Add B to X... X=X+B 
	jsr MonitorABP			;There's no AAX or ABY!
	
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
TestSubroutine:
	lda #'A'
	jsr printchar
	lda #'B'
	jsr printchar
	
	jmp Skip			;Jump to label Skip

	lda #'X'			;This never happens
	jsr printchar
Skip:	
	lda #'C'
	jsr printchar
	
	jsr TestJsr			;Call subroutine 
	
	lda #'E'			;This line happens after sub RTS
	jsr printchar
	
	jmp InfLoop

TestJsr:				;Sub routine
	lda #'D'
	jsr printchar
	rts					;Return from subroutine
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
	
InfLoop:
	ifdef BuildVTX
		jsr DrawVectrexScreen	;Wait for Vsync and Redraw screen
	endif
	jmp InfLoop
	

MonitorMem:
	ldy #8			;Bytes to show
	ldx #$6000		;Address to show
	jmp Memdump		;Show Memory
	

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
		
		ifdef BuildFM7
			jsr NewLine
		endif
		
	puls d,x,cc
	rts	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	include "\srcALL\v1_Footer.asm"