	
	include "\srcALL\v1_header.asm"
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	  
	LDD       #$FC38       ;Font Size ($HHWW=$F848 / $FC38)
	STD       $C82A			;SIZRAS
	
InfLoop:				
	inc $C9FF 		;Incrementing value 
					;Use as Scale / Rotation etc


;Either
	;jsr DrawVectrexScreen			;Show Text and wait for Vblank
	;jsr Cls
	;jsr Monitor				
	
;OR	

	jsr $F192 ; FRWAIT - Wait for beginning of frame boundary (Timer #2 = $0000).
		
	lda #0	   ;Set to >0 for absolute positioning
	sta $C824 ;ZSKIP 1= Zero integrators after draw (Center Pen)
									
	ASSUME dpr:$d0		;SETDP on other systems $D0= Hardware Regs $C8=Ram
	lda #$d0
	tfr a,dp
	
	jsr ResetPenPos	;Center 'pen' position, scale=127

	
	
	
	;jsr DrawDots
	;jsr DrawLines
	
	;jsr DrawString
	
	;jsr DrawDiffyDuffyPacket
	;jsr DrawChibiko
	jsr DrawRotated
	
	jmp InfLoop
			
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Draw Relative dots

DrawDots:	
	lda #16		;Ypos
	ldb #16		;Xpos
	jsr $F2C3  ;DOTAB - Draw A dot
	
	lda #16		;Ypos
	ldb #16		;Xpos
	jsr $F2C3  ;DOTAB - Draw A dot

	jsr ResetPenPos	;Center 'pen' position

;Note: $C9FF is set to AutoInc 0-255
	lda #0		;Ypos
	ldb $C9FF	;Xpos
	jsr $F2C3  ;DOTAB - Draw A dot
	
	jsr ResetPenPos	;Center 'pen' position

	lda $C9FF	;Ypos
	ldb #0		;Xpos
	jsr $F2C3  ;DOTAB - Draw A dot
	
	jsr ResetPenPos	;Center 'pen' position
	rts
	

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Draw a line

DrawLines:
	ldd #$7F7F	;YYXX pos (127,127)
	jsr $F3DF 	;DIFFAB - Draw A line

	jsr ResetPenPos	;Center 'pen' position, scale=127

	ldd #$F0F0 	;Relative Position $XXYY
	jsr $F312 	;POSITN - Set beam pos to (Y,X) A,B	
	
	ldd #$10F0	;YYXX pos -+16,-17
	jsr $F3DF 	;DIFFAB - Draw A line

	jsr ResetPenPos	;Center 'pen' position, scale=127
	rts

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;Draw text to the screen	
	
DrawString:
	ldy #$1010	;Absolute $YYXX Position
	ldu #txtHello
	jsr $EAA8	;Position and draw raster message
	
	ldy #$1515	;Absolute $YYXX Position
	ldu #txtHello
	jsr $EAA8	;Position and draw raster message
	
	jsr ResetPenPos	;Center 'pen' position, scale=127
	rts

txtHello:
	dc.b "HELLO WORLD",$80
				

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawDiffyDuffyPacket:
	ldd #$1010 		;Relative Position $XXYY
	jsr $F312 		;POSITN - Set beam pos to (Y,X) A,B
;Duffy	
	ldx #Duffy
	jsr $F3AD 		;DUFFAB - Draw from ‘Duffy’ style list
	
	ldd #$1010 		;Relative Position $XXYY
	jsr $F312 		;POSITN - Set beam pos to (Y,X) A,B
	
;Duffy + Scale	
	ldx #DuffyScale
	jsr $F3B5 		;DUFLST (DUFFX) - Draw from ‘Duffy’ style list with scale
	
	ldd #$1010 		;Relative Position $XXYY
	jsr $F312 		;POSITN - Set beam pos to (Y,X) A,B
	
;Diffy	
	ldx #Diffy
	jsr $F3CE 		;DIFFAX - Draw from ‘Diffy’ style list
	
	ldd #$1010 		;Relative Position $XXYY
	jsr $F312 		;POSITN - Set beam pos to (Y,X) A,B
	
;Packet	
	ldb #64     	;Scale (127=normal 0=dott 255=double)
	ldx	#Packet 	;Packet address
	jsr $F40E 		;TPACK - Draw according to ‘Packet’ style list
		
	jsr ResetPenPos	;Center 'pen' position, scale=127
	rts

Duffy:		;Duffy List With ItemCount
    dc.b 8	;ItemCount -1
	dc.b $00,$00 	;0	Y,X	Move to this point
    dc.b $F6,$F5	;1	Y,X	Draw this
    dc.b $E6,$0C	;2	Y,X Draw this
    dc.b $FA,$F6	;3	Y,X Draw this
    dc.b $F9,$0A	;4	Y,X Draw this
    dc.b $06,$08	;5	Y,X Draw this
    dc.b $08,$F6	;6	Y,X Draw this
    dc.b $17,$0E	;7	Y,X Draw this
    dc.b $0E,$F2	;8	Y,X Draw this

DuffyScale:	;Duffy List With Scale + ItemCount	
	dc.b 8	;ItemCount -1
	dc.b 64	;Scale (127=normal 0= Dot 255=Double)
	dc.b $00,$00 	;0	Y,X++
    dc.b $F6,$F5	;1	Y,X
    dc.b $E6,$0C	;2	Y,X
    dc.b $FA,$F6	;3	Y,X
    dc.b $F9,$0A	;4	Y,X
    dc.b $06,$08	;5	Y,X
    dc.b $08,$F6	;6	Y,X
    dc.b $17,$0E	;7	Y,X
    dc.b $0E,$F2	;8	Y,X
	
Diffy:		;Diffy List With ItemCount
    dc.b 7	;ItemCount -1
	;dc.b $00,$00 	;No initial move on Diffy
    dc.b $F6,$F5	;0	Y,X	Draw this
    dc.b $E6,$0C	;1	Y,X Draw this
    dc.b $FA,$F6	;2	Y,X Draw this
    dc.b $F9,$0A	;3	Y,X Draw this
    dc.b $06,$08	;4	Y,X Draw this
    dc.b $08,$F6	;5	Y,X Draw this
    dc.b $17,$0E	;6	Y,X Draw this
    dc.b $0E,$F2	;7	Y,X Draw this
	
Packet:		;Packet List
	dc.b $00,$00,$00 	;0	Y,X	Move to this point
    dc.b $FF,$F6,$F5	;1	Y,X	Draw this
    dc.b $FF,$E6,$0C	;2	Y,X Draw this
    dc.b $FF,$FA,$F6	;3	Y,X Draw this
    dc.b $FF,$F9,$0A	;4	Y,X Draw this
    dc.b $FF,$06,$08	;5	Y,X Draw this
    dc.b $FF,$08,$F6	;6	Y,X Draw this
    dc.b $FF,$17,$0E	;7	Y,X Draw this
    dc.b $FF,$0E,$F2	;8	Y,X Draw this
	dc.B $01	;End of list	
	
;Duffy List is a sequence of connected lines.
;Diffy is the same with no initial move
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

DrawChibiko:		;Draw a vector graphic

;Draw Chibiko! (part 1)
	LDd     #$1010 		;Relative Position $XXYY
	jsr $F312 	;POSITN - Set beam pos to (Y,X) A,B
	
	LDB     $C9FF        ;Scale (127=normal 0=dott 255=double)
	LDX     #PacketChibi     ;Packet address
	jsr $F40E 	;Tpack - Draw according to ‘Packet’ style list
		
	jsr ResetPenPos	;Center 'pen' position
	rts
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;	
;RotateTest

DrawRotated:	
;Rotate packet list
	lda $C9FF			;Angle
	ldx #PacketSmile	;Source Packet list to rotate
	ldu #$C880			;Destination of rotated data (RAM)
	jsr  $F61F			;Rotate packet list
	
;Draw Packet
	LDB #32        		;Scale
	ldx #$C880	   		;Dest (RAM)
	jsr $F40E 			;Tpack - Draw Packet
	
PacketSmile:			;Smiley for rotation
    dc.b $00,$32,$E9
    dc.b $FF,$00,$26
    dc.b $FF,$E1,$1D
    dc.b $FF,$D2,$02
    dc.b $FF,$FF,$00
    dc.b $FF,$E7,$DE
    dc.b $FF,$02,$CE
    dc.b $FF,$2A,$EE
    dc.b $FF,$29,$0B
    dc.b $FF,$13,$15
    dc.b $00,$E6,$02
    dc.b $FF,$F7,$F8
    dc.b $FF,$EF,$0C
    dc.b $FF,$FF,$00
    dc.b $FF,$12,$0C
    dc.b $FF,$0A,$F1
    dc.b $00,$00,$1C
    dc.b $FF,$F6,$0F
    dc.b $FF,$F2,$F7
    dc.b $FF,$09,$F5
    dc.b $FF,$0F,$05
    dc.b $00,$D6,$D0
    dc.b $FF,$EB,$18
    dc.b $FF,$00,$18
    dc.b $FF,$1E,$1B
    dc.b $01	
	
	
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;


ResetPenPos:
	pshs x,d
;Zero the integrators only 		
		jsr $F36B	;ZERO - Zero the integrators only
;Reset Pos /Scale 
		ldx #PositionList	;Position Vector (Y,X)
		ldb #127	;Scale (127=normal 64=half 255=double)
		jsr $F30E	;POSITB - Release integrators and position beam
	puls x,d,pc

PositionList:
	dc.b 0,0				

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

PacketChibi:					;Packet List Without Scale
    dc.b $00,$08,$EF	;Cmd,Y,X
    dc.b $FF,$F8,$FB
    dc.b $FF,$FA,$08
    dc.b $FF,$F3,$FA
    dc.b $FF,$F2,$04
    dc.b $FF,$F9,$FD
    dc.b $FF,$F7,$00
    dc.b $FF,$FC,$FB
    dc.b $FF,$FA,$02
    dc.b $FF,$00,$03
    dc.b $FF,$0D,$09
    dc.b $FF,$06,$FF
    dc.b $FF,$F9,$F7
    dc.b $00,$08,$08
    dc.b $FF,$07,$02
    dc.b $FF,$01,$F9
    dc.b $00,$00,$06
    dc.b $FF,$FF,$09
    dc.b $FF,$FA,$04
    dc.b $FF,$FB,$00
    dc.b $FF,$FE,$FD
    dc.b $FF,$F5,$0B
    dc.b $FF,$FE,$02
    dc.b $FF,$05,$04
    dc.b $FF,$07,$FD
    dc.b $FF,$05,$FB
    dc.b $FF,$FD,$FC
    dc.b $FF,$03,$FC
    dc.b $FF,$FF,$00
    dc.b $00,$02,$07
    dc.b $FF,$05,$01
    dc.b $FF,$04,$FD
    dc.b $00,$01,$F8
    dc.b $FF,$00,$07
    dc.b $FF,$04,$06
    dc.b $FF,$07,$00
    dc.b $FF,$10,$FB
    dc.b $FF,$02,$0D
    dc.b $FF,$06,$00
    dc.b $FF,$09,$FA
    dc.b $FF,$F9,$F9
    dc.b $FF,$FD,$FC
    dc.b $FF,$02,$F7
    dc.b $FF,$F8,$04
    dc.b $FF,$00,$02
    dc.b $FF,$F7,$00
    dc.b $00,$04,$FD
    dc.b $FF,$00,$05
    dc.b $00,$06,$FE
    dc.b $00,$FF,$00
    dc.b $FF,$08,$03
    dc.b $00,$01,$F5
    dc.b $FF,$05,$F7
    dc.b $FF,$0A,$FC
    dc.b $FF,$08,$00
    dc.b $FF,$02,$0C
    dc.b $FF,$00,$10
    dc.b $FF,$FB,$07
    dc.b $FF,$FF,$00
    dc.b $FF,$00,$07
    dc.b $FF,$FC,$01
    dc.b $FF,$FC,$FD
    dc.b $FF,$FD,$FA
    dc.b $00,$0A,$03
    dc.b $FF,$FB,$00
    dc.b $FF,$03,$02
    dc.b $FF,$02,$FE
    dc.b $00,$01,$FE
    dc.b $FF,$FB,$F9
    dc.b $FF,$FF,$FB
    dc.b $FF,$02,$FD
    dc.b $FF,$06,$01
    dc.b $FF,$03,$07
    dc.b $00,$F8,$FF
    dc.b $FF,$FF,$00
    dc.b $FF,$03,$FD
    dc.b $FF,$FE,$FE
    dc.b $FF,$FE,$02
    dc.b $00,$0A,$F2
    dc.b $FF,$FC,$04
    dc.b $FF,$FA,$02
    dc.b $FF,$FC,$FE
    dc.b $FF,$05,$F6
    dc.b $FF,$04,$FF
    dc.b $FF,$05,$05
    dc.b $00,$F7,$00
    dc.b $FF,$01,$01
    dc.b $FF,$00,$02
    dc.b $FF,$FD,$01
    dc.b $00,$F9,$03
    dc.b $FF,$01,$03
    dc.b $FF,$FF,$04
    dc.b $FF,$FE,$03
    dc.b $FF,$04,$00
    dc.b $FF,$02,$02
    dc.b $FF,$FC,$01
    dc.b $FF,$FD,$00
    dc.b $FF,$FD,$FB
    dc.b $FF,$02,$FA
    dc.b $FF,$03,$00
    dc.b $FF,$02,$FD
    dc.b $00,$09,$F2
    dc.b $FF,$FF,$FF
    dc.b $FF,$0A,$FB
    dc.b $FF,$0C,$09
    dc.b $FF,$07,$08
    dc.b $FF,$00,$07
    dc.b $FF,$FD,$0A
    dc.b $FF,$F9,$09
    dc.b $FF,$F8,$06
    dc.b $FF,$F0,$02
    dc.b $FF,$FF,$FF
    dc.b $FF,$FA,$FB
    dc.b $FF,$F9,$00
    dc.b $FF,$0A,$0E
    dc.b $FF,$03,$06
    dc.b $FF,$04,$04
    dc.b $FF,$01,$F7
    dc.b $FF,$08,$FB
    dc.b $FF,$F8,$FC
    dc.b $FF,$FC,$02
    dc.b $FF,$F9,$FA
    dc.b $00,$12,$07
    dc.b $FF,$02,$01
    dc.b $FF,$08,$07
    dc.b $FF,$0F,$05
    dc.b $FF,$EE,$03
    
    dc.b $FF,$F5,$03
    dc.b $FF,$FB,$FD
    dc.b $FF,$03,$FC
    dc.b $FF,$08,$02
    dc.b $FF,$03,$FB
    dc.b $FF,$FB,$FA
    dc.b $00,$17,$DF
    dc.b $FF,$06,$02
    dc.b $FF,$03,$F8
    dc.b $FF,$00,$ED
    dc.b $FF,$F7,$F8
    dc.b $FF,$F6,$03
    dc.b $00,$DE,$0F
    dc.b $FF,$05,$F1
    dc.b $FF,$08,$F1
    dc.b $FF,$FB,$F9
    dc.b $FF,$F4,$FD
    dc.b $FF,$03,$0B
    dc.b $FF,$06,$04
    dc.b $FF,$F8,$05
    dc.b $FF,$FD,$10
    dc.b $00,$F8,$06
    dc.b $FF,$F8,$F6
    dc.b $FF,$F2,$FF
    dc.b $FF,$0E,$FD
    dc.b $FF,$FC,$F9
    dc.b $FF,$F3,$00
    dc.b $FF,$0C,$F9
    dc.b $FF,$1B,$02
    dc.b $00,$06,$0A
    dc.b $00,$08,$F2
    dc.b $FF,$10,$01
    dc.b $FF,$13,$05
    dc.b $FF,$FF,$00
    dc.b $FF,$F7,$03
    dc.b $FF,$00,$08
    dc.b $FF,$F7,$01
    dc.b $00,$FF,$3A
    dc.b $FF,$0E,$01
    dc.b $FF,$F8,$03
    dc.b $00,$0C,$08
    dc.b $FF,$08,$03
    dc.b $FF,$E2,$07
    dc.b $FF,$E8,$00
    dc.b $FF,$E3,$F8
    dc.b $FF,$11,$F6
    dc.b $FF,$EC,$FA
    dc.b $FF,$0D,$FF
    dc.b $FF,$02,$F0
    dc.b $01

;Cmd FF=Pen Down   00=Pen Up   01=End of list

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
	
	include "\srcALL\v1_Monitor.asm"
	include "\srcALL\v1_Functions.asm"
	
	include "\srcALL\v1_Footer.asm"
	
	
	
