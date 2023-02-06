
	
	
DoRandom:					;RND outputs to A (no params)
	ldx z_hl			
	ldy z_bc			
	pshs x,y
		ldd RandomSeed
		std z_bc
			jsr incbc		;Get and update Random Seed
		ldd z_bc
		std RandomSeed
		jsr DoRandomWord
		lda z_l
		eora z_h
	puls x,y
	sty z_bc
	stx z_hl
	rts

DoRandomWord:				;Return Random pair in HL from Seed BC
	jsr DoRandomByte1		;Get 1st byte
	sta z_h
	jsr DoRandomByte2		;Get 2nd byte
	sta z_l
	jmp incbc		
	

DoRandomByte1:
	lda z_c					;Get 1st sed
DoRandomByte1b:
	rrca					;Rotate Right
	rrca
	eora z_c				;Xor 1st Seed
	rrca					;Rotate Right
	rrca				
	eora z_b				;Xor 2nd Seed
	rrca					;Rotate Right
 	eora #%10011101			;Xor Constant
	eora z_c				;Xor 1st seed
	rts


DoRandomByte2:
	ldx #Randoms1
	ldb z_b
	eorb #%10101011
	andb #%00001111		;Convert 2nd seed low nibble to Lookup
		
	abx
	lda x					;Get Byte from LUT 1
	sta z_d
		
	jsr DoRandomByte1
	anda #%00001111			;Convert random number from 1st 
	tfr a,b						;geneerator to Lookup
	
	ldx #Randoms2
	abx  
	lda x					;Get Byte from LUT2
	
	eora z_d				;Xor 1st lookup
	rts
	
	
	
	