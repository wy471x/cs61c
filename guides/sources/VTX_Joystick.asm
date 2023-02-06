;Settings
;$C81F	EPOT0 (DPOT0)		Controller #1: Right / left joystick pot enable (must be $00 or $01)
;$C820	EPOT1 (DPOT1		Controller #1: Up    / down joystick pot enable (must be $00 or $03)
;$C821	EPOT2 (DPOT2)		Controller #2: Right / left joystick #2 enable  (must be $00 or $05)
;$C822	EPOT3 (DPOT3)		Controller #2: Up    / down joystick #2 enable  (must be $00 or $07)

;Results
;$C81B	POT0	R=64 C=0 L=-64 	Joystick #1 - X Axis 
;$C81C	POT1	U=64 C=0 D=-64	Joystick #1 - Y Axis
;$C81D	POT2	R=64 C=0 L=-64 	Joystick #2 - X Axis 
;$C81E	POT3	U=64 C=0 D=-64 	Joystick #2 - Y Axis
;$C80F	TRIGGR	%----1234		Fire buttons


;Note Joy2 doesn't seem to work - maybe not supported by emulator?
	
	include "\SRCAll\v1_Header.asm"
	  
				
				
JoyTest:
	jsr Cls			;Zero Cursor Pos
	
;Get Joystick Settings (needed for both examples)	
	ASSUME dpr:$d0	;SETDP on other systems $D0= Hardware Regs 
	lda #$d0
	tfr a,dp
		
	ldd #$0103 		;Enable Joy 1
	std $C81F		;Epot0/1	
	
	ldd #$0000		;Disable Joy 2 (Doesn't work?)
	std $C821		;Epot2/3
	
	jsr $F1F8		;JOYBIT - Read Up, Down, Left, Right

	lda #255		;Direct response mask
	jsr $F1B4		;DBNCE - Read Buttons 1234 (A=Response mask)
	
;Show Example data from Joystick		
	
	ldx $C81B		;$C81B/C UDLR	 (Emulator Keys: cursors)
	ldy $C80F		;Button ----1234 (Emulator Keys: ASDF) 
	
	jsr Monitor		

;Convert to 1 bit per button digital (in B)

	ldb $C80F		;4 Fire buttons %----4321
	
	;$C81B - Controller #1: Right / left joystick pot value
	lda $C81B		;LR
	jsr TestOneAxis	
	
	;$C81C - Controller #1: Up / down joystick pot value
	lda $C81C		;UD
	nega			;Flip Y axis so our test works
	jsr TestOneAxis
	
	comb			;Flip bits of B

;Show the results B=%4321RLDU
	
	jsr newline
	tfr b,a
	jsr ShowBits		;Show the Register
	
	jsr DrawVectrexScreen		
	jmp JoyTest

TestOneAxis:	;Test an Axis, and convert to two bits in B
	lslb
	lslb
	cmpa #$40
	bcs TestOneDone
	cmpa #$C0
	bcs TestOneDoneB
	orb #%00000001
	rts
TestOneDoneB:
	orb #%00000010
TestOneDone:	
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
	
	
	
ShowBits:
	pshs d,x,cc,dp
		pshs a
			assume dpr:$C8	;SETDP on other systems $D0xx= Hardware Regs $C8xx=Ram
			lda #$C8		;DP now points to RAM
			tfr a,dp
		puls a
		sta $C8F0			;Save into DP ($C880+ free for use)
		
	
		ldb #8
ShowBitsAgain:
		rol $C8F0			;Load back from DP
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
	puls d,x,cc,dp
	rts
	
	include "\srcALL\v1_Monitor.asm"	
	include "\srcALL\v1_functions.asm"	

	

;***************************************************************************
                
;***************************************************************************
