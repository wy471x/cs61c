	
	include "\srcALL\v1_header.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

scrWidth equ 128

;Cpu Speed - WOOOSH!
	sta $FFD9		;Select 1.78 mhz CPU
	;sta $FFD8		;Select 0.89 mhz CPU	

;Turn On CoCo3 function 
		 ;CMIFRSr-
	lda #%01000000	;M=Enable MMU Mem Mapper C=0 Coco 3 mode
	sta $FF90
	;-MT-----m - m=Task 0/1
	lda #%00000000	;Task 0 ($FFA0-7 control bank mapping)
	sta $FF91

;Select 256x192 @ 16 color
		; P-DMFLLL		L=Lines per row / F=Freq (60/50) M=Mono D=Descender P=Planes(Text/Graphics)
	lda #%10000000	;Vmode Bitplane
	sta $FF98
	
		; -LLBBBCC	C=Colors (2=16 col) B=Bytes per row (6=128) L=Lines (0=192)
	lda #%00011010
	sta $FF99
	
	ldx #$C000 
	stx $FF9D		;Screen Base /8 = $60000/8=$C000
	
;Palettte
	ldy #$FFB0		;Palette 0
	ldx #Palette
	ldb #4			;No of colors (Up to 16)
PaletteAgain:
	lda x+			;Transfer a color
	sta y+
	decb
	bne PaletteAgain
	
		
;Draw a test sprite	
	ldx #1			;Xpos
	ldy #10			;Ypos
	jsr GetScreenPos	;Calculate screen address
	ldx #Bitmap			;Bitmap source	
	ldb #48				;Height in lines
NextLine:
	pshs b
		ldb #48/2		;Width in bytes (16 Color)
		pshs y
NextByte:
			lda x+		;Transfer a byte
			sta y+
			decb
			bne NextByte ;Repeat for next byte
		puls y
		jsr GetNextLine	;Move Down a line
	puls b	
	decb
	bne NextLine		;Repeat for next line
	
	
	;Scroll Test
InfLoop:	
	adda #16
	sta $FF9E	;Voff
	
	incb
	andb #%01111111
	stb $FF9F	;Hoff
	
	jsr delay
	
	
	jmp InfLoop			;Infinite Loop
	
	
delay
	ldx #$4000
delay2
	leax -1,x
	bne delay2
	rts
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;Note: Each Bank is $2000 / 8k (256x192 4bpp = 24k total screen)
GetNextLine:			
	tfr y,d
	addd #scrWidth		;Move down a line
	tfr d,y
	cmpy #$4000			;See if we've gone over a bank limit
	bcs GetNextLineDone
	inc $FFA1			;Move Down a line
	subd #$2000			;Move to top of bank
	tfr d,y
GetNextLineDone:	
	rts

GetScreenPos: 	;Y=ram address of (X,Y)
;Calc Bank Number
	tfr y,d
	andb #%11000000	;Bank No
	rolb
	rolb
	rolb
	addb #$30 		;$60000
	stb $FFA1		;Set bank at address $2000-$4000
	
;Calc Address in bank	
	tfr y,d
	andb #%00111111
	lda #scrWidth	
	mul				;Ypos * ScreenWidth
	addd #$2000		;Add Screen Base
	tfr d,y
	exg y,x
	tfr y,d
	abx				;Add Xpos
	tfr x,y	
	rts				;Result in Y
		
;16 Color sprite
Bitmap:
		binclude "\ResALL\RawMSX.RAW"
	
	
Palette:; --RGBRGB
	dc.b %00000000
	dc.b %00000101
	dc.b %00011011
	dc.b %00111111
	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	
	include "\srcALL\v1_Footer.asm"
	
	
	