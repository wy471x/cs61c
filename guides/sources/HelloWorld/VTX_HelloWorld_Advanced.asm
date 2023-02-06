
TextDatapos equ $CA00		;Next byte of Text Ram to write
TextDataY   equ $CA02		;Current Y line
TextRam     equ $CA03		;Area Used by our text routine 
;Text ram is many bytes - should allocate at least 256

	Padding Off					;Don't pad to 16 bit entries

	org $0000
	dc.b "g GCE 1983", $80    	;"(C) GCE 1983" - fixed value
	dc.w $FD0D 				  	;Music address
    dc.b $F8, $50, $20, -$46  	;Title Pos (Hei,Wid) (Y,X)
    dc.b "LEARNASM.NET",$80	  	;Cart Title ($80 terminated)
    dc.b 0                    	;Header End 
	
	assume dpr:$C8	;SETDP on other systems $D0= Hardware Regs $C8=Ram
	lda #$C8
	tfr a,dp
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

	jsr ScreenInit		;Set up screen
		
	ldD #$1234			;Test Value
	jsr Monitor			;Show the Register
	
	ldy #32				;Bytes to dump
	ldx #$C000			;Address to dump
	jsr Memdump
	
	ldy #Hello			;255 terminated Message
	jsr PrintString		;Show String to screen
	
InfLoop:
		jsr DrawVectrexScreen	;Wait for Vsync and Redraw screen
	jmp InfLoop			;Infinite Loop
	
PrintString:			;Print 255 terminated string
	lda ,Y+
	cmpa #255	
	beq PrintStringDone	;read 255? then done
	jsr printchar		;Print Char to screen
	jmp PrintString
PrintStringDone:	
	rts	
	
Hello:					;255 terminated string
	dc.b "HellO WORLD!?",255
	
	include "\srcALL\v1_Monitor.asm"

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	

ScreenINIT:		
	ldd #$FC38       ;Font Size ($HHWW=$F848 / $FC38)
	std $C82A		;SIZRAS (2 bytes) - Size of Raster Text

Cls:
	pshs d,x	
		ldx #TextRam
		lda #127			;Start Ypos
		bra ScreenINITB
NewLine:
	pshs d,x
		ldx TextDatapos		;Pos of next Character in string
		lda #$80			;NewLine
		sta ,x+
		lda TextDataY
		suba #8				;Move Down 8 lines
ScreenINITB:
		sta TextDataY		;Save Ypos
		sta ,x+
		lda #-128			;Save Xpos
		sta ,x+
		bra NewLineB
	
PrintChar:
	pshs d,x
		ldx TextDatapos		;Pos of next Character in string
		cmpa #64			;No lowercase characters
		blt PrintCharB
		anda #%01011111		;Convert Lcase -> Ucase
PrintCharB:
		sta ,x+				;Char to Ram
NewLineB:
		lda #$80			;$80 = NewLine
		sta ,x
		lda #0				;0 = End of Strings
		sta 1,x
		stx TextDatapos		;Save pos of next char
	puls d,x,pc	
		
		
DrawVectrexScreen:
	pshs dp
;Wait for beginning of frame boundary (Timer #2 = $0000)   
		jsr $F192 	;FRWAIT 
     	
		lda #$d0		;Need DP=$d0 for next command
		tfr a,dp
		ldu #TextRam	;Screen Text Buffer
		
;Fetch position and display multiple text strings			
		jsr $F38C	;TXTPOS 
	puls dp,pc
	
