AddHL_HL	macro 				
		asla z_l
		rola z_h
	endm 
rlca	macro 
		andcc #%11111110; clc
		adc #$80
		rol
	endm
rrca	macro 
		pshs a
			rora
		puls a
		rora
	endm
	
PushPair macro ra	;Push a pair onto the stack (eg PushPair z_HL)
		ldd ra			
		pshs d				;Push lower Zpage entry
	endm
	
PullPair macro ra	;Pull a pair onto the stack (eg PullPair z_HL)
		puls d
		std ra		;Pull lower Zpage entry
	endm
PushPairSafe macro ra	;Push a pair onto the stack (eg PushPair z_HL)
		std z_spec
		ldd ra			
		pshs d				;Push lower Zpage entry
		ldd z_spec
	endm				;Push higher Zpage entry
	
PullPairSafe macro ra	;Pull a pair onto the stack (eg PullPair z_HL)
		std z_spec
		puls d
		std ra			;Pull higher Zpage entry
		ldd z_spec
	endm
LoadPair macro zr,val
		ldd #val
		std zr
	endm
LoadPairSafe macro zr,val
		pshs d
			ldd #val
			std zr
		puls d
	endm

LoadPairFromsafe macro zr,addr
		pshs d
			ldd addr
			std zr
		puls d
	endm
LoadPairFrom macro zr,addr
		ldd addr
		std zr
	endm
SavePairTo	macro zr,addr
		ldd zr
		std addr
		
	endm
LoadOne	macro zr,val
		lda #val
		sta zr
	endm
AddPair	macro zr,val
		ldd zr
		addd #val
		std zr
	endm
	