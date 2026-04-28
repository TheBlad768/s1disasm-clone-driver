; ---------------------------------------------------------------------------
; Sprite mappings - unused small explosion (used for prototype Ball Hog)
; ---------------------------------------------------------------------------
Map_UnkExplode_internal:	mappingsTable
	mappingsTableEntry.w	.unexpl0
	mappingsTableEntry.w	.unexpl1
	mappingsTableEntry.w	.unexpl2
	mappingsTableEntry.w	.unexpl3

.unexpl0:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 0, 0, 0, 0, 0
.unexpl0_End

.unexpl1:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 9, 0, 0, 0, 0
.unexpl1_End

.unexpl2:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, $12, 0, 0, 0, 0
.unexpl2_End

.unexpl3:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, $1B, 0, 0, 0, 0
.unexpl3_End

	even
