
;Show B bytes of X 
BCD_Show:	
	leax b,x	;X=X+B - Move to Most significant byte
BCD_ShowDirect:
	lda -x
	pshs x,b
		jsr PrintBCDChar		
	puls x,b
	decb
	bne BCD_ShowDirect
	rts
	
PrintBCDChar:
	pshs a
		anda #$F0
		jsr SwapNibbles
		jsr PrintBCDCharOne		;Top digit
	puls a
	anda #$0F					;Bottom Digit
PrintBCDCharOne:	
	adda #'0'
	jmp PrintChar
	
;Add B bytes of X to Y	
BCD_Add:
	andcc #%11111110		;Clear Carry
BCD_Add_Again:
	lda ,y			;Get BCD byte
	adca ,x+		;Add BCD param + Carry
	daa				;Decimal Adjust Accumulator
	sta ,y+			;Store BCD byte
	decb
	bne BCD_Add_Again ;Repeat for next byte
	rts
	
	
;Compare B bytes of Y to X
BCD_Cp:
	leax b,x	;X=X+B - Move to Most significant byte
	leay b,y	;Y=Y+B - Move to Most significant byte
BCD_CpB:	
		lda -x
		cmpa -y
		bne BCD_CpDone		;If this byte is the same, 
		decb					;we need to check the next
		bne BCD_CpB
BCD_CpDone:
		rts
		
		
;Bytes are in reverse order... eg:
;	dc.b $01,$00,$00,$00 = 00000001
	