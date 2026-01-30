; ---------------------------------------------------------------------------
; Palette index
; ---------------------------------------------------------------------------

makePalEntry:	macro paletteLabel,paletteRAMaddress,{INTLABEL},{GLOBALSYMBOLS}
__LABEL__: = (*-Pal_Index)/8
	dc.l paletteLabel
	dc.w paletteRAMaddress,(paletteLabel_end-paletteLabel)/4-1
	endm
; ---------------------------------------------------------------------------

Pal_Index:

; Id			Palette label,		RAM location
; NOTE: Palette size is calculated dynamically using an end marker made by bincludeEndMarker
palid_SegaBG:		makePalEntry	Pal_SegaBG, 		v_palette_line_1
palid_Title:		makePalEntry	Pal_Title,		v_palette_line_1
palid_LevelSel:		makePalEntry	Pal_LevelSel,		v_palette_line_1
palid_Sonic:		makePalEntry	Pal_Sonic,		v_palette_line_1

Pal_Levels:

palid_GHZ:		makePalEntry	Pal_GHZ, 		v_palette_line_2
palid_LZ:		makePalEntry	Pal_LZ, 		v_palette_line_2
palid_MZ:		makePalEntry	Pal_MZ, 		v_palette_line_2
palid_SLZ:		makePalEntry	Pal_SLZ,		v_palette_line_2
palid_SYZ:		makePalEntry	Pal_SYZ,		v_palette_line_2
palid_SBZ1:		makePalEntry	Pal_SBZ1, 		v_palette_line_2
	zonewarning Pal_Levels,8

palid_Special:		makePalEntry	Pal_Special, 		v_palette_line_1
palid_LZWater:		makePalEntry	Pal_LZWater, 		v_palette_line_1
palid_SBZ3:		makePalEntry	Pal_SBZ3, 		v_palette_line_2
palid_SBZ3Water:	makePalEntry	Pal_SBZ3Water, 		v_palette_line_1
palid_SBZ2:		makePalEntry	Pal_SBZ2, 		v_palette_line_2
palid_LZSonWater:	makePalEntry	Pal_LZSonWater,		v_palette_line_1
palid_SBZ3SonWat:	makePalEntry	Pal_SBZ3SonWat,		v_palette_line_1
palid_SSResult:		makePalEntry	Pal_SSResult, 		v_palette_line_1
palid_Continue:		makePalEntry	Pal_Continue, 		v_palette_line_1
palid_Ending:		makePalEntry	Pal_Ending, 		v_palette_line_1
	even
