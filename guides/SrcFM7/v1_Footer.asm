ProgramEnd:
	;DC.B $FF,0
	;DC.B $00
	dc.w ProgramStart	;exec
	dc.b $1a 	;EOF
	;ds.b 242
	;dc.b 0,0,0