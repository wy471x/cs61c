	
	include "\srcALL\v1_header.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	
	;jmp NewRegisters
	;jmp Maths
	jmp Maths2
	
NewRegisters:	
;We now have 4 8 bit accumulators! (A B E F)
	lda #$11			;Old 8 bit 6809 register
	ldb #$12			;Old 8 bit 6809 register
	lde #$13			;New 8 bit 6309 register
	ldf #$14			;New 8 bit 6309 register

	sta $7100			;We also have store commands
	stb $7101
	ste $7102
	stf $7103
	
	jsr Monitor			;Show the Registers
	
	
;These combine to form 2 16 bit accumulators

	ldd #$2324			;Old D accumulator (AB)
	ldw #$3536			;New W accumulator (EF)
	
	std $7104
	stw $7106
	
	jsr Monitor			;Show the Registers
	
	
;These combine to form 1 32 bit accumulators (ABEF = DW)
	
	ldq #$FEDCBA98		;New 32 bit Q (ABEF)
	stq $7108
	
	jsr Monitor			;Show the Registers
			
	ldy #16				;Bytes to dump
	ldx #$7100			;Address to dump
	jsr Memdump

	
;We can't directly set V, but can transfer to it
	tfr w,v
	
;the Zero register always contains 0 (z in asw)
	tfr z,x

;MD is the mode flags #1 turns on native mode
	ldmd #1 ;0I------FN
			;F= FIRQ pushes all registers (1=on)
			;N= Native mode (1=on)
	
	jsr Monitor			;Show the Registers
	
	jmp InfLoop
	
Maths:	
;we have new clear commands
	clre				;Clear 8 bit E
	clrf				;Clear 8 bit F
	clrd				;Clear 16 bit D
	clrw				;Clear 16 bit W
	jsr Monitor			;Show the Registers

;We have new inc and dec commands
	ince				;8 bit INCs
	incf
	incd				;16 bit INCs
	incw	
	jsr Monitor			;Show the Registers
	
	dece				;8 bit DECs
	decf
	decd				;16 bit DECs
	decw	
	jsr Monitor			;Show the Registers

;We have new Add and Sub commands
	adde #8				;We have new 8 bit reg adds
	addf #8
	addw #$1111			;We also have 16 bit reg adds
	jsr Monitor			;Show the Registers

	sube #8				;We have new 8 bit reg sub
	subf #8
	subw #$1111			;We also have 16 bit reg sub
	jsr Monitor			;Show the Registers
	
	jmp InfLoop
	
	
Maths2:		
	ldd #1
	tfr d,v
	clrd
		
;We can now Add and Sub between registers
	addr v,w			;ADDR adds a register to another
	subr v,d			;SUBR subtracts a register from another 
	jsr Monitor			;Show the Registers
	
;We also have Add/Sub with carry reg to reg commands	
	adcr v,w			;ADCR adds a register to another with carry
	sbcr v,d			;SBCR subtracts a register from another with carry
	jsr Monitor			;Show the Registers
	
;We have no 32 bit add or sub, but we can do it in two parts
	addw #$8008			;Add to Q Low part W
	adcd #0				;Add with carry to Q high part D
	;adcr z,d			;This should work, but doesn't seem to compile?	
	jsr Monitor			;Show the Registers
	
	subw #$8008			;Sub from Q Low part W
	sbcd #0				;Subtract with carry to Q high part D
	jsr Monitor			;Show the Registers

	jmp InfLoop
	
InfLoop:
	ifdef BuildVTX
		jsr DrawVectrexScreen	;Wait for Vsync and Redraw screen
	endif
	jmp InfLoop			;Infinite Loop
	
TestMemory:
	dc.l $12345678
	
PrintString:			;Print 255 terminated string
	lda ,Y+
	cmpa #255
	beq PrintStringDone
	jsr printchar
	jmp PrintString
PrintStringDone:	
	rts	
	
Hello:
	dc.b "HellO WORLD!?",255
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	
	include "\srcALL\v1_Footer.asm"
	
	
	