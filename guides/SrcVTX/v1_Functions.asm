TextRam equ $CA03

TextDatapos equ $CA00
TextDataY equ $CA02

ScreenINIT:
	LDD       #$FC38       ;Font Size ($HHWW=$F848 / $FC38)
	STD       $C82A			;SIZRAS
	
Cls:
	pshs d,x	
		ldx #TextRam
		lda #127				;Ypos
		bra ScreenINITB
		
	
	
NewLine:
	pshs d,x
		ldx TextDatapos
		lda #$80			;NewLine
		sta ,x+
		lda TextDataY
		suba #8
ScreenINITB:
		sta TextDataY
		sta ,x+
		lda #-128			;Xpos
		sta ,x+
		bra NewLineB
	
PrintChar:
	pshs d,x
		ldx TextDatapos
		cmpa #64			;No lowercase characters
		blt PrintCharB
		anda #%01011111	
PrintCharB:
		sta ,x+				;Char to Ram
NewLineB:
		lda #$80			;NewLine
		sta ,x
		lda #0				;End of Strings
		sta 1,x
		stx TextDatapos
	puls d,x,pc	
		
		
DrawVectrexScreen:
	pshs dp
		JSR     $F192 ;FRWAIT      
	
		lda #$d0
		tfr a,dp
		ldu #TextRam			;Screen Text Buffer
		jsr $F38C	;TXTPOS
	puls dp,pc
	