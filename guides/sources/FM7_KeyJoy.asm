	
	include "\srcALL\v1_header.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Init Joystick
	ldb #15	;RegNum
	lda #$7F	;Value	(Turn off joysticks)
	jsr FMRegWrite
	
	ldb #7	;RegNum
		 ;BANNNTTT 7=Mixer BA=ports (1=Write 0=Read) N=Noise T=Tone
	lda #%10111111	;Value (Set Direction B=Out R15 / A= In R14)
	jsr FMRegWrite
	
;Init Keyboard interrupt handler
	ldx #Ihandle	;Our interrupt handler
	stx $FFF8		;IRQ interrupt vector address
		
		;%RRRR-TPK	
	lda #%00000001	;Enable Keyboard interrupt
	sta $fd02		;Enable IRQs (RS232/Timer/Printer/ Keyboard)
		
Infloop:
	Jsr CLS
	
;Read Joy 2	
	ldb #15 ;$2F (Joy1) $5F (Joy2)
	lda #$5F
	jsr FMRegWrite			;JoySelect

	ldb #14
	jsr FMRegRead			;A= %--21RLDU
	jsr ShowBits
	jsr NewLine
	
;Read Joy 1
	ldb #15 ;$2F (Joy1) $5F (Joy2)
	lda #$2F
	jsr FMRegWrite		;JoySelect

	ldb #14
	jsr FMRegRead		;A= %--21RLDU
	jsr ShowBits
	jsr NewLine
	 
;Read (ASCII) Directly
	lda $FD00		;Read key bit 8 %K-------
	rola
	lda #0
	rola
	jsr ShowHex		;Show Hex A
	lda $FD01		;Read key bit 0-7 %KKKKKKKK
	jsr ShowHex		;Show Hex A
	jsr newline
	jsr ShowBits	;Show in binary
	
	jsr newline
	
;Read from Interrupt handler
	lda KeyRead		;Load key set by interrupt handler
	clr KeyRead		;Clear key
	jsr ShowHex		;Show Hex A
	
	ldx #$8000
Delay:
	leax -1,x
	bne Delay
	
	jmp InfLoop		;Infinite Loop
	
;Can Test what caused IRQ with $FD03	
;$FD03	%----ETPK	IRQs (Extended / Timer / Printer / Keyboard)	
Ihandle:
	pshs d
		lda $FD01	;Read ASCII key from keyboard 
		sta KeyRead					;(Clears interrupt)
	puls d
	rti				;Return from interrupt
	
KeyRead:
	dc.b 0			;Buffer for read key
	
ShowHex:
	pshs d
		jsr ShowRegNibblePair
	puls d,pc
ShowBits:
	pshs d,x,cc
		sta $00
	
		ldb #8
ShowBitsAgain:
		rol $00
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
	puls d,x,cc
	rts
	
FMRegRead:	;A=Returned Value B=Regnum
	stb $FD16	;RegNum
	ldb #3
	stb $FD15	
	clr $FD15	;Write #0
	
	lda #9
	sta $FD15
	
	lda $FD16	;Value
	
	clr $FD15	;Write #0
	rts
	
FMRegWrite:	;A=New Value B=Regnum
	stb $FD16	;RegNum
	ldb #3
	stb $FD15	
	clr $FD15	;Write #0
		
	sta $FD16	;Value
	lda #2
	sta $FD15
	
	clr $FD15	;Write #0
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	
	include "\srcALL\v1_Footer.asm"
	
	
	