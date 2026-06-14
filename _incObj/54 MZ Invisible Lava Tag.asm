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
		dc.b	$95	; subtyle 02 - damaging, $100x$40 (large)
		even
; ===========================================================================

LTag_Main:	; Routine 0
		addq.b	#2,obRoutine(a0)			; advacne to LTag_ChkDel
		moveq	#0,d0					; clear d0 for word-based addressing
		move.b	obSubtype(a0),d0			; get size in subtype (0-2)
		move.b	LTag_ColTypes(pc,d0.w),obColType(a0)	; set collision response type/size based on subtype
		move.l	#Map_LTag,obMap(a0)			; set mappings (debug mode only)
		move.b	#$84,obRender(a0)			; set object visible flag and playfield-positioned mode
; ---------------------------------------------------------------------------

LTag_ChkDel:	; Routine 2
		out_of_range.w	DeleteObject,obX(a0),1		; contains a (redundant) bmi check
		rts						; don't delete, but also don't display
; ===========================================================================

Map_LTag:	include	"_maps/Lava Tag.asm"
