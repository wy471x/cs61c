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
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	

	;jmp DoTest_Cls		;Clear the screen with a color
	;jmp DoTest_Points	;Draw Dots
	;jmp DoTest_Put		;Draw Console Text
	;jmp DoTest_Symbol	;Draw Graphics text (With Color/Scale/Rotation)
	;jmp DoTest_Line	;Draw lines and boxes
	
	;jmp DoTest_Fill	;Fill an area
	;jmp DoTest_Change	;Swap a color
	jmp DoTest_Inkey	;Wait for a key
	;jmp DoTest_PutBlock ;SendBitmapData
	;jmp DoTest_Yama	;Transfer program code and run	
	
	;jmp Palettes		;Set Color Palettes
	jmp Masks 			;Use View/Write channel Masks
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoTest_Cls:		;Clear the screen
	ldx #TestCLS					;Source
	LDB #(TestCLS_End-TestCLS)/2	;length (Words)
	jsr SubCpu_DoCmd				;Send it to $FC82
	jmp InfLoop

TestCLS:
	dc.b $02	;02=Erase 
	dc.b 0,1	;(Mode All/Scroll/Page1/Page2), Color
TestCLS_End:		
		
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
DoTest_Points:		;Draw Dots
	ldx #TestPoints						;Source
	LDB #(TestPoints_End-TestPoints)/2	;length (Words)
	jsr SubCpu_DoCmd					;Send it to $FC82
	jmp InfLoop

TestPoints:
	dc.b $17,2 ;17=Points 2=Count
;Dot 1
	dc.w 150,100	;(X,Y)
	dc.b 6,0		;Color,Operation
;Dot 2
	dc.w 160,110	;(X,Y)
	dc.b 6,0		;Color,Operation
TestPoints_End:	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
		
DoTest_Put:			;Send Text To screen
	ldx #TestPut					;Source
	LDB #(TestPut_End-TestPut)/2	;length (Words)
	jsr SubCpu_DoCmdFull			;Send it to $FC80
	jmp InfLoop

TestPut:
	dc.b $0		;128=Continue last string
	dc.b $0		;Ignored
	dc.b $3		;3=PUT
	dc.b 5+3		;ByteCount
	dc.b $12,5,5	;$12=Locate X,Y
	dc.b "HELLO"	
TestPut_End:	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoTest_Symbol:	;Draw text with color, rotation and scaling
	ldx #TestSymbol						;Source
	LDB #(TestSymbol_End-TestSymbol)/2	;length (Words)
	jsr SubCpu_DoCmd					;Send it to $FC82
	jmp InfLoop

TestSymbol:
	dc.b $19	;$19 = Symbol
	dc.b 3		;Color
	dc.b 0 		;Function Code (0=Pset)
	dc.b 3		;Rotation (0-3 = 0,90,180,270)
	dc.b 2,2	;Scale X,Y (1=normal)
	dc.w 100,10 ;Pos (X,Y)
	dc.b 9		;Chars
	dc.b "FM7 Rocks"	;String (9 Chars)
TestSymbol_End:	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoTest_Line:	;Draw a line / Box
;Draw a line
	ldx #TestLine					;Source
	LDB #(TestLine_End-TestLine)/2	;length (Words)
	jsr SubCpu_DoCmd				;Send it to $FC82

;Draw a box
	ldx #TestBox					;Source
	LDB #(TestBox_End-TestBox)/2	;length (Words)
	jsr SubCpu_DoCmd				;Send it to $FC82
	
;Draw a box (Xor)
	ldx #TestBox2					;Source
	LDB #(TestBox2_End-TestBox2)/2	;length (Words)
	jsr SubCpu_DoCmd				;Send it to $FC82
	
	jmp InfLoop
	
TestLine:
	dc.b $15 	;$15=Line 
	dc.b 2,0	;Color (KBRMGCYW), Op (PSET/PRESET/OR/And/XOR/NOT)
	dc.w 110,110,164,164	;(X,y)-(x,y)
	dc.b 0		;Fill mode (0=Line,1=Square,2=Fill)
TestLine_End:	

TestBox:
	dc.b $15	;$15=Line
	dc.b 4,4	;Color (KBRMGCYW), Op (PSET/PRESET/OR/And/XOR/NOT)
	dc.w 10,10,64,64 ;(X,y)-(x,y)
	dc.b 2		;Fill mode (0=Line,1=Square,2=Fill)
TestBox_End:	

TestBox2:
	dc.b $15	;$15=Line
	dc.b 4,4	;Color (KBRMGCYW), Op (PSET/PRESET/OR/And/XOR/NOT)
	dc.w 32,32,96,96;(X,y)-(x,y)
	dc.b 2		;Fill mode (0=Line,1=Square,2=Fill)
TestBox2_End:	


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
DoTest_Fill:	;Paint
	ldx #TestBoxF					;Test box to fill
	LDB #(TestBoxF_End-TestBoxF)/2
	jsr SubCpu_DoCmd	
	
	ldx #TestFill					;Source
	LDB #(TestFill_End-TestFill)/2	;length (Words)
	jsr SubCpu_DoCmd				;Send it to $FC82
	jmp InfLoop

TestFill:
	dc.b $18			;$18=Paint
	dc.w 320,20			;Xpos,Ypos
	dc.b 7				;Color to fill
	dc.b 7				;Boundary Color Count
	dc.b 1,2,3,4,5,6,7	;Boundary color
TestFill_End:	

TestBoxF:
	dc.b $15	;$15=Line
	dc.b 4,0	;Color (KBRMGCYW), Op
	dc.w 310,10,364,128 ;(X,y)-(x,y)
	dc.b 1		;Fill mode (0=Line,1=Square,2=Fill)
TestBoxF_End:	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoTest_Change:		;Change Color
	jsr monitor
	jsr monitor
	ldx #TestBoxF
	LDB #(TestBoxF_End-TestBoxF)/2		;Test graphics
	jsr SubCpu_DoCmd	
	ldx #TestFill
	LDB #(TestFill_End-TestFill)/2
	jsr SubCpu_DoCmd	
		
	ldx #TestChange						;Source
	LDB #(TestChange_End-TestChange)/2	;length (Words)
	jsr SubCpu_DoCmd					;Send it to $FC82
	jmp InfLoop
	
TestChange:
	dc.b $1A			;$1A=CHANGE COLOR
	dc.w 0,10,400,30	;(x,y)-(x,y)
	dc.b 2				;SwapCount
	dc.b 7,6			;Old Color,New Color
	dc.b 4,3			;Old Color,New Color
TestChange_End:

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
DoTest_Inkey:	;Wait for a key from the cursor
	ldx #TestInkey						;Source
	LDB #(TestInkey_End-TestInkey)/2	;length (Words)
	jsr SubCpu_DoCmd					;Send it to $FC82
	
	jsr SubCpu_Halt		;Stop the Sub CPU so we can read ram
	lda $FC83			;Key code
	ldb $FC84			;Key read? (1=yes)
	pshs d
		lda #%10000000
		sta $FC80		;Ready Request 
;(Ready Request FC80 Bit7=1 Stops CPU locking when no command sent)	
		
	puls d
	jsr SubCpu_Release
	jsr monitor			;A=Ascii   B=Key Read?
	
	jmp DoTest_Inkey
	
TestInkey:
	dc.b $29	;$29=INKEY
	dc.b $3		;(Bit0=Wait,Bit1=Reset buffer)
TestInkey_End:	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoTest_PutBlock:	;Send First Block of color sprite

	ldx #BitmapFile	;864 byte image = 48x48 3bpp
	ldb #8			;96 bytes per block  = 9 blocks (8 + first)
	pshs b
		pshs x
			ldx #SendCMDPut						;Source
			LDB #(SendCMDPut_End-SendCMDPut)/2	;length (Words)
			jsr SubCpu_Halt		;Stop Sub CPU
			jsr SubCpu_SendAlt	;Send it to $FC80
		puls x
		LDB #48					;Words to Send
		jsr SubCPU_SendAltB		;Send 48 Words from X
		jsr SubCpu_Release		;Release Sub CPU
	puls b
	
SendAgain:			;Send Other blocks
	pshs b
		pshs x
			ldx #SendCMDContinue	;Continue sprite
			LDB #(SendCMDContinue_End-SendCMDContinue)/2
			jsr SubCpu_Halt		;Stop Sub CPU
			jsr SubCpu_SendAlt	;Send it to $FC80
		puls x
		LDB #48					;Words to Send
		jsr SubCPU_SendAltB		;Send 48 Words from X
		jsr SubCpu_Release		;Release Sub CPU
	puls b
	decb						;Repeat until all blocks sent
	bne SendAgain				;More Blocks to send
	jmp InfLoop
	
SendCMDPut:
	dc.b 0,128		;(128=Multiblock)
	dc.b $1E		;$1E=PUT BLOCK2
	dc.w 10,10,10+47,10+47 ;(x,y)-(x,y)
	dc.b 0			;unused
	dc.b 0			;Func (0=PSET)
	dc.b 96			;Bytes
SendCMDPut_End:	
	
SendCMDContinue:
	dc.b 0,128	;More Data
	dc.b $64	;$64=CONTINUE
	dc.b 96		;Bytes
SendCMDContinue_End:

BitmapFile:

	binclude "\ResALL\BitMapTestFM7.raw"
	
;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	;dc.b $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF, $FF,$FF,$FF,$FF,$FF,$FF
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DoTest_Yama:		;Secret 'Yamauchi commands' - direct SubCPU control
	jsr Monitor
	
	ldx #CmdYamaTransfer							;Source
	LDB #(CmdYamaTransfer_End-CmdYamaTransfer)/2	;length (Words)
	jsr SubCpu_DoCmd								;Send it to $FC82
	
	jmp InfLoop
	
CmdYamaTransfer:	;Transfer a test program to the Sub CPU
	dc.b $3F  		;$3F = Yamauchi command
	;dc.b "YAMAUCHI"	;Actually FM-7 doesn't check this (FM8 did) it can be anything!
	dc.b "LAMAICHI"		;8 Bytes of something!
	      
	
	dc.b $91		;$91 = Yamauchi Move
	dc.w $D382+CmdYamaTransferPrg-CmdYamaTransfer ;Source Addr (MAIN Ram)
	dc.w $C000									  ;Dest (SUB Console ram)
	dc.w CmdYamaTransfer_End-CmdYamaTransfer	  ;Length in bytes
	
	dc.b $93		;$93 = Yamauchi Call
	DC.W $C000		;Address to call (Console Ram)
	
	dc.b $90		;$90 = Yamauchi End
	
;This program will be transferred to $C000 in SUB Cpu
;Use Relative commands ONLY!	
CmdYamaTransferPrg:
	ldx #$4001	;4000+ = Red Channel
	ldy #$4000
TAgain:			
	ldd ,X++
	std ,y++
	cmpy #$8000
	bne TAgain
	rts
	
CmdYamaTransfer_End:;End of transferred area
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


; Execute sub program

CmdYamaExec:
	dc.b $3F  		;YamaUchi command					;$FC82
	
	dc.b "YAMAUCHI"	;Actually FM-7 doesn't check this (FM8 did) it can be anything!
	
	dc.b $93		;Call
	DC.W $C000		;Address to call (Console Ram)
	DC.B $90		;End
CmdYamaExec_End:

	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
Palettes:	
	ldx #BitmapFile	;864 byte image = 48x48 3bpp
	ldb #8			;96 bytes per block  = 9 blocks (8 + first)
	pshs b
		pshs x
			ldx #SendCMDPut		;Send first block of sprite
			LDB #(SendCMDPut_End-SendCMDPut)/2	;Words to send
			jsr SubCpu_Halt		;Stop Sub CPU
			jsr SubCpu_SendAlt	;Send it to $FC80
		puls x
		LDB #48					;Words to Send
		jsr SubCPU_SendAltB		;Send 96 bytes from X
		jsr SubCpu_Release
	puls b
	
SendAgain2:
	pshs b
		pshs x
			ldx #SendCMDContinue ;Send first block of sprite
			LDB #(SendCMDContinue_End-SendCMDContinue)/2	;Words to send
			jsr SubCpu_Halt		;Stop Sub CPU
			jsr SubCpu_SendAlt	;Send it to $FC80
		puls x
		LDB #48
		jsr SubCPU_SendAltB
		jsr SubCpu_Release
	puls b
	decb						;Repeat until all blocks sent
	
PalLoop:
	bne SendAgain2
	;     -----GRB	
	lda #%00000111		;White
	jsr SetPalettes
	;     -----GRB	
	lda #%00000011		;Magenta
	jsr SetPalettes
	jmp PalLoop
	
SetPalettes:
	sta $FD3F	;Color 7
	jsr Delay
	sta $FD3E	;Color 6
	jsr Delay
	sta $FD3D	;Color 5
	jsr Delay
	sta $FD3C	;Color 4
	jsr Delay
	sta $FD3B	;Color 3
	jsr Delay
	sta $FD3A	;Color 2
	jsr Delay
	sta $FD39	;Color 1
	jsr Delay
	sta $FD38	;Color 0
	jsr Delay
	rts
	
Delay
	ldx #0
Delay2
	nop
	nop
	nop
	nop
	leax -1,x
	bne delay2
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

	
Masks:	
	jsr Monitor
	jsr ReadChar
	
		 ;-GRB-GRB	Display / Write
	lda #%01000000 		
	sta $FD37		;View/Write mask - View RB / Write RGB
	jsr Monitor
	jsr ReadChar

		 ;-GRB-GRB	Display / Write
	lda #%01100000 
	sta $FD37		;View/Write mask - View B / Write RGB
	jsr Monitor
	jsr ReadChar
	
		 ;-GRB-GRB	Display / Write
	lda #%00010000 
	sta $FD37		;View/Write mask - View GR / Write RGB
	jsr Monitor
	jsr ReadChar
	
 		 ;-GRB-GRB	Display / Write
	lda #%00000010 
	sta $FD37		;View/Write mask - View GRB / Write GB
	jsr Monitor
	jsr ReadChar
	
		 ;-GRB-GRB	Display / Write
	lda #%00000100 
	sta $FD37		;View/Write mask - View GRB / Write RB
	jsr Monitor
	jsr ReadChar
	
		 ;-GRB-GRB	Display / Write
	lda #%00000110 
	sta $FD37		;View/Write mask - View GRB / Write B
	jsr Monitor
	jsr ReadChar
	
		 ;-GRB-GRB	Display / Write
	lda #%00000011 
	sta $FD37		;View/Write mask - View GRB / Write G
	jsr Monitor
	jsr ReadChar
	
	jmp infloop

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
InfLoop:

	jmp InfLoop
	




;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;Transfer Command data without first two bytes			
SubCpu_DoCmd:			;Transfer $FC82-$FCFF / $D382-$D3FF
	incb
	jsr SubCpu_Halt		;Stop SubCPU (Shared Ram Accessible)
	jsr SubCpu_Send		;Transfer data to shared Ram
	jsr SubCpu_Release	;Release SubCPU (SubCPU will process command)
	rts

;Transfer Command data with first two bytes	
SubCpu_DoCmdFull:		;Transfer $FC80-$FCFF / $D380-$D3FF
	incb
	jsr SubCpu_Halt		;Stop SubCPU (Shared Ram Accessible)
	jsr SubCPU_SendAlt	;Transfer data to shared Ram
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

;Wait for SubCPU to finish processing it's commands
SubCpu_Wait:
	PSHS	A
SubCpu_Wait2:
	LDA $FD05		 ;Wait for SubCpu to be ready (Bit7 1=busy)
	BMI SubCpu_Wait2 ;Bit7 = Busy Flag.
	PULS A,PC						
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	include "\srcALL\BasicFunctions.asm"
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	include "\SrcALL\V1_ChibiSound.asm"
	include "\srcALL\v1_Footer.asm"
	
	
	
	