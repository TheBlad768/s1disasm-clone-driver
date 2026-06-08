; ---------------------------------------------------------------------------
; Defeated boss subroutine (shared by all bosses)
; ---------------------------------------------------------------------------

BossDefeated:
		move.b	(v_vblank_byte).w,d0
		andi.b	#7,d0 					; AND with the first 3 bits
		bne.s	.noExplosion 				; don't load an object: this limits explosions to load every 8 frames
		jsr	(FindFreeObj).l
		bne.s	.noExplosion 				; no free objects, exit
		_move.b	#id_Explosion,obID(a1)			; load explosion object
		move.w	obX(a0),obX(a1) 			; set explosion position to boss position
		move.w	obY(a0),obY(a1)
		jsr	(RandomNumber).l 			; generate a random number for position
		move.w	d0,d1 					; copy random number to d1
		moveq	#0,d1 					; ditch the first byte
		move.b	d0,d1 					; copy first byte of d0 to first byte of d1
		lsr.b	#2,d1 					; scale down the random number
		subi.w	#$20,d1 				; shift left by $20 pixels, otherwise all explosions would be on the right side of the boss.
		; No shift is made for the Y position, hard to tell if it was intentional or not, but all explosions are biased downwards due to this.
		add.w	d1,obX(a1) 				; apply random x
		lsr.w	#8,d0 					; shift high byte into low byte
		lsr.b	#3,d0 					; scale down the random number
		add.w	d0,obY(a1) 				; apply random y

; locret_178A2:
.noExplosion:
		rts
; End of function BossDefeated


; ---------------------------------------------------------------------------
; Subroutine to move a boss (shared by all bosses)
; ---------------------------------------------------------------------------

BossMove:
		move.l	obBossX(a0),d2
		move.l	obBossY(a0),d3
		move.w	obVelX(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d2
		move.w	obVelY(a0),d0
		ext.l	d0
		asl.l	#8,d0
		add.l	d0,d3
		move.l	d2,obBossX(a0)
		move.l	d3,obBossY(a0)
		rts
; End of function BossMove