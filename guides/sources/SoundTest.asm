	
	include "\srcALL\v1_header.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	lda #$C0
InfLoop:
	pshs a
		jsr Monitor			;Show the Register
		
		jsr ChibiSound		;Make sound A
	
		ifdef BuildFM7
			ldd #1000
		endif
		ifdef BuildVTX
			ldd #4
		endif
		ifdef BuildDGN
			ldd #3000
		endif
Delay
		ifdef BuildVTX
			pshs d
				jsr DrawVectrexScreen	;Wait for Vsync and Redraw screen
			puls d
		endif

		subd #1
		bne Delay
		jsr cls
	puls a
	inca
	jmp InfLoop			;Infinite Loop
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "\srcALL\BasicFunctions.asm"
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	include "\SrcALL\V1_ChibiSound.asm"
	include "\srcALL\v1_Footer.asm"
	
	
	