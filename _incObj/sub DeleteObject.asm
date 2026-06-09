; ---------------------------------------------------------------------------
; Subroutine to delete an object
; ---------------------------------------------------------------------------

DeleteObject:
		movea.l	a0,a1			; move self object RAM address a0 to a1
; ---------------------------------------------------------------------------

DeleteChild:	; object is alread already in a1
		moveq	#0,d1			; overwrite with zeroes
		moveq	#object_size/4-1,d0	; cover all $40 bytes of object RAM slot
DelObj_Loop:	move.l	d1,(a1)+		; clear the object RAM
		dbf	d0,DelObj_Loop		; repeat for length of object RAM
		rts				; deletion done
; End of function DeleteObject
