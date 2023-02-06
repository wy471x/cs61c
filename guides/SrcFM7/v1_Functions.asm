printchar equ $D08E
ReadChar equ $D072

Cls:
	lda #$0C
	jmp printchar

NewLine:
	pshs d
		lda #13
		jsr printchar
		lda #10
		jsr printchar
	puls d,pc