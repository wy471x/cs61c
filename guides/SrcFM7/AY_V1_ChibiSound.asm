


;X is used as temp reg
;A= new value for register... B=Register number

ChibiSound:			;NVTTTTTT	Noise Volume Tone 
	tsta
	beq silent		;Zero turns off sound
	
	tfr d,x
	anda #%00000111	;Rotate lowest 3 bits from -----XXX
	rora
	rora
	rora
	rora
	ora #%00011111		;convert 11100000 to 11111111
	ldb #0			;TTTTTTTT Tone Lower 8 bits	A
	jsr AYRegWrite

	tfr x,d
	anda #%00111000	;Get upper bits of tone
	lsra
	lsra
	lsra
	ldb #1			;----TTTT Tone Upper 4 bits
	jsr AYRegWrite
	
	tfr x,d
	anda #%10000000			;Noise bit N-------
	beq AYNoNoise
	
		 ;PPNNNTTT (1=off) --CBACBA	PP=Ports
	lda #%00110110
	ldb #7			;Mixer  
	jsr AYRegWrite
	
		 ;---NNNNN  - Noise
	lda #%00011111
	ldb #6			
	jsr AYRegWrite
	bra AYMakeTone
	
AYNoNoise:
	;	  PPNNNTTT (1=off) --CBACBA P=ports
	lda #%00111110
	ldb #7			;7=Mixer
	jsr AYRegWrite
	
	beq AYMakeTone
	
AYMakeTone:
	tfr x,d
	anda  #%01000000	;-V------ = Volume bit
	lsra
	lsra
	lsra
	lsra
		  ;---EVVVV
	ora  #%00001011	; 00001V11 
	ldb #8	;4-bit Volume / 2-bit Envelope Select for channel A 
	bra AYRegWrite
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
silent:
	ldb #7		;Mixer  --NNNTTT (1=off) --CBACBA
	lda #%00111111				
	bra AYRegWrite				
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	ifdef BuildFM7
AYRegWrite:			;A=Value B=Regnum
	;Select Reg
		stb $FD0E	;RegNum
		ldb #3
		stb $FD0D	;Write #3
		clr $FD0D	;Write #0
	;Set Value
		sta $FD0E	;Value
		decb
		stb $FD0D	;Write #2
		clr $FD0D	;Write #0
		rts
	endif

	Ifdef BuildVTX
AYRegWrite:			;A=Value B=Regnum
	;Select Reg
		STb $D001	;Regnum
		LDb #$19         	
		STb $D000	;write #$19
		LDb #1
		STb $D000	;Write #1
	;Set Value	
        STa $D001	;Value 
        LDa #$11
        STa $D000	;Write #$11
        STb $D000	;Write #1
		rts
		
	endif

	;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
;sample code
	; ldb #0		
		 ; ;TTTTTTTT Tone Lower 8 bits - Chn A
	; lda #%11111111
	; jsr AYRegWrite
	; ldb #1		
		 ; ;----TTTT Tone Upper 4 bits - Chn A
	; lda #%00000000
	; jsr AYRegWrite
	
	
	
	;ldb #8		
		 ;%---EVVVV 4-bit Volume / Envelope for chn A 
	;lda #%000011111			;E=1 means envelope on
	;jsr AYRegWrite
	
	