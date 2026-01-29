
; instructions that were used with 0(a#) syntax
; defined to assemble as they originally did

_move:	macro
	; FIXME: Respect zero-offset optimization flag when introduced
	pusho
	opt oz-
	move.\0 \_
	popo
	endm

_clr:	macro
	; FIXME: Respect zero-offset optimization flag when introduced
	pusho
	opt oz-
	clr.\0 \_
	popo
	endm
