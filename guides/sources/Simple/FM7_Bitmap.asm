
	PADDING off						;Don't word align!
	ORG		$2000-21
	DC.B $50,$52,$4f,$47,$00,$00,$00,$00	;FileName
	dc.b $00,$00,$02,$00,$00
	dc.b $58,$4d,$37				;XM7
	dc.b 0
	DC.W ProgramEnd-ProgramStart	;Size
	DC.W ProgramStart 				;Load Addr
	
ProgramStart:	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;We Read from Joy 2	
	LDB #15 				;AY Reg 15 (Joy select)
	lda #$2F				;$2F (Joy1) $5F (Joy2)
	jsr FMRegWrite			;JoySelect
	
	ldx #100			;Xpos
	ldy #100			;Ypos
	jsr ShowSprite			;Show starting Sprite pos
	
InfLoop:	
	;Read in the Joystick	%---FUDLR
	LDB #14
	jsr FMRegRead			;A= %--21RLDU
	tfr a,b
	andb #%00001111
	cmpb #%00001111
	beq InfLoop
	
	pshs b
		jsr ShowSprite	;Remove old sprite
	puls b
	
	bitb #%00000001
	bne JoyNotUp		;Up Pressed?
	cmpY #0		
	beq	JoyNotUp		;At top of screen?
	leay -2,y		;Y=Y+2
JoyNotUp:	
	bitb #%00000010		;Down pressed?
	bne JoyNotDown
	cmpY #200-8			;At bottom of screen?
	beq	JoyNotDown
	leay 2,y		;Y=Y+2
JoyNotDown:	
	bitb #%00000100		;Left pressed?
	bne JoyNotLeft
	cmpX #0				;At far left of screen?
	beq	JoyNotLeft
	leax -4,x		;X=X-1
JoyNotLeft:	
	bitb #%00001000		;Right pressed?
	bne JoyNotRight
	cmpX #640-8			;At far right of screen?
	beq	JoyNotRight
	leax 4,x		;X=X+1
JoyNotRight:	

	jsr ShowSprite		;Show new sprite pos

	ldd #128
Delay:	
	subd #1
	bne Delay			;Delay
	
	jmp InfLoop			;Repeat
	
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
ShowSprite:				;Send First Block of color sprite
	pshs y,x
		stx SpriteSX	;Store Start
		sty SpriteSY
		
		leax 7,x		;Add Width-1
		leay 7,y		;Add Height-1
		
		stx SpriteEX	;Store End
		sty SpriteEY

		ldx #Bitmap		;864 byte image = 48x48 3bpp
		LDB #8			;96 bytes per block  = 9 blocks (8 + first)
		pshs b
			pshs x
				ldx #SendCMDPut						;Source
				LDB #(SendCMDPut_End-SendCMDPut)/2	;length (Words)
				jsr SubCpu_Halt		;Stop Sub CPU
				jsr SubCpu_SendAlt	;Send it to $FC80
			puls x
			LDB #(Bitmap_End-Bitmap)/2				;Words to Send
			jsr SubCPU_SendAltB		;Send 48 Words from X
			jsr SubCpu_Release		;Release Sub CPU
		puls b		
	puls y,x
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Transfer command daya from X (B = WORDS to send) to the shared ram
SubCPU_SendAlt:
	ldu #$FC80	;$FC80/D380 - Use Full range
SubCPU_SendAltB:
	ldy X++
	sty U++
	decb		;2 Bytes per transfer
	bne SubCPU_SendAltB
	rts

;Stop SubCPU - Main CPU can now Read/Write $FCxx/$D3xx range
SubCpu_Halt:			;Halt the SubCPU
	LDA $FD05			
	BMI SubCpu_Halt		;Wait for Not Busy
	LDA #$80			;Bit7 = Busy Flag.
	STA $FD05			;Set Halt
SubCpu_HaltWait			
	LDA $FD05
	BPL SubCpu_HaltWait	;Wait For Busy (halt to happen)
	rts	

;Release SubCPU - Sub CPU will start to try processing 
SubCpu_Release:			;the command at $FC82/$D382
	PSHS A
	LDA #0
	STA $FD05			;Release the SubCpu
	PULS A,PC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

SendCMDPut:			;Command to start sending bitmap
	dc.b 0,0		;(0=single block)
	dc.b $1E		;$1E=PUT BLOCK2
SpriteSX:	dc.w 10			;Start X
SpriteSY:	dc.w 10			;Stary Y
SpriteEX:	dc.w 10+8		;End X
SpriteEY:	dc.w 10+8		;End Y
	dc.b 0			;unused
	dc.b 4			;Func (4=XOR)
	dc.b 8*3		;Bytes
SendCMDPut_End:	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

Bitmap:
;Blue
        DC.B %00111100     ;  0	
        DC.B %01111110     ;  1
        DC.B %11111111     ;  2
        DC.B %11111111     ;  3
        DC.B %11111111     ;  4
        DC.B %11011011     ;  5
        DC.B %01100110     ;  6
        DC.B %00111100     ;  7
;Red
        DC.B %00000000     ;  8
        DC.B %00000000     ;  9
        DC.B %00000000     ; 10
        DC.B %00000000     ; 11
        DC.B %00000000     ; 12
        DC.B %00100100     ; 13
        DC.B %00011000     ; 14
        DC.B %00000000     ; 15
;Green
        DC.B %00000000     ; 16
        DC.B %00000000     ; 17
        DC.B %00100100     ; 18
        DC.B %00000000     ; 19
        DC.B %00000000     ; 20
        DC.B %00000000     ; 21
        DC.B %00000000     ; 22
        DC.B %00000000     ; 23
Bitmap_End:	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
FMRegRead:		;B=Regnum ... A=Returned Value 
	stb $FD16	;RegNum
	LDB #3
	stb $FD15	
	clr $FD15	;Write #0
	
	lda #9
	sta $FD15
	
	lda $FD16	;Value
	
	clr $FD15	;Write #0
	rts
	
FMRegWrite:		;A=New Value B=Regnum
	stb $FD16	;RegNum
	LDB #3
	stb $FD15	
	clr $FD15	;Write #0
		
	sta $FD16	;Value
	lda #2
	sta $FD15
	
	clr $FD15	;Write #0
	rts
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
ProgramEnd:	
	dc.w ProgramStart	;exec
	dc.b $1a 			;EOF
	