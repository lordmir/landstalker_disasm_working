; ---------------------------------------------------------------------------

PostUseItemTable:				  ; DATA XREF: sub_8BC8+6o
		bra.w	PostUseGarlic
; ---------------------------------------------------------------------------
		dc.b $9B
		dc.b $FF			  ; $80	| ITM_GARLIC
; ---------------------------------------------------------------------------
		bra.w	PostUseEinsteinWhistle
; ---------------------------------------------------------------------------
		dc.b $A0			  ; $80	| ITM_EINSTEIN_WHISTLE
		dc.b $FF
; ---------------------------------------------------------------------------
		bra.w	PostUseGolasEye
; ---------------------------------------------------------------------------
		dc.b $AB			  ; $80	| ITM_GOLAS_EYE
		dc.b $FF
; ---------------------------------------------------------------------------
		bra.w	PostUseIdolStone
; ---------------------------------------------------------------------------
		dc.b $B1			  ; $80	| ITM_IDOL_STONE
		dc.b $FF
; ---------------------------------------------------------------------------
		bra.w	PostUseKey
; ---------------------------------------------------------------------------
		dc.b $B2			  ; $80	| ITM_KEY
		dc.b $FF
; ---------------------------------------------------------------------------
		bra.w	PostUseShortcake
; ---------------------------------------------------------------------------
		dc.b $B6			  ; $80	| ITM_SHORTCAKE
		dc.b $FF
		dc.l $FFFFFFFF
		dc.w $FFFF