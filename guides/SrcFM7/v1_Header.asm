z_Regs equ $40
	PADDING off
	ORG		$2000-21
	DC.B $50,$52,$4f,$47,$00,$00,$00,$00	;FileName
	dc.b $00,$00,$02,$00,$00
	dc.b $58,$4d,$37	;XM7
	dc.b 0
	DC.W ProgramEnd-ProgramStart	;Size
	DC.W ProgramStart 	;Load Addr
	
ProgramStart:	