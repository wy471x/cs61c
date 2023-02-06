	
	include "\srcALL\v1_header.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;mPmode4 equ 1	;256x192 2 color
;mPmode3 equ 1	;128x192 4 color
;mPmode2 equ 1	;128x192 2 color
;mPmode1 equ 1	;128x96 4 color
;mPmode0 equ 1	;128x96 2 color
;mPmodeF equ 1	;128x64 4 color
;mPmodeE equ 1	;128x64 2 color
;mPmodeD equ 1	;64x64 4 color
	
	ifdef mPmode4
scrWidth equ 32	 	
	endif
	ifdef mPmode3
scrWidth equ 32	 	
bmpColor equ 1
	endif
	ifdef mPmode2
scrWidth equ 16
	endif
	ifdef mPmode1	
scrWidth equ 32	
bmpColor equ 1
	endif
	ifdef mPmode0
scrWidth equ 16	
	endif
	ifdef mPmodeF
scrWidth equ 32	
bmpColor equ 1
	endif
	ifdef mPmodeE
scrWidth equ 16
	endif
	ifdef mPmodeD
scrWidth equ 16
bmpColor equ 1
	endif
	
	ldx #1
	ldy #0
	jsr GetScreenPos	;Calculate screen address
	ldx #Bitmap			;Bitmap source	
	ldb #48				;Height in lines
NextLine:
	pshs b
	ifdef bmpColor
		ldb #48/4		;Width in bytes (4 Color)
	else
		ldb #48/8		;Width in bytes (2 Color)
	endif
		pshs y
NextByte:
			lda x+		;Transfer a byte
			sta y+
			decb
			bne NextByte ;Repeat for next byte
		puls d
		addd #scrWidth	;Move down a line
		tfr d,y
	puls b	
	decb
	bne NextLine		;Repeat for next line
	
	ifdef mPmode4
		jsr Pmode4
	endif
	ifdef mPmode3
		jsr Pmode3
	endif
	ifdef mPmode2
		jsr Pmode2
	endif
	ifdef mPmode1
		jsr Pmode1
	endif
	ifdef mPmode0
		jsr Pmode0
	endif
	ifdef mPmodeF
		jsr PmodeF
	endif
	ifdef mPmodeE
		jsr PmodeE
	endif
	ifdef mPmodeD
		jsr PmodeD
	endif
	;jsr Pmode3
	;jsr PalSwap
	jmp *
	
GetScreenPos: 	;Y=ram address of (X,Y)
	tfr y,d
	lda #scrWidth	
	mul			;Ypos * ScreenWidth
	addd #$400	;Add Screen Base
	tfr d,y
	exg y,x
	tfr y,d
	abx			;Add Xpos
	tfr x,y	
	rts			;Result in Y
	
PalSwap:
	lda $FF22
	eora #%00001000	;Switch CSS color palette
	sta $FF22
	rts

	
Pmode4:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%11110000
	sta $FF22
	sta $ffc4+1 ;SAM V2=1
	sta $ffc2+1	;SAM V1=1
	rts
	
Pmode3:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%11100000
	sta $FF22
	sta $ffc4+1 ;SAM V2=1
	sta $ffc2+1	;SAM V1=1
	rts
	
Pmode2:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%11010000
	sta $FF22
	sta $ffc4+1 ;SAM V2=1
	sta $ffc0+1	;SAM V0=1
	rts	

Pmode1:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%11000000
	sta $FF22
	sta $ffc4+1 ;SAM V2=1
	rts
	
Pmode0:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%10110000
	sta $FF22
	sta $ffc2+1	;SAM V1=1
	sta $ffc0+1	;SAM V0=1
	rts	
	
PmodeF:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%10101000
	sta $FF22
	sta $ffc2+1	;SAM V1=1
	rts	
	
PmodeE:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%10011000
	sta $FF22
	sta $ffc0+1	;SAM V0=1
	rts		
	
PmodeD:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%10001000
	sta $FF22
	sta $ffc0+1	;SAM V0=1
	rts		
	
PmodeIA:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%00000000
	sta $FF22
	rts		
	
PmodeEA:
	jsr PmodeReset
		; AGGGC---	C=Color (0=Green 1=Orange)
	lda #%00010000
	sta $FF22
	rts		

	
PmodeReset:
	sta $FFC6	;Clr ScrBase Bit 0	$0200
	sta $FFC8	;Clr ScrBase Bit 1	$0400
	sta $FFCA	;Clr ScrBase Bit 2	$0800
	sta $FFCC	;Clr ScrBase Bit 3	$1000
	sta $FFCE	;Clr ScrBase Bit 4	$2000
	sta $FFD0	;Clr ScrBase Bit 5	$4000
	sta $FFD2	;Clr ScrBase Bit 6	$8000
	
	sta $FFC8+1	;Set ScrBase Bit 1	$0400
	
	sta $FFC0	;SAM V0=0
	sta $FFC2	;SAM V1=0
	sta $FFC4	;SAM V2=0
	rts
	
	
Bitmap:
	ifdef bmpColor
		binclude "\ResALL\BitMapTestDGN.raw"
	else
		binclude "\ResALL\RawZX.RAW"
	endif
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	
	include "\srcALL\v1_Footer.asm"
	
	
	