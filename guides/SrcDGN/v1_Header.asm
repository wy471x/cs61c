	Padding off
z_Regs equ $20

	org $C000
CursorX equ $7000	
CursorY equ $7001

ProgStart:	
	LDS $8000
	clr CursorX
	clr CursorY
	