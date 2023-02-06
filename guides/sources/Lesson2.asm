	include "\srcALL\v1_header.asm"

;Copy Test Data
	ldx #ChunkZP20
	ldy #$0080
	ldb #8
	jsr CopyChunk
	
	ldx #Chunk2000
	ldy #$2000
	ldb #8
	jsr CopyChunk
	
	ldx #Chunk1311
	ldy #$1311
	ldb #8
	jsr CopyChunk
	
	ldx #Chunk1211
	ldy #$1211
	ldb #8
	jsr CopyChunk
	
	ldx #Chunk1A18
	ldy #$1A18
	ldb #8
	jsr CopyChunk
	
	ldx #Chunk1B18
	ldy #$1B18
	ldb #8
	jsr CopyChunk
	
	
	ldy #8			;Bytes to show
	ldx #$0080		;Address to show
	jsr Memdump		;Show Memory
	
	ldy #8			;Bytes to show
	ldx #$2000		;Address to show
	jsr Memdump		;Show Memory
	
	ldy #8			;Bytes to show
	ldx #$1110		;Address to show
	jsr Memdump		;Show Memory
		
	ldy #8			;Bytes to show
	ldx #$1210		;Address to show
	jsr Memdump		;Show Memory
	
	ldy #8			;Bytes to show
	ldx #$1310		;Address to show
	jsr Memdump		;Show Memory
	
	ldy #8			;Bytes to show
	ldx #$1A18		;Address to show
	jsr Memdump		;Show Memory
	
	ldy #8			;Bytes to show
	ldx #$1B18		;Address to show
	jsr Memdump		;Show Memory
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	;jmp TestSimple
	;jmp TestDP
	;jmp TestExtended
	;jmp TestIndexed
	;jmp TestZero
	;jmp FiveBitOffset
	;jmp ConstantOffsetFromPC
	;jmp ProgramCounterRelative
	;jmp IndirectWithConstantOffset
	;jmp AccumulatorOffsetFromBase
	;jmp IndirectAccumulatorOffsetFromBase
	;jmp AutoInc
	;jmp AutoDec
	;jmp IndirectAutoInc
	;jmp IndirectAutoDec
	;Jmp ProgramRelative
	jmp LoadEffectiveAddress
	
TestSimple:
;Inherant Addressing
	jsr MonitorABP
	inca				;Register A implied by command
	jsr MonitorABP
	jsr NewLine
	
	
;Regsiter Addressing
	jsr MonitorABP
	tfr a,b				;Transfer A->B
	jsr MonitorABP
	jsr NewLine
	
;Immediate Addressing
	jsr MonitorABP
	lda #$1F			;load 1F into the register
	jsr MonitorABP
	jsr NewLine
	jmp InfLoop
	
;Direct Page addressing
TestDP:
	jsr MonitorABP
	lda $80				;Load A from DP address 
	jsr MonitorABP			;$80 = $0080
	
;Indirect Direct Page Addressing
	lda [$81]				;Load A from address at DP address 
	jsr MonitorABP			;$80 = $0080
	
	jsr NewLine
	jmp InfLoop
	
	
TestExtended:	
;Extended Direct addressing
	lda $2000
	jsr MonitorABP
	
;Extended Indirect Addressing
	lda [$2000]
	jsr MonitorABP
	jmp InfLoop
	
TestIndexed:		
;Indexed Addressing
	ldy #$2000
	ldu #$2002
	jsr MonitorABP
	
	lda ,Y				;Zero Offset
	ldb 1,Y				;Parameter loaded from address in Y +1
	ldx 2,U				;Can Also use Y,X,S,U
	ldy -1,U			;Can be negative!
	jsr MonitorABP
	
	jsr NewLine
	
	ldy #8			;Bytes to show
	ldx #$2000		;Address to show
	jsr Memdump		;Show Memory
	
	ldy #8			;Bytes to show
	ldx #$0080		;Address to show
	jsr Memdump		;Show Memory
	
	ldy #2
	jsr MonitorABP
	
testoff equ $80	

	lda testoff,y		;Symbol used
	
	ldb $2000,y			;Very large offsets possible!
	
	jsr MonitorABP
	
	jmp InfLoop
	
	
TestZero:
;Indexed Addressing - Zero Offset
	jsr MonitorABP
	ldy #$2000
	
	lda ,Y				;All these use value at address Y
	ldb 0,Y				;All these use value at address Y
	ldx Y				;All these use value at address Y
	
	jsr MonitorABP
	
	jmp InfLoop

	
;;Indexed Addressing - 5 bit offset (smaller resulting commands)
FiveBitOffset:
	jsr MonitorABP
	ldy #$2004
	lda -2,Y
	ldb -1,Y
	jsr MonitorABP
	lda 2,Y
	ldb 1,Y
	jsr MonitorABP
	jmp InfLoop
	
;Constant Offset From PC - Can't get this to work
; ConstantOffsetFromPC:
	; ldy #24			;Bytes to show
	; ldx #ConstantOffsetFromPC2		;Address to show
	; jsr Memdump		;Show Memory
; ConstantOffsetFromPC2:	
	; jsr MonitorABP
	; ldd $C137,PC		;Just seems to read from absolute adress?????
	; jsr MonitorABP
	; jmp InfLoop
	
	
;Program counter relative
ProgramCounterRelative:
	jsr MonitorABP
	ldd TestLabel,PCR		;Calculate offset from Program counter
	jsr MonitorABP				;to Testlabel
	
	jmp InfLoop
TestLabel:
	dc.w $FEDC				;Test Data
	
;Indirect with constant offset from base register
IndirectWithConstantOffset:
	ldx #1					;Load X with 1
	jsr MonitorABP			;Call the monitor
	lda [$80,X]				;Preindex with constant ($0080+X)  
								;so load data from address at ($0081)
	ldb [$2000,X]			;Preindex with constant ($2000+X)  
								;so load data from address at ($2001)
	jsr MonitorABP			;Call the monitor
	jmp InfLoop				;Inf Loop
	
;Accumulator offset from Base register
AccumulatorOffsetFromBase:
	ldx #$2000				;Load X with $2000
	lda #4					;Offset 4
	ldb #5					;Offset 5
	jsr MonitorABP			;Call the monitor

	ldy A,X					;Load from address (X+A)

	ldd B,X					;Can also use B or D (X+B)

	jsr MonitorABP			;Call the monitor
	jmp InfLoop				;Inf Loop



;Indirect Accumulator offset from Base register
IndirectAccumulatorOffsetFromBase:
	ldx #$0080				;Load X with $0080
	lda #1
	ldb #2
	jsr MonitorABP			;Call the monitor
	
	ldy [A,X]				;Load from Address at Address (A+X) 
								;Can also use B or D
	ldd [d,X]
	
	jsr MonitorABP			;Call the monitor
	jmp InfLoop				;Inf Loop

	
;AutoIncrement
AutoInc:
	ldx #$0080				;Load X with $0080
	ldy #$0080				;Load Y with $0080
	jsr MonitorABP	
	lda X+					;Load from address in X, Add 1 to X
	ldb Y++					;Load from address in Y, Add 2 to Y
	jsr MonitorABP	
	lda X+					;Load from address in X, Add 1 to X
	ldb Y++					;Load from address in Y, Add 2 to Y
	jsr MonitorABP	
	lda X+					;Load from address in X, Add 1 to X
	ldb Y++					;Load from address in Y, Add 2 to Y
	jsr MonitorABP	
	lda X+					;Load from address in X, Add 1 to X
	ldb Y++					;Load from address in Y, Add 2 to Y
	jsr MonitorABP		
	jmp InfLoop
	
	


;AutoDecrement
AutoDec:
	ldx #$0084				;Load X with $0084
	ldy #$0088				;Load X with $0088
	jsr MonitorABP			
	lda -X					;Subtract 1 from X, Load from address in X
	ldb --Y					;Subtract 2 from Y, Load from address in Y
	jsr MonitorABP			
	lda -X					;Subtract 1 from X, Load from address in X
	ldb --Y					;Subtract 2 from Y, Load from address in Y
	jsr MonitorABP			
	lda -X					;Subtract 1 from X, Load from address in X
	ldb --Y					;Subtract 2 from Y, Load from address in Y
	jsr MonitorABP			
	lda -X					;Subtract 1 from X, Load from address in X
	ldb --Y					;Subtract 2 from Y, Load from address in Y
	jsr MonitorABP			
	jmp InfLoop
;Indirect AutoIncrement
	
IndirectAutoInc:
	ldx #$0080				
	ldy #$0080				
	jsr MonitorABP			
	lda [X+]				;Load from Address at Address X - Add 1 to X
	ldb [Y++]				;Load from Address at Address Y - Add 2 to Y
	jsr MonitorABP			
	lda [X+]				;Load from Address at Address X - Add 1 to X
	ldb [Y++]				;Load from Address at Address Y - Add 2 to Y
	jsr MonitorABP			
	lda [X+]				;Load from Address at Address X - Add 1 to X
	ldb [Y++]				;Load from Address at Address Y - Add 2 to Y
	jsr MonitorABP			
	lda [X+]				;Load from Address at Address X - Add 1 to X
	ldb [Y++]				;Load from Address at Address Y - Add 2 to Y
	jsr MonitorABP			
	
	jmp InfLoop
	
;Indirect AutoDecrement
IndirectAutoDec:
	ldx #$0084				
	ldy #$0088				
	jsr MonitorABP			
	lda [-X]			;Subtract 1 from X - Load from Address at Address X
	ldb [--Y]			;Subtract 2 from Y - Load from Address at Address Y
	jsr MonitorABP			
	lda [-X]			;Subtract 1 from X - Load from Address at Address X
	ldb [--Y]			;Subtract 2 from Y - Load from Address at Address Y
	jsr MonitorABP			
	lda [-X]			;Subtract 1 from X - Load from Address at Address X
	ldb [--Y]			;Subtract 2 from Y - Load from Address at Address Y
	jsr MonitorABP			
	lda [-X]			;Subtract 1 from X - Load from Address at Address X
	ldb [--Y]			;Subtract 2 from Y - Load from Address at Address Y
	jsr MonitorABP			
	jmp InfLoop

;Program relative
ProgramRelative:
	lda #'A'
	jsr PrintChar
	lda #'B'
	jsr PrintChar
	
	bra Skipped			;Branch to relative location (-128 to +127)
	
	;lbra Skipped		-Works for Long distances
	;ds 129			;Relative Branch can only be a short distance (use LBRA)
	
	lda #'X'
	jsr PrintChar
Skipped:
	lda #'C'
	jsr PrintChar
	jmp InfLoop
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


LoadEffectiveAddress:
	ldy #$2000
	
	leaU $100,y	;Load Address of $100+$2000...  U=$2100
	
	jsr Monitor
	jsr NewLine
	
	leaX --y	;Load Address of $2000--...     X=$1FFE ,Y=$1FFE
	
	leaS [$80]	;Load Address of Indirect $0080 S=$1122
	
	jsr Monitor
	
	jmp InfLoop


	
InfLoop:
	jmp InfLoop
	
	
	
	
	
	
	
CopyChunk:	
	lda ,x+
	sta ,y+
	decb
	bne CopyChunk
	rts
	
ChunkZP20:
	dc.b $11,$12,$13,$14,$15,$16,$17,$18
Chunk2000:
	dc.b $1A,$1B,$1C,$1D,$1E,$1F,$20,$21
Chunk1311:
	dc.b $30,$31,$32,$33,$34,$35,$36,$37
Chunk1211:
	dc.b $40,$41,$42,$43,$44,$45,$46,$47
Chunk1A18:
	dc.b $FF,$EE,$DD,$CC,$BB,$AA,$99,$88
Chunk1B18:
	dc.b $EF,$DE,$CD,$BC,$AB,$9A,$89,$78
MonitorMem:
	ldy #8			;Bytes to show
	ldx #$6000		;Address to show
	jmp Memdump		;Show Memory

MonitorDp:
	ldy #8			;Bytes to show
	ldx #$0000		;Address to show
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
		
		ldx 5,s
		;ldb #-3
		;abx 
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
	
	include "\srcALL\BasicFunctions.asm"
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	include "\srcALL\v1_Footer.asm"