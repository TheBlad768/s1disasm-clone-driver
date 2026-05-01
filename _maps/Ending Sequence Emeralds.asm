; ---------------------------------------------------------------------------
; Sprite mappings - chaos emeralds on the ending sequence
; ---------------------------------------------------------------------------
Map_ECha_internal:	mappingsTable
	mappingsTableEntry.w	.eCha_1
	mappingsTableEntry.w	.eCha_2
	mappingsTableEntry.w	.eCha_3
	mappingsTableEntry.w	.eCha_4
	mappingsTableEntry.w	.eCha_5
	mappingsTableEntry.w	.eCha_6
	mappingsTableEntry.w	.eCha_7

.eCha_1:	spriteHeader
	spritePiece	-8, -8, 2, 2, 0, 0, 0, 0, 0
.eCha_1_End

.eCha_2:	spriteHeader
	spritePiece	-8, -8, 2, 2, 4, 0, 0, 0, 0
.eCha_2_End

.eCha_3:	spriteHeader
	spritePiece	-8, -8, 2, 2, $10, 0, 0, 2, 0
.eCha_3_End

.eCha_4:	spriteHeader
	spritePiece	-8, -8, 2, 2, $18, 0, 0, 1, 0
.eCha_4_End

.eCha_5:	spriteHeader
	spritePiece	-8, -8, 2, 2, $14, 0, 0, 2, 0
.eCha_5_End

.eCha_6:	spriteHeader
	spritePiece	-8, -8, 2, 2, 8, 0, 0, 0, 0
.eCha_6_End

.eCha_7:	spriteHeader
	spritePiece	-8, -8, 2, 2, $C, 0, 0, 0, 0
.eCha_7_End

	even
