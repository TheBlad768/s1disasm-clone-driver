; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to	make the sides of a monitor solid
; 
; input:
;	d1 = width/2
;	d2 = height/2
; 
; output:
;	d0 = distance from side of monitor
;	d1 = collision type: 0 = none; 1 = side collision; -1 = top/bottom collision
;	d3 = distance from top of monitor
; ---------------------------------------------------------------------------

Mon_SolidSides:
		lea	(v_player).w,a1			; load Sonic's player object
		move.w	obX(a1),d0			; get Sonic's X position
		sub.w	obX(a0),d0			; subtract monitor's X position from it
		add.w	d1,d0				; add collision width
		bmi.s	.no_collision			; if Sonic is to the left of the monitor, branch
		move.w	d1,d3				; copy collision width
		add.w	d3,d3				; double it 
		cmp.w	d3,d0				; is Sonic to the right of the monitor?
		bhi.s	.no_collision			; if yes, branch

		move.b	obHeight(a1),d3			; get Sonic's collision height
		ext.w	d3				; extend to word
		add.w	d3,d2				; add it to monitor's collision height
		move.w	obY(a1),d3			; get Sonic's Y position
		sub.w	obY(a0),d3			; subtract monitor's Y position from it
		add.w	d2,d3				; add collision height
		bmi.s	.no_collision			; if Sonic is above the monitor, branch
		add.w	d2,d2				; double collision height
		cmp.w	d2,d3				; is Sonic below the monitor?
		bcc.s	.no_collision			; if yes, branch
		
		tst.b	(f_playerctrl).w		; is Sonic's object interaction disabled?
		bmi.s	.no_collision			; if yes, branch
		cmpi.b	#6,(v_player+obRoutine).w	; is Sonic dying?
		bhs.s	.no_collision			; if yes, branch
		tst.w	(v_debuguse).w			; is debug mode active?
		bne.s	.no_collision			; if yes, branch
		
		cmp.w	d0,d1				; is Sonic between left side and middle of the monitor?
		bcc.s	.left_hit			; if yes, branch
	
	.right_hit:
		add.w	d1,d1				; double collision width
		sub.w	d1,d0				; update d0 for to right side of monitor

	; loc_A4DC:
	.left_hit:
		cmpi.w	#$10,d3				; is Sonic between top & middle of monitor?
		blo.s	.top_hit			; if yes, branch

; loc_A4E2:
.side_hit:
		moveq	#1,d1				; set side collision flag
		rts					; return with result in CCR
; ===========================================================================

; loc_A4E6:
.no_collision:
		moveq	#0,d1				; set no collision flag
		rts					; return with result in CCR	
; ===========================================================================

; loc_A4EA:
.top_hit:
		moveq	#0,d1				; clear d1
		move.b	obActWid(a0),d1			; get display width of monitor
		addq.w	#4,d1				; add 4px to top collision width
		move.w	d1,d2				; copy it for rightside check
		add.w	d2,d2				; double the copy for rightside check
		add.w	obX(a1),d1			; add Sonic's X position to main collision width
		sub.w	obX(a0),d1			; subtract Monitor's X position 
		bmi.s	.side_hit			; if Sonic is to the left of the monitor, branch
		cmp.w	d2,d1				; is Sonic to the right of the monitor?
		bhs.s	.side_hit			; if yes, branch

		moveq	#-1,d1				; set top/bottom collision flag
		rts					; return with result in CCR
; End of function Mon_SolidSides