; ---------------------------------------------------------------------------

loc_9EB9C:					  ; DATA XREF: sub_9B00Co
		cmpi.w	#$0188,(g_RmNum1).l	  ; Church in cave
		beq.s	locret_9EBC4
		move.b	#$FF,GoldOrChestContents(a4)
		clr.w	d0
		move.b	ChestIndex(a4),d0
		move.b	d0,d1
		andi.b	#$07,d1
		lsr.b	#$03,d0
		lea	(g_ChestOpenFlags).l,a0
		bset	d1,(a0,d0.w)

locret_9EBC4:					  ; CODE XREF: ROM:0009EBA4j
		rts
; ---------------------------------------------------------------------------

CheckIfChestOpened:				  ; DATA XREF: j_CheckIfChestOpenedo
		clr.w	d0
		move.b	$00000037(a1),d0
		move.b	d0,d1
		andi.b	#$07,d1
		lsr.b	#$03,d0
		lea	(g_ChestOpenFlags).l,a0
		btst	d1,(a0,d0.w)
		rts
