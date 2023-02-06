;Color defauils
colBlack equ 0		;---
colBlue equ 1		;--B
colRed equ 2		;-R-
colMagenta equ 3	;-RB
colGreen equ 4		;G--
colCyan equ 5		;G-B
colYellow equ 6		;GR-
colWhite equ 7		;GRB

;Logical ops
opPset equ 0
opPreset equ 1
opOr equ 2
opAnd equ 3
opXor equ 4
opNot equ 5

	
	include "\srcALL\v1_header.asm"

Tilenum equ 3	;Test tile num
	
Use8ColorTiles equ 1

;DisableBitplane3 ;Free up $8000-BFFF rage for tile data (2 bitplanes only)	
	
;TileDataVram equ $8000
TileDataVram equ $C000

	ifdef Use8ColorTiles
tilesize equ  24
	else
tilesize equ  16
	endif
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
;Send our bitmap data	
	
	ldx #Tiles			;Source Address in CPU RAM
	ldd #TileDataVram	;Dest Address in VRAM ($C000)
	
	jsr TransferBytes	;96 bytes per transfer
	jsr TransferBytes
	jsr TransferBytes
	
;Send our program to sub cpu address $CF00	
	
	ldx #DrawTile		;Source Address in CPU RAM
	ldd #$CF00			;Dest Address in VRAM ($C000)
	
	jsr TransferBytes	;96 bytes per transfer
	jsr TransferBytes
	
;Run our test program 
	ldx #CmdYamaTile					;Source
	LDB #(CmdYamaTile_End-CmdYamaTile)/2;length (Words)
	jsr SubCpu_DoCmd					;Send it to $FC82


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Free up $8000-BFFF rage for tile data (2 bitplanes only)	
	ifdef DisableBitplane3	
		;     -----GRB	
		lda #%00000000	
		sta $FD38	;Color 0
		lda #%00000001	
		sta $FD39	;Color 1
		lda #%00000101
		sta $FD3A	;Color 2
		lda #%00000111	
		sta $FD3B	;Color 3
		
			 ;-GRB-GRB	Display / Write
		lda #%01000000 		
		sta $FD37	;View/Write mask - View RB / Write RGB
	endif	

InfLoop:
	jmp InfLoop
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

TransferBytes:	;Transfer 96 bytes from MAIN Ram X to SUB Ram (D)
	pshs d
		pshs x
			std YamaDest
			
			jsr SubCpu_Halt		;Stop SubCPU (Shared Ram Accessible)
			ldx #CmdYamaTransfer							;Source
			LDB #((CmdYamaTransfer_End-CmdYamaTransfer)/2)+1 ;length (Words)
			ldu #$FC82	;$FC82/D382
			jsr SubCPU_SendAltB
		
		puls x
		LDB #(96/2)
		ldu #$FCA0		;$FCA0/D3A0
		jsr SubCPU_SendAltB
		jsr SubCpu_Release	;Release SubCPU (SubCPU will process command)
	puls d
	addd #96			;Update D - we can run again to transfer more
	rts	
	
CmdYamaTransfer:	;Transfer data to the Sub CPU
	dc.b $3F  		;$3F = Yamauchi command
	;dc.b "YAMAUCHI"	;Actually FM-7 doesn't check this (FM8 did) it can be anything!
	dc.b "LAMAICHI"		;8 Bytes of something!
	      
	dc.b $91		;$91 = Yamauchi Move
	dc.w $D3A0 ;Source Addr (MAIN Ram)
YamaDest:	dc.w $0000									  ;Dest (SUB Console ram)
	dc.w 96	  ;Length in bytes

	dc.b $90		;$90 = Yamauchi End
	
CmdYamaTransfer_End:;End of transferred area
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Fill the screen with a tile
;DrawTile must reside at $CF00 on Sub CUP

CmdYamaTile:	
	dc.b $3F  		;$3F = Yamauchi command
	dc.b "CHIBIKO!"		;8 Bytes of something!
	      
	dc.b $93		;$91 = Yamauchi Move
	dc.w $D382+CmdYamaTilePrg-CmdYamaTile ;Source Addr (MAIN Ram)
	
	dc.b $90		;$90 = Yamauchi End
	
CmdYamaTilePrg:
	
	ldu #TileDataVram+tilesize*Tilenum		;TileAddress
	ldx #$0000		;ScreenAddress
NextLine:
	clra
NextTile
	pshs a,u
		jsr $CF00	;Copy 8x8 4 color tile from Vram U to ScreenPos X
	puls a,u
	leax 1,x		;Inc X
	inca
	cmpa #80
	bne NextTile
	leax 80*7,x		;Down one strip
	cmpx #$3D80
	bcs NextLine	
	rts
CmdYamaTile_End:;End of transferred area	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Copy 8x8 4 color tile from Vram U to ScreenPos X
	
	
DrawTile:	
	ldd u++				;Bitplane 1
	sta 80*0,x
	stb 80*1,x
	ldd u++
	sta 80*2,x
	stb 80*3,x
	ldd u++
	sta 80*4,x
	stb 80*5,x
	ldd u++
	sta 80*6,x
	stb 80*7,x
		
	ldd u++
	sta $4000+80*0,x	;Bitplane 2
	stb $4000+80*1,x
	ldd u++
	sta $4000+80*2,x
	stb $4000+80*3,x
	ldd u++
	sta $4000+80*4,x
	stb $4000+80*5,x
	ldd u++
	sta $4000+80*6,x
	stb $4000+80*7,x
	
	ifdef Use8ColorTiles
		ldd u++			;Bitplane 3
		sta $8000+80*0,x
		stb $8000+80*1,x
		
		ldd u++
		sta $8000+80*2,x
		stb $8000+80*3,x
	
		ldd u++
		sta $8000+80*4,x
		stb $8000+80*5,x
	
		ldd u++
		sta $8000+80*6,x
		stb $8000+80*7,x
	endif
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
;Alternate version I was trying to see if it was faster
;(It wasn't !)	
DrawTile2:	;Copy 8x8 4 color tile from Vram U to ScreenPos X
	pshs x
	ldb #80
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	
	leax $4000-(80*7),x	;add  #$4000-(80*7) to X
	
	ldb #80
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	
	
	ifdef Use8ColorTiles
;3rd Bitplane

	leax $4000-(80*7),x	;add  #$4000-(80*7) to X
	
	ldb #80
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	abx
	lda u+
	sta x
	
	endif
	puls x
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Commands to control Sub CPU


;Transfer Command data without first two bytes			
SubCpu_DoCmd:			;Transfer $FC82-$FCFF / $D382-$D3FF
	incb
	jsr SubCpu_Halt		;Stop SubCPU (Shared Ram Accessible)
	jsr SubCpu_Send		;Transfer data to shared Ram
	jsr SubCpu_Release	;Release SubCPU (SubCPU will process command)
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Transfer command daya from X (B = WORDS to send) to the shared ram
SubCpu_send:	
	ldu #$FC82	;First two bytes unused (Error code / Status)
	bra SubCPU_SendAltB
SubCPU_SendAlt:
	ldu #$FC80	;$FC80/D380 - Use Full range
SubCPU_SendAltB:
	ldy X++
	sty U++
	decb		;2 Bytes per transfer
	bne SubCPU_SendAltB
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;Stop SubCPU - Main CPU can now Read/Write $FCxx/$D3xx range
SubCpu_Halt:			;Halt the SubCPU
	LDA $FD05			
	BMI SubCpu_Halt		;Wait for Not Busy
	LDA #$80			;Bit7 = Busy Flag.
	STA $FD05			;Set Halt
SubCpu_HaltWait			
	LDA $FD05
	BPL SubCpu_HaltWait	;Wait For Busy (halt to happen)
	RTS	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
;Release SubCPU - Sub CPU will start to try processing 
SubCpu_Release:			;the command at $FC82/$D382
	PSHS A
	LDA #0
	STA $FD05			;Release the SubCpu
	PULS A,PC

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Tiles:	
	ifdef Use8ColorTiles
		binclude "\ResALL\FM7Tiles8color.RAW"
	else
		
		binclude "\ResALL\FM7Tiles.RAW"
	endif
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "\srcALL\BasicFunctions.asm"
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	include "\SrcALL\V1_ChibiSound.asm"
	include "\srcALL\v1_Footer.asm"
	
	
	
	