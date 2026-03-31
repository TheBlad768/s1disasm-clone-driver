; ---------------------------------------------------------------------------
; Special stage background loading subroutine
; ---------------------------------------------------------------------------

SS_BGLoad:
		lea	(v_ssbuffer1).l,a1
		lea	(Eni_SSBg1).l,a0 ; load mappings for the birds and fish
		move.w	#ArtTile_SS_Background_Fish|Tile_Pal3,d0
		bsr.w	EniDec
		locVRAM	ArtTile_SS_Plane_1*tile_size+plane_size_64x32,d3
		lea	(v_ssbuffer1+$80).l,a2
		moveq	#7-1,d7 ; $5000, $6000, $7000, $8000, $9000, $A000, $B000.

loc_48BE:
		move.l	d3,d0
		moveq	#3,d6
		moveq	#0,d4
		cmpi.w	#4-1,d7 ; $8000
		bhs.s	loc_48CC
		moveq	#1,d4

loc_48CC:
		moveq	#8-1,d5

loc_48CE:
		movea.l	a2,a1
		eori.b	#1,d4
		bne.s	loc_48E2
		cmpi.w	#6,d7
		bne.s	loc_48F2

		lea	(v_ssbuffer1).l,a1

loc_48E2:
		movem.l	d0-d4,-(sp)
		moveq	#8-1,d1
		moveq	#8-1,d2
		bsr.w	TilemapToVRAM
		movem.l	(sp)+,d0-d4

loc_48F2:
		addi.l	#$100000,d0
		dbf	d5,loc_48CE

		addi.l	#$3800000,d0
		eori.b	#1,d4
		dbf	d6,loc_48CC

		addi.l	#$10000000,d3
		bpl.s	loc_491C
		swap	d3
		addi.l	#$C000,d3
		swap	d3

loc_491C:
		adda.w	#$80,a2
		dbf	d7,loc_48BE

		lea	(v_ssbuffer1).l,a1
		lea	(Eni_SSBg2).l,a0 ; load mappings for the clouds
		move.w	#ArtTile_SS_Background_Clouds|Tile_Pal3,d0
		bsr.w	EniDec
		copyTilemap	v_ssbuffer1,ArtTile_SS_Plane_5*tile_size,64,32
		copyTilemap	v_ssbuffer1,ArtTile_SS_Plane_5*tile_size+plane_size_64x32,64,64
		rts
; End of function SS_BGLoad

; ===========================================================================
; ---------------------------------------------------------------------------
; Palette cycling routine - special stage
; ---------------------------------------------------------------------------

PalCycle_SS:
		tst.w	(f_pause).w
		bne.s	locret_49E6
		subq.w	#1,(v_palss_time).w
		bpl.s	locret_49E6

		lea	(vdp_control_port).l,a6
		move.w	(v_palss_num).w,d0
		addq.w	#1,(v_palss_num).w
		andi.w	#$1F,d0
		lsl.w	#2,d0
		lea	(byte_4A3C).l,a0
		adda.w	d0,a0

		; Time
		move.b	(a0)+,d0
		bpl.s	loc_4992
		move.w	#$1FF,d0

loc_4992:
		move.w	d0,(v_palss_time).w

		; Anim
		moveq	#0,d0
		move.b	(a0)+,d0
		move.w	d0,(v_ssbganim).w
		lea	(byte_4ABC).l,a1
		lea	(a1,d0.w),a1
		; FG VRAM
		move.w	#$8200,d0
		move.b	(a1)+,d0
		move.w	d0,(a6)
		; Y coordinate
		move.b	(a1),(v_scrposy_vdp).w

		; BG VRAM
		move.w	#$8400,d0
		move.b	(a0)+,d0
		move.w	d0,(a6)
		move.l	#$40000010,(vdp_control_port).l
		move.l	(v_scrposy_vdp).w,(vdp_data_port).l

		; Palette cycle index
		moveq	#0,d0
		move.b	(a0)+,d0
		bmi.s	loc_49E8
		lea	(Pal_SSCyc1).l,a1
		adda.w	d0,a1
		lea	(v_palette+$4E).w,a2
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+
		move.l	(a1)+,(a2)+

locret_49E6:
		rts
; ===========================================================================

loc_49E8:
		move.w	(v_palss_index).w,d1	; Doesn't seem to ever be modified...
		cmpi.w	#$8A,d0
		blo.s	loc_49F4
		addq.w	#1,d1

loc_49F4:
		mulu.w	#$2A,d1
		lea	(Pal_SSCyc2).l,a1
		adda.w	d1,a1
		andi.w	#$7F,d0

		bclr	#0,d0
		beq.s	loc_4A18
		lea	(v_palette+$6E).w,a2
		move.l	(a1),(a2)+
		move.l	4(a1),(a2)+
		move.l	8(a1),(a2)+

loc_4A18:
		adda.w	#$C,a1
		lea	(v_palette+$5A).w,a2
		cmpi.w	#$A,d0
		blo.s	loc_4A2E
		subi.w	#$A,d0
		lea	(v_palette+$7A).w,a2

loc_4A2E:
		move.w	d0,d1
		add.w	d0,d0
		add.w	d1,d0
		adda.w	d0,a1
		move.l	(a1)+,(a2)+
		move.w	(a1)+,(a2)+
		rts
; End of function PalCycle_SS

; ===========================================================================
SSBGData:	macro time,anim,vram,index,flag1,flag2
		dc.b	(\time), (\anim), ((\vram)*tile_size)>>13
	if strcmp("\flag1","TRUE")
		dc.b	(\index)|$80|(strcmp("\flag2","TRUE")&1)
	else
		dc.b	(\index)*12
	endif
		endm

byte_4A3C:
		; Time, anim, BG VRAM, palette cycle index & flags
		SSBGData  3,  0, ArtTile_SS_Plane_6, 18, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 16, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 14, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 12, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6, 10, TRUE,	TRUE

		SSBGData  3,  0, ArtTile_SS_Plane_6,  0, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  2, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  4, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  6, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_6,  8, TRUE,	FALSE


		SSBGData  7,  8, ArtTile_SS_Plane_6,  0, FALSE,	FALSE
		SSBGData  7, 10, ArtTile_SS_Plane_6,  1, FALSE,	FALSE
		SSBGData -1, 12, ArtTile_SS_Plane_6,  2, FALSE,	FALSE
		SSBGData -1, 12, ArtTile_SS_Plane_6,  2, FALSE,	FALSE
		SSBGData  7, 10, ArtTile_SS_Plane_6,  1, FALSE,	FALSE
		SSBGData  7,  8, ArtTile_SS_Plane_6,  0, FALSE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  8, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  6, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  4, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  2, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5,  0, TRUE,	TRUE

		SSBGData  3,  0, ArtTile_SS_Plane_5, 10, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 12, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 14, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 16, TRUE,	FALSE
		SSBGData  3,  0, ArtTile_SS_Plane_5, 18, TRUE,	FALSE

		SSBGData  7,  2, ArtTile_SS_Plane_5,  3, FALSE,	FALSE
		SSBGData  7,  4, ArtTile_SS_Plane_5,  4, FALSE,	FALSE
		SSBGData -1,  6, ArtTile_SS_Plane_5,  5, FALSE,	FALSE
		SSBGData -1,  6, ArtTile_SS_Plane_5,  5, FALSE,	FALSE
		SSBGData  7,  4, ArtTile_SS_Plane_5,  4, FALSE,	FALSE
		SSBGData  7,  2, ArtTile_SS_Plane_5,  3, FALSE,	FALSE
		even

SSFGData:	macro vram,y
		dc.b ((\vram)*tile_size)>>10, (\y)>>8
		endm

byte_4ABC:
		; FG VRAM, Y coordinate
		SSFGData ArtTile_SS_Plane_1, $100
		SSFGData ArtTile_SS_Plane_2,    0
		SSFGData ArtTile_SS_Plane_2, $100
		SSFGData ArtTile_SS_Plane_3,    0
		SSFGData ArtTile_SS_Plane_3, $100
		SSFGData ArtTile_SS_Plane_4,    0
		SSFGData ArtTile_SS_Plane_4, $100
		even
; ===========================================================================

Pal_SSCyc1:	binclude	"palette/Cycle - Special Stage 1.bin"
		even
Pal_SSCyc2:	binclude	"palette/Cycle - Special Stage 2.bin"
		even

; ===========================================================================
; ---------------------------------------------------------------------------
; Subroutine to make the special stage background animated
; ---------------------------------------------------------------------------

SS_BGAnimate:
		move.w	(v_ssbganim).w,d0
		bne.s	loc_4BF6
		move.w	#0,(v_bgscreenposy).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w

loc_4BF6:
		cmpi.w	#8,d0
		bhs.s	loc_4C4E
		cmpi.w	#6,d0
		bne.s	loc_4C10
		addq.w	#1,(v_bg3screenposx).w
		addq.w	#1,(v_bgscreenposy).w
		move.w	(v_bgscreenposy).w,(v_bgscrposy_vdp).w

loc_4C10:
		moveq	#0,d0
		move.w	(v_bgscreenposx).w,d0
		neg.w	d0
		swap	d0
		lea	(byte_4CCC).l,a1
		lea	(v_ngfx_buffer).w,a3
		moveq	#$A-1,d3

loc_4C26:
		move.w	2(a3),d0
		bsr.w	CalcSine
		moveq	#0,d2
		move.b	(a1)+,d2
		muls.w	d2,d0
		asr.l	#8,d0
		move.w	d0,(a3)+
		move.b	(a1)+,d2
		ext.w	d2
		add.w	d2,(a3)+
		dbf	d3,loc_4C26
		lea	(v_ngfx_buffer).w,a3
		lea	(byte_4CB8).l,a2
		bra.s	loc_4C7E
; ===========================================================================

loc_4C4E:
		cmpi.w	#$C,d0
		bne.s	loc_4C74
		subq.w	#1,(v_bg3screenposx).w
		lea	(v_ssscroll_buffer).w,a3
		move.l	#$18000,d2
		moveq	#7-1,d1

loc_4C64:
		move.l	(a3),d0
		sub.l	d2,d0
		move.l	d0,(a3)+
		subi.l	#$2000,d2
		dbf	d1,loc_4C64

loc_4C74:
		lea	(v_ssscroll_buffer).w,a3
		lea	(byte_4CC4).l,a2

loc_4C7E:
		lea	(v_hscrolltablebuffer).w,a1
		move.w	(v_bg3screenposx).w,d0
		neg.w	d0
		swap	d0
		moveq	#0,d3
		move.b	(a2)+,d3
		move.w	(v_bgscreenposy).w,d2
		neg.w	d2
		andi.w	#$FF,d2
		lsl.w	#2,d2

loc_4C9A:
		move.w	(a3)+,d0
		addq.w	#2,a3
		moveq	#0,d1
		move.b	(a2)+,d1
		subq.w	#1,d1

loc_4CA4:
		move.l	d0,(a1,d2.w)
		addq.w	#4,d2
		andi.w	#$3FC,d2
		dbf	d1,loc_4CA4
		dbf	d3,loc_4C9A
		rts
; End of function SS_BGAnimate

; ===========================================================================
byte_4CB8:	dc.b 9,	$28, $18, $10, $28, $18, $10, $30, $18,	8, $10,	0
		even
byte_4CC4:	dc.b 6,	$30, $30, $30, $28, $18, $18, $18
		even
byte_4CCC:	dc.b 8,	2, 4, $FF, 2, 3, 8, $FF, 4, 2, 2, 3, 8,	$FD, 4,	2, 2, 3, 2, $FF
		even
; ===========================================================================