UserRam Equ $C900	;Ram starts C800
z_Regs equ $C0
	ORG     $0000
	Padding Off
	DC.B      "g GCE 1983", $80       ;(C) GCE 1983	- Don't Change
	DC.W      $FD0D 				  ;Music File
    DC.B      $F8, $50, $20, -$46     ;Title Pos H,W,Y,X
    DC.B      "LEARNASM.NET",$80		;Cart Title (length can change)
    DC.B      0                       ;Header Ends
	
	ASSUME dpr:$C8		;SETDP on other systems $D0= Hardware Regs $C8=Ram
	lda #$C8
	tfr a,dp
	jsr ScreenInit
	