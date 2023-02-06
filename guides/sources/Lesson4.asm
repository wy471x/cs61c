	include "\srcALL\v1_header.asm"
	
	ifdef BuildDGN
		ldS #$7E00			;Set Stack S (Main)
		ldU #$7D00			;Set Stack U (User)
	endif
	
	ifdef BuildFM7
	
		ldS #$3E00			;Set Stack S (Main)
		
		ldU #$3D00			;Set Stack U (User)
		
	endif
	
	;jmp StackTests1		;Nesting and multiple Push/Pulls
	;jmp StackTests2		;Combining Bytes and Words, and pushing Stack registers!
	;jmp StackTests3		;Subroutines and stacks
	jmp StackTests4		;Subroutines, and saving a RTS
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
StackTests1:
	jsr monitor
	
	ldd #$FEDC
	pshs d			;Push D onto the S Stack
		ldd #$1234
		pshs d			;Push D onto the S Stack
			ldd #$FFEE
			pshu d			;Push D onto the U Stack
				ldd #$DDCC
				pshu d			;Push D onto the U Stack

				jsr MonitorStacks
				
				jsr MonitorXYSU
			pulu x,y		;Pull two 16 bit registers onto the stack
				
			pshu x,y		;Push XY
				jsr MonitorXYSU
			pulu y,x		;Pull YX Order doesn't matter 
			jsr MonitorXYSU		;Same effect as pulu x,y
			jsr NewLine
		puls x
		jsr MonitorXYSU
	puls y
	jsr MonitorXYSU
	
	jmp InfLoops
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
StackTests2:
	jsr monitor
	
	pshu s			;Push the S stack onto the U Stack
	
	lda #$FF
	pshs a			;Push A onto the S Stack (1 Byte)
		lda #$EE
		pshs a			;Push A onto the S Stack (1 Byte)
			lda #$DD
			pshs a			;Push A onto the S Stack (1 Byte)
				lda #$CC
				pshs a		;Push A onto the S Stack (1 Byte)
					jsr MonitorStacks
					jsr MonitorXYSU
		puls x			;Pull 2 bytes off the S stack into X
		jsr MonitorXYSU
		
	pulu s			;Pull the S stack pointer off the U Stack
					;We didn't Pull all the pushed data off the stack, 
						;but now it doesn't matter
	jsr MonitorXYSU
	
	jmp InfLoops
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

StackTests3:
	lda #$FF
	pshs a			;Push A onto the S Stack (1 Byte)
	jsr MonitorA
		jsr SubTest		;Sub call puts return address 
		jsr MonitorStack		;onto stack
	puls a
	jsr MonitorA
	jmp InfLoops
	
SubTest:			
	lda #$EE
	pshs a			;Push A onto the S Stack (1 Byte)
	jsr MonitorA
		lda #$DD
		pshs a		;Push A onto the S Stack (1 Byte)
			jsr MonitorA
			jsr NewLine
			jsr MonitorStack
		puls a
		jsr MonitorA
	puls a		
	jsr MonitorA
	jsr NewLine
	rts				;Stack needs to be in same position as 
						;when sub started

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
StackTests4:
	ldY #$1234			;Test Values
	ldX #$5678			;Test Values
	lda #0				;Set Flag Z=1
	jsr Monitor
	
	jsr SubTest2		;Call Sub (Return addr onto stack)
	
	jsr Monitor
	jmp InfLoops
	
SubTest2:
	pshs x,y,cc
		ldY #$FFEE		;More test values
		ldX #$DDCC	
		jsr MonitorXYSU
		jsr MonitorStack
	puls x,y,cc,pc	;Pop Return into PC - no need for RTS

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;		
InfLoops:	
	jmp InfLoops

MonitorStack:

	ldy #16			;Bytes to show
	ifdef BuildFM7
		ldx #$3E00-16	;Address to show
	else
		ldx #$7E00-16	;Address to show
	endif
	jsr Memdump		;Show Memory
	rts
MonitorStacks:

	ldy #16			;Bytes to show
	ifdef BuildFM7
		ldx #$3E00-16	;Address to show
	else
		ldx #$7E00-16	;Address to show
	endif
	jsr Memdump		;Show Memory
	
	
	ldy #16			;Bytes to show
	ifdef BuildFM7
		ldx #$3D00-16	;Address to show
	else
		ldx #$7D00-16	;Address to show
	endif
	jsr Memdump		;Show Memory
	jsr NewLine
	rts
	
MonitorA:
	pshs d,x,cc
		tfr a,b
		tfr d,x
		lda #"A"
		jsr ShowRegName
		jsr ShowRegNibblePair
		lda #" "
		jsr PrintChar
	puls d,x,cc
	rts

MonitorXYSU:
	pshs d,x,cc

		lda #"X"
		jsr ShowReg
		
		tfr y,x
		lda #"Y"
		jsr ShowReg
		
		tfr S,D
		addd #7
		tfr d,x
		lda #"S"
		jsr ShowReg
		
		tfr u,x
		lda #"U"
		jsr ShowReg
		jsr NewLine
		
	puls d,x,cc
	rts
	
		
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	include "\srcALL\v1_Footer.asm"