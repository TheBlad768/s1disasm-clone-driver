; ---------------------------------------------------------------------------
; Palette index
; ---------------------------------------------------------------------------

paletteIndexEntry:	macro paletteLabel,paletteRAMaddress,{GLOBALSYMBOLS}

ptr_paletteLabel:
	dc.l paletteLabel
	dc.w paletteRAMaddress,(paletteLabel_end-paletteLabel)/4-1
	endm

Pal_Index:
	; FORMAT:			Palette label,		RAM location
	; Palette size is calculated dynamically using an end marker made by bincludeEndMarker
	paletteIndexEntry	Pal_SegaBG, 		v_palette_line_1
	paletteIndexEntry	Pal_Title,			v_palette_line_1
	paletteIndexEntry	Pal_LevelSel,		v_palette_line_1
	paletteIndexEntry	Pal_Sonic,			v_palette_line_1
	paletteIndexEntry	Pal_GHZ, 			v_palette_line_2
	paletteIndexEntry	Pal_LZ, 			v_palette_line_2
	paletteIndexEntry	Pal_MZ, 			v_palette_line_2
	paletteIndexEntry	Pal_SLZ,			v_palette_line_2
	paletteIndexEntry	Pal_SYZ,			v_palette_line_2
	paletteIndexEntry	Pal_SBZ1, 			v_palette_line_2
	paletteIndexEntry	Pal_Special, 		v_palette_line_1
	paletteIndexEntry	Pal_LZWater, 		v_palette_line_1
	paletteIndexEntry	Pal_SBZ3, 			v_palette_line_2
	paletteIndexEntry	Pal_SBZ3Water, 		v_palette_line_1
	paletteIndexEntry	Pal_SBZ2, 			v_palette_line_2
	paletteIndexEntry	Pal_LZSonWater,		v_palette_line_1
	paletteIndexEntry	Pal_SBZ3SonWat,		v_palette_line_1
	paletteIndexEntry	Pal_SSResult, 		v_palette_line_1
	paletteIndexEntry	Pal_Continue, 		v_palette_line_1
	paletteIndexEntry	Pal_Ending, 		v_palette_line_1
	even

; ---------------------------------------------------------------------------
; Palette index IDs
; ---------------------------------------------------------------------------

offset :=	Pal_Index
ptrsize :=	8
idstart :=	0

palid_SegaBG:		equ	id(ptr_Pal_SegaBG)
palid_Title:		equ id(ptr_Pal_Title)
palid_LevelSel:		equ id(ptr_Pal_LevelSel)
palid_Sonic:		equ id(ptr_Pal_Sonic)
palid_GHZ:			equ id(ptr_Pal_GHZ)
palid_LZ:			equ id(ptr_Pal_LZ)
palid_MZ:			equ id(ptr_Pal_MZ)
palid_SLZ:			equ id(ptr_Pal_SLZ)
palid_SYZ:			equ id(ptr_Pal_SYZ)
palid_SBZ1:			equ id(ptr_Pal_SBZ1)
palid_Special:		equ id(ptr_Pal_Special)
palid_LZWater:		equ id(ptr_Pal_LZWater)
palid_SBZ3:			equ id(ptr_Pal_SBZ3)
palid_SBZ3Water:	equ id(ptr_Pal_SBZ3Water)
palid_SBZ2:			equ id(ptr_Pal_SBZ2)
palid_LZSonWater:	equ id(ptr_Pal_LZSonWater)
palid_SBZ3SonWat:	equ id(ptr_Pal_SBZ3SonWat)
palid_SSResult:		equ id(ptr_Pal_SSResult)
palid_Continue:		equ id(ptr_Pal_Continue)
palid_Ending:		equ id(ptr_Pal_Ending)
