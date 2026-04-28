; ---------------------------------------------------------------------------
; Sprite mappings - Unused switch thingy
; ---------------------------------------------------------------------------
Map_Swi_internal:	mappingsTable
	mappingsTableEntry.w	.unused_switch

.unused_switch:	spriteHeader
	spritePiece	-$10, -$18, 2, 4, $54, 0, 0, 0, 0
	spritePiece	-$10, 8, 2, 2, $5C, 0, 0, 0, 0
	spritePiece	0, -$18, 2, 4, $54, 0, 0, 0, 0
	spritePiece	0, 8, 2, 2, $5C, 0, 0, 0, 0
.unused_switch_End

	even
