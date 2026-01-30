
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

_add:	macro
	; FIXME: Respect zero-offset optimization flag when introduced
	pusho
	opt oz-
	add.\0 \_
	popo
	endm

_cmp:	macro
	; FIXME: Respect zero-offset optimization flag when introduced
	pusho
	opt oz-
	cmp.\0 \_
	popo
	endm

