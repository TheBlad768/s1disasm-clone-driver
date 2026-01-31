
; instructions that were used with 0(a#) syntax
; defined to assemble as they originally did

_move:	macro
	if zeroOffsetOptimization=0
		pusho
		opt oz-
	endif
	move.\0 \_
	if zeroOffsetOptimization=0
		popo
	endif
	endm

_clr:	macro
	pusho
	opt oz-
	clr.\0 \_
	if zeroOffsetOptimization=0
		popo
	endif
	endm

_add:	macro
	if zeroOffsetOptimization=0
		pusho
		opt oz-
	endif
	add.\0 \_
	if zeroOffsetOptimization=0
		popo
	endif
	endm

_cmp:	macro
	if zeroOffsetOptimization=0
		pusho
		opt oz-
	endif
	cmp.\0 \_
	if zeroOffsetOptimization=0
		popo
	endif
	endm

_cmpi:	macro
	if zeroOffsetOptimization=0
		pusho
		opt oz-
	endif
	cmpi.\0 \_
	if zeroOffsetOptimization=0
		popo
	endif
	endm

_tst:	macro
	if zeroOffsetOptimization=0
		pusho
		opt oz-
	endif
	tst.\0 \_
	if zeroOffsetOptimization=0
		popo
	endif
	endm
