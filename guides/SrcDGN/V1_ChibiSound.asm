;X is used as temp reg
;A= new value for register... B=Register number

ChibiSound:			;NVTTTTTT	Noise Volume Tone 
	tfr d,x			;Back up for later
	
; ; Turn off 1 bit sound	
	 lda #%00110000	;Bit 2=0 - Select Direction 
	 sta $FF23
	 lda $FF22
	 anda #%11111000
	 ora  #%00000110	;0=Out, 1=in
	 sta $FF22		;Set Bit 1 (single bit sound) to input
	
	
	
; ; Turn on DAC + Hsync interrupt
	 lda #%00110111	;Bit 3=0 Bit0=Hsync
	 sta $ff01		;Bit 3	CA2: Select Device (Multiplexor LSB)
	 lda #%00110110	;Bit 3=0 Bit0=Vsync
	 sta $FF03		;Bit 3	CB2: Select Device (Multiplexor MSB)
	
; ; Turn On Sound
	 lda #%00111111	;CA2
	 sta $FF23		;Bit 3 CB2: Sound Source Enable (1=on)
	
	tfr x,d			;Get Back A
	tsta
	beq silent		;Zero turns off sound
	
	
;Get Volume
	anda #%01000000	;Get Volume Bit
	lsla
	ora  #%01111100	;Volume
	
	sta Svol		;Store for interrupt hander
	clr $FF20		;Clear current sound
	
;Get Pitch
	tfr x,d			;Get Back A
	tfr a,b
	clra
	andb #%00111111	;%--TTTTTT
	incb
	stb sfreq		;Store for timer 
	

	tfr x,d			;Get Back A
	anda #%10000000
	bne ChibiSoundNose	;Tone interrupt handler

;Make A tone
	ldx #InterruptTone
	bra SetInterrupt
	
;Make a noise
ChibiSoundNose:
	clr Snoise
	ldx #InterruptNoise	;Noise interrupt handler
	bra SetInterrupt
	
;Turn Off Sound 	
Silent:
	ldx #InterruptSilent
	
;Set interrupt handler routine	
SetInterrupt:
	orcc  #%00010000 	;Turn off IRQ
	lda #$7E			;JMP
	sta $010C
	stx $010D			
	andcc #%11101111 	;Turn on IRQ
	rts
	
	
	

	
	
InterruptNoise:
	lda stime		;Check if Time>Frequency
	inca
	cmpa sfreq
	bne InterruptA	;No? No tone!
	
	inc Snoise		;Inc Noise source
	ldb Snoise
	
	ldx #ProgStart	;Use Program code as noise source!
	
	lda b,x			;Get a byte of random data
	anda Svol		;Limit volume
	jmp ToneSet

	
InterruptTone:
	lda stime		;Check if Time>Frequency
	inca
	cmpa sfreq
	bne InterruptA	;No? No tone!
	
	lda $FF20		;Get current Volume
	eora Svol		;Flip it
ToneSet:
	sta $FF20		;Send to Dac (make tone)
	clra 
InterruptA:
	sta Stime		;Update Time
	
InterruptSilent:
	lda $FF00		;Clear interrupt
	rti
	
Stime equ $7002		;Tick count
Svol  equ $7003		;Volume of sound
Sfreq equ $7004		;Frequency (make sound when tick=freq)
Snoise equ $7005	;Noise source

