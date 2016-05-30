


; =============== S U B	R O U T	I N E =======================================


DecompressLZ77Gfx:			; CODE XREF: sub_2CF6+3Ap sub_4A7A+6p	...
		moveq	#$0000000F,d4

loc_4AB4:				; CODE XREF: DecompressLZ77Gfx+50j
					; DecompressLZ77Gfx+5Ej
		moveq	#$00000007,d3
		move.b	(a0)+,d0
		bmi.s	loc_4B04

loc_4ABA:				; CODE XREF: DecompressLZ77Gfx+48j
					; DecompressLZ77Gfx+5Aj
		clr.w	d1
		move.b	(a0)+,d1
		move.w	d1,d2
		and.b	d4,d1
		add.b	d1,d1
		lsl.w	#$04,d2
		move.b	(a0)+,d2
		tst.w	d2
		beq.s	locret_4B12
		movea.l	a1,a3
		suba.w	d2,a3
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		jmp	loc_4AD8(pc,d1.w)
; ---------------------------------------------------------------------------

loc_4AD8:
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		move.b	(a3)+,(a1)+
		add.b	d0,d0
		dbmi	d3,loc_4ABA
		dbpl	d3,loc_4B04
		bra.s	loc_4AB4
; ---------------------------------------------------------------------------

loc_4B04:				; CODE XREF: DecompressLZ77Gfx+6j
					; DecompressLZ77Gfx+4Cj ...
		move.b	(a0)+,(a1)+
		add.b	d0,d0
		dbpl	d3,loc_4B04
		dbmi	d3,loc_4ABA
		bra.s	loc_4AB4
; ---------------------------------------------------------------------------

locret_4B12:				; CODE XREF: DecompressLZ77Gfx+18j
		rts
; End of function DecompressLZ77Gfx

