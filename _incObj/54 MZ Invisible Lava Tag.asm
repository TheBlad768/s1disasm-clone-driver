; ===========================================================================
; ---------------------------------------------------------------------------
; Object 54 - invisible lava tag / hurt marker (MZ)
; ---------------------------------------------------------------------------

LavaTag:
		moveq	#0,d0
		move.b	obRoutine(a0),d0
		move.w	LTag_Index(pc,d0.w),d1
		jmp	LTag_Index(pc,d1.w)
; ===========================================================================
LTag_Index:	dc.w LTag_Main-LTag_Index
		dc.w LTag_ChkDel-LTag_Index

LTag_ColTypes:	; collision types for ReactToItem
		dc.b	$96	; subtype 00 - damaging, $40x$40 (small)
		dc.b	$94	; subtype 01 - damaging, $80x$40 (medium)
		dc.b	$95	; subtype 02 - damaging, $100x$40 (large)
		even
; ===========================================================================

LTag_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advacne to LTag_ChkDel
		moveq	#0,d0					; clear d0 for word-based addressing
		move.b	obSubtype(a0),d0			; get size in subtype (0-2)
		move.b	LTag_ColTypes(pc,d0.w),obColType(a0)	; set collision response type/size based on subtype
		move.l	#Map_LTag,obMap(a0)			; set mappings (blank)
	if FixBugs
		move.b	#4,obRender(a0)				; set playfield-positioned mode
	else
		; There isn't any need to set the object visible flag, since the object has
		; blank mappings (they did exist in the prototype, but were blanked out for
		; the final). Additionally, if one decided to implement proper mappings like
		; in Sonic 2, it would cause it to appear when dying.

		; This bug does technically affect Sonic 2, but was hackishly fixed by having
		; the object use a set of blank mappings when not in edit mode. However, the
		; ARZ leaf generator (whose initialization routine was likely copied from here)
		; does suffer from this bug.
		move.b	#$84,obRender(a0)			; set object visible flag and playfield-positioned mode
	endif
; ---------------------------------------------------------------------------

LTag_ChkDel:	; Routine 2
		out_of_range.w	DeleteObject,obX(a0),1		; contains a (redundant) bmi check
		rts						; don't delete, but also don't display
; ===========================================================================

Map_LTag:	include	"_maps/Lava Tag.asm"
