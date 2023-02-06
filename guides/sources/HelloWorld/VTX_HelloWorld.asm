
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
	
	ldd #$FC38	;Font Size ($HHWW=$F848 / $FC38)
	std $C82A	;SIZRAS (2 bytes) - Size of Raster Text


InfLoop:
;Wait for beginning of frame boundary (Timer #2 = $0000)   
	jsr $F192 	;FRWAIT 
	

	lda #$d0				;Need DP=$d0 for next command
	tfr a,dp
	ldu #txtHello			;Screen Text Buffer

;Fetch position and display multiple text strings		
	jsr $F38C	;TXTPOS 

	jmp InfLoop				;Infinite Loop
	
	
txtHello:						;Test string (Ucase only)
	dc.b 127,-128				;Ypos,Xpos (TopLeft)
	dc.b "HELLO WORLD!?",$80,0	;$80=newline, $0=Strings End
	
	
