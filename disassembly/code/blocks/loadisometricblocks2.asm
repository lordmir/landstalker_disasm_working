
; =============== S U B	R O U T	I N E =======================================


ConvertXYToBlockPtr:				  ; CODE XREF: LoadTopTiles+20p
						  ; LoadLeftTiles+20p
		ext.w	d0
		ext.w	d1
		add.w	d1,d1
		move.w	Mult148tbl(pc,d1.w),d1
		add.w	d0,d1
		add.w	d0,d1
		lea	(g_BackgroundBlocks).l,a6
		adda.w	d1,a6
		rts
; End of function ConvertXYToBlockPtr


; =============== S U B	R O U T	I N E =======================================


MultiplyD0By148:				  ; CODE XREF: CheckForDoorNE+DCp
		add.w	d0,d0
		move.w	Mult148tbl(pc,d0.w),d0
		ext.l	d0
		rts
; End of function MultiplyD0By148


; =============== S U B	R O U T	I N E =======================================


MultiplyD1By148:				  ; CODE XREF: sub_4DECp
						  ; DATA XREF: sub_3146+26t ...
		add.w	d1,d1
		move.w	Mult148tbl(pc,d1.w),d1
		ext.l	d1
		rts
; End of function MultiplyD1By148


; =============== S U B	R O U T	I N E =======================================


MultiplyD2By148:				  ; DATA XREF: sub_30E4+2Et
						  ; sub_31A6+32t ...
		add.w	d2,d2
		move.w	Mult148tbl(pc,d2.w),d2
		ext.l	d2
		rts
; End of function MultiplyD2By148


; =============== S U B	R O U T	I N E =======================================


MultiplyD3By148:				  ; DATA XREF: j_MultiplyD3By148t
		add.w	d3,d3
		move.w	Mult148tbl(pc,d3.w),d3
		ext.l	d3
		rts
; End of function MultiplyD3By148

; ---------------------------------------------------------------------------
Mult148negTbl:	dc.w -01184,-01036,-00888,-00740,-00592,-00444,-00296,-00148
Mult148tbl:	dc.w  00000, 00148, 00296, 00444, 00592, 00740,	00888, 01036
		dc.w  01184, 01332, 01480, 01628, 01776, 01924,	02072, 02220
		dc.w  02368, 02516, 02664, 02812, 02960, 03108,	03256, 03404
		dc.w  03552, 03700, 03848, 03996, 04144, 04292,	04440, 04588
		dc.w  04736, 04884, 05032, 05180, 05328, 05476,	05624, 05772
		dc.w  05920, 06068, 06216, 06364, 06512, 06660,	06808, 06956
		dc.w  07104, 07252, 07400, 07548, 07696, 07844,	07992, 08140
		dc.w  08288, 08436, 08584, 08732, 08880, 09028,	09176, 09324
		dc.w  09472, 09620, 09768, 09916, 10064, 10212,	10360, 10508
		dc.w  10656, 10804, 10952, 11100, 11248, 11396

; =============== S U B	R O U T	I N E =======================================


sub_C46A:					  ; CODE XREF: ROM:00008DFEp
						  ; DATA XREF: sub_16DC+82t
		move.b	(byte_FF1159).l,d0
		beq.s	locret_C4B2
		move.w	(word_FF12EE).l,d1
		bne.w	loc_C4B4
		andi.w	#$00FF,d0
		lsl.b	#$02,d0
		lea	IntroStringPointers(pc),a2
		movea.l	-$00000004(a2,d0.w),a2
		move.w	(a2)+,d0
		move.w	(a2)+,d1
		move.w	(a2)+,d2
		move.w	(a2)+,d3
		move.w	(a2)+,(word_FF12EE).l
		movem.l	d2-d3,-(sp)
		movem.l	d0-d1,-(sp)
		bsr.s	CopyIntroString
		movem.l	(sp)+,d0-d1
		bsr.w	sub_C56E
		movem.l	(sp)+,d0-d1
		bsr.w	loc_C57A

locret_C4B2:					  ; CODE XREF: sub_C46A+6j
		rts
; ---------------------------------------------------------------------------

loc_C4B4:					  ; CODE XREF: sub_C46A+Ej
		subq.w	#$01,d1
		move.w	d1,(word_FF12EE).l
		bne.s	locret_C4E0
		lea	(g_VDPSpr08_Y).l,a0
		moveq	#$00000007,d7

loc_C4C6:					  ; CODE XREF: sub_C46A+6Cj
		clr.w	(a0)
		clr.b	$00000002(a0)
		clr.w	$00000004(a0)
		clr.w	$00000006(a0)
		addq.w	#$08,a0
		dbf	d7,loc_C4C6
		clr.b	(byte_FF1159).l

locret_C4E0:					  ; CODE XREF: sub_C46A+52j
		rts
; End of function sub_C46A


; =============== S U B	R O U T	I N E =======================================


CopyIntroString:				  ; CODE XREF: sub_C46A+36p
		bsr.s	ClearIntroStringBuffer
		lea	(g_Buffer).l,a1

loc_C4EA:					  ; CODE XREF: CopyIntroString+10j
		bsr.s	GetNextIntroChar
		tst.b	d0
		bmi.s	loc_C4F4
		bsr.s	LoadIntroChar
		bra.s	loc_C4EA
; ---------------------------------------------------------------------------

loc_C4F4:					  ; CODE XREF: CopyIntroString+Cj
		lea	(g_Buffer).l,a0
		lea	(loc_F180).l,a1
		move.w	#$0400,d0
		jmp	(QueueDMAOp).l		  ; d0 - DMA Length
; End of function CopyIntroString		  ; a0 - DMA Source
						  ; a1 - DMA Copy

; =============== S U B	R O U T	I N E =======================================


ClearIntroStringBuffer:				  ; CODE XREF: CopyIntroStringp
		lea	(g_Buffer).l,a1
		move.w	#$01FF,d7

loc_C514:					  ; CODE XREF: ClearIntroStringBuffer+Cj
		clr.l	(a1)+
		dbf	d7,loc_C514
		rts
; End of function ClearIntroStringBuffer


; =============== S U B	R O U T	I N E =======================================


GetNextIntroChar:				  ; CODE XREF: CopyIntroString:loc_C4EAp
		move.b	(a2)+,d0
		rts
; End of function GetNextIntroChar


; =============== S U B	R O U T	I N E =======================================


LoadIntroChar:					  ; CODE XREF: CopyIntroString+Ep
		andi.w	#$00FF,d0
		lsl.w	#$06,d0
		movea.l	(IntroFontPtr).l,a0
		move.l	(a0,d0.w),(a1)+
		move.l	$00000004(a0,d0.w),(a1)+
		move.l	$00000008(a0,d0.w),(a1)+
		move.l	$0000000C(a0,d0.w),(a1)+
		move.l	$00000010(a0,d0.w),(a1)+
		move.l	$00000014(a0,d0.w),(a1)+
		move.l	$00000018(a0,d0.w),(a1)+
		move.l	$0000001C(a0,d0.w),(a1)+
		move.l	$00000020(a0,d0.w),(a1)+
		move.l	$00000024(a0,d0.w),(a1)+
		move.l	$00000028(a0,d0.w),(a1)+
		move.l	$0000002C(a0,d0.w),(a1)+
		move.l	$00000030(a0,d0.w),(a1)+
		move.l	$00000034(a0,d0.w),(a1)+
		move.l	$00000038(a0,d0.w),(a1)+
		move.l	$0000003C(a0,d0.w),(a1)+
		rts
; End of function LoadIntroChar


; =============== S U B	R O U T	I N E =======================================


sub_C56E:					  ; CODE XREF: sub_C46A+3Cp
		move.w	#$E78C,d2
		lea	(g_VDPSpr08_Y).l,a0
		bra.s	loc_C584
; ---------------------------------------------------------------------------

loc_C57A:					  ; CODE XREF: sub_C46A+44p
		move.w	#$E7AC,d2
		lea	(g_VDPSpr12_Y).l,a0

loc_C584:					  ; CODE XREF: sub_C56E+Aj
		moveq	#$00000003,d7

loc_C586:					  ; CODE XREF: sub_C56E+2Aj
		move.w	d1,(a0)+
		move.b	#$0D,(a0)
		addq.l	#$02,a0
		move.w	d2,(a0)+
		move.w	d0,(a0)+
		addq.w	#$08,d2
		addi.w	#$0020,d0
		dbf	d7,loc_C586
		rts
; End of function sub_C56E

; ---------------------------------------------------------------------------
