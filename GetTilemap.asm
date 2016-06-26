; ---------------------------------------------------------------------------

RoomData	struc ;	(sizeof=0x8)											; XREF:	ROM:RoomData_0r
field_0:	dc.l ?													; offset (00000000)
field_4:	dc.b ?
field_5:	dc.b ?
field_6:	dc.b ?
field_7:	dc.b ?
RoomData	ends



; =============== S U B	R O U T	I N E =======================================


GetTilemap:														; CODE XREF: ROM:00002BB4p
		lea	(HeightMap).l,a1
		move.w	#$0AB1,d7

loc_2BD2:														; CODE XREF: GetTilemap+10j
		move.l	#$40004000,(a1)+
		dbf	d7,loc_2BD2
		movea.l	a2,a0
		lea	(ScrollA).l,a1
		jsr	sub_CDAE
		movem.w	d0-d4,-(sp)

loc_2BEE:
		lea	(ScrollA).l,a0
		move.b	(a0)+,d0
		move.b	(a0)+,d1
		move.b	(a0)+,d2
		move.b	(a0)+,d3
		ext.w	d0
		ext.w	d1
		ext.w	d2
		ext.w	d3
		movem.w	d1,-(sp)
		movem.w	d0,-(sp)
		movem.w	d2-d3,-(sp)
		addq.w	#$01,d2
		addq.w	#$01,d3
		mulu.w	d2,d3
		add.w	d3,d3
		add.w	d3,d3
		adda.w	d3,a0
		movem.w	(sp)+,d2-d3
		add.w	d2,d0
		add.w	d3,d1
		movem.w	(sp)+,d7
		movem.w	(sp)+,d5
		lea	(HeightMap).l,a1
		movem.w	d0-d3/d5/d7,-(sp)
		bsr.s	ExtractMap?
		movem.w	(sp)+,d0-d3/d5/d7
		lea	(ScrollB).l,a1
		bsr.s	ExtractMap?
		movem.w	(sp)+,d0-d4
		rts
; End of function GetTilemap


; =============== S U B	R O U T	I N E =======================================


ExtractMap?:														; CODE XREF: GetTilemap+6Ep
															; GetTilemap+7Ap
		move.w	#$0048,d4

loc_2C4E:
		sub.w	d1,d4
		bmi.s	loc_2C60

loc_2C52:														; CODE XREF: ExtractMap?+12j
		move.w	#$0049,d6

loc_2C56:														; CODE XREF: ExtractMap?+Ej
		clr.w	-(a1)
		dbf	d6,loc_2C56
		dbf	d4,loc_2C52

loc_2C60:														; CODE XREF: ExtractMap?+6j
		move.w	#$0048,d6
		sub.w	d0,d6
		subq.w	#$01,d7

loc_2C68:														; CODE XREF: ExtractMap?+40j
		movem.w	d2/d6-d7,-(sp)
		tst.w	d6
		bmi.s	loc_2C76

loc_2C70:														; CODE XREF: ExtractMap?+28j
		clr.w	-(a1)
		dbf	d6,loc_2C70

loc_2C76:														; CODE XREF: ExtractMap?+24j
															; ExtractMap?+2Ej
		move.w	-(a0),-(a1)
		dbf	d2,loc_2C76
		tst.w	d7
		bmi.s	loc_2C86

loc_2C80:														; CODE XREF: ExtractMap?+38j
		clr.w	-(a1)
		dbf	d7,loc_2C80

loc_2C86:														; CODE XREF: ExtractMap?+34j
		movem.w	(sp)+,d2/d6-d7
		dbf	d3,loc_2C68
		subq.w	#$01,d5
		bmi.s	locret_2CA0

loc_2C92:														; CODE XREF: ExtractMap?+52j
		move.w	#$0049,d7

loc_2C96:														; CODE XREF: ExtractMap?+4Ej
		clr.w	-(a1)
		dbf	d7,loc_2C96
		dbf	d5,loc_2C92

locret_2CA0:														; CODE XREF: ExtractMap?+46j
		rts
; End of function ExtractMap?

