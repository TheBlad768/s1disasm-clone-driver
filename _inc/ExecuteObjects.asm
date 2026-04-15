; ---------------------------------------------------------------------------
; Object code execution subroutine
; ---------------------------------------------------------------------------

ExecuteObjects:
		lea	(v_objspace).w,a0 ; set address for object RAM
		moveq	#(v_objspace_end-v_objspace)/object_size-1,d7
		moveq	#0,d0
		cmpi.b	#6,(v_player+obRoutine).w
		bhs.s	loc_D362

loc_D348:
		move.b	obID(a0),d0		; load object number from RAM
		beq.s	loc_D358
		add.w	d0,d0
		add.w	d0,d0
		movea.l	Obj_Index-4(pc,d0.w),a1
		jsr	(a1)		; run the object's code
		moveq	#0,d0

loc_D358:
		lea	object_size(a0),a0	; next object
		dbf	d7,loc_D348
		rts
; ===========================================================================

loc_D362:
		moveq	#(v_lvlobjspace-v_objspace)/object_size-1,d7
		bsr.s	loc_D348
		moveq	#(v_lvlobjend-v_lvlobjspace)/object_size-1,d7

loc_D368:
		moveq	#0,d0
		move.b	obID(a0),d0
		beq.s	loc_D378
		tst.b	obRender(a0)
		bpl.s	loc_D378
		bsr.w	DisplaySprite

loc_D378:
		lea	object_size(a0),a0

loc_D37C:
		dbf	d7,loc_D368
		rts
; End of function ExecuteObjects
