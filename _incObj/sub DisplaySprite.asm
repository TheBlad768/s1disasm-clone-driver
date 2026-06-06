; ---------------------------------------------------------------------------
; Subroutine to display a sprite/object, when a0 is the object RAM
; ---------------------------------------------------------------------------

DisplaySprite:
		lea	(v_spritequeue).w,a1		; load sprite priority layer buffer
		move.w	obPriority(a0),d0		; get sprite priority as word (prio 0-7 in upper byte)
		lsr.w	#1,d0				; divide by 2 because each layer is $80 bytes
		andi.w	#spritequeue_layersize*7,d0	; mask to possible offset starts per layer ($380)
		adda.w	d0,a1				; jump to position in queue
		cmpi.w	#spritequeue_layersize-2,(a1)	; is this sprite priority layer full? ($7E bytes)
		bhs.s	DSpr_Full			; if yes, branch
		addq.w	#2,(a1)				; increment sprite counter
		adda.w	(a1),a1				; jump to empty position
		move.w	a0,(a1)				; insert RAM address for object

DSpr_Full:
		rts
; End of function DisplaySprite

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to display a 2nd sprite/object, when a1 is the object RAM
; ---------------------------------------------------------------------------

; DisplaySprite1: <-- old misnomer
DisplaySprite2:
		lea	(v_spritequeue).w,a2		; load sprite priority layer buffer
		move.w	obPriority(a1),d0		; get sprite priority as word (prio 0-7 in upper byte)
		lsr.w	#1,d0				; divide by 2 because each layer is $80 bytes
		andi.w	#spritequeue_layersize*7,d0	; mask to possible offset starts per layer ($380)
		adda.w	d0,a2				; jump to position in queue
		cmpi.w	#spritequeue_layersize-2,(a2)	; is this sprite priority layer full? ($7E bytes)
		bhs.s	DSpr2_Full			; if yes, branch
		addq.w	#2,(a2)				; increment sprite counter
		adda.w	(a2),a2				; jump to empty position
		move.w	a1,(a2)				; insert RAM address for object

DSpr2_Full:
		rts
; End of function DisplaySprite2
