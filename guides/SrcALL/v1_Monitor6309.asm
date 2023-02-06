
Memdump:
	pshs d,x,cc
		tfr x,d
		jsr ShowRegNibblePair
		jsr ShowRegNibblePair
		lda #":"
		jsr PrintChar
		jsr newline
MemdumpAgain:	
		lda ,x+
		pshs x
			tfr d,x
			jsr ShowHexByte
		puls x
		tfr y,d
		decb
		
		andb #%00000111
		bne MemdumpLineOk
		jsr NewLine
MemdumpLineOk:	
		tfr y,d
		decb
		tfr d,y
		bne MemdumpAgain
	puls d,x,cc
	
	rts	
	
Monitor:
	pshs d,x,cc
		pshs cc
			pshs x
				exg x,d
				lda #"D"
				jsr ShowReg
				ifdef CPU6309
					tfr w,x
					lda #"W"
					jsr ShowReg
				endif
				
					
			puls x
			lda #"X"
			jsr ShowReg
			
			tfr y,x
			lda #"Y"
			jsr ShowReg
			
			jsr NewLine
			
			tfr S,D
			addd #8
			tfr d,x
			lda #"S"
			jsr ShowReg
			
			tfr u,x
			lda #"U"
			jsr ShowReg
			
			tfr pc,x
			lda #"P"
			jsr ShowReg
			ifdef CPU6309
				tfr v,x
				lda #"V"
				jsr ShowReg
			endif
		puls a
		;orCC #%11111111	
		tfr d,x
		lda #"C"
		jsr ShowRegByte
		; ifdef CPU6309
		
			; clrb
			
			; bitmd #%00000001
			; beq Mon0
			; orb #%00000001
; Mon0:
			; bitmd #%00000010
			; beq Mon1
			; orb #%00000010
; Mon1:
			; bitmd #%01000000
			; beq Mon2
			; orb #%01000000
; Mon2:
			; bitmd #%10000000
			; beq Mon3
			; orb #%10000000
; Mon3:
			; clra
			; tfr d,x
			; lda #"M"
			; jsr ShowRegByte
		; endif
			
		lda #"D"
		jsr PrintChar
		tfr dp,a
		tfr d,x
		lda #"p"
		jsr ShowRegByte
				
		jsr NewLine
	puls d,x,cc
	rts
	
	
ShowRegName:
	jsr PrintChar
	lda #":"
	jsr PrintChar
	tfr x,d
	rts
ShowRegByte:
	jsr ShowRegName
	jmp ShowHexByte

ShowReg:
	jsr ShowRegName
	jsr ShowRegNibblePair
ShowHexByte:
	jsr ShowRegNibblePair
	lda #" "
	jsr PrintChar
	rts
	

ShowRegNibblePair:
	jsr ShowRegNibble
ShowRegNibble:
	pshs d
		lsra 
		lsra 
		lsra 
		lsra 
		anda #$0F
		adda #'0'
		cmpa #'9'
		ble ShowRegNibbleB
		adda #7				;Hex Fix
ShowRegNibbleB:
		jsr PrintChar
	puls d
	aslb
	rola
	aslb
	rola
	aslb
	rola
	aslb
	rola
	
	rts
	;ANDCC #%11111011

	