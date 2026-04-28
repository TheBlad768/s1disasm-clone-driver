; ---------------------------------------------------------------------------
; Sprite mappings - special stage "R" block
; ---------------------------------------------------------------------------
Map_SS_R_internal:	mappingsTable
	mappingsTableEntry.w	.r0
	mappingsTableEntry.w	.r1
	mappingsTableEntry.w	.ghost_switch ; blank

.r0:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 0, 0, 0, 0, 0
.r0_End

.r1:	spriteHeader
	spritePiece	-$C, -$C, 3, 3, 9, 0, 0, 0, 0
.r1_End

.ghost_switch:	spriteHeader
.ghost_switch_End

	even
