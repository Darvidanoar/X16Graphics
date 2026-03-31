.segment "ZEROPAGE"
; Locations $22-$7F are available for user zero-page variables


;******************************************************************
.segment "ONCE"
.segment "CODE"
.org $080D

   jmp start  ; jump to the main code routine


; Add any includes here
.include "INC\x16.inc"  ; Standard X16 variables and macros

;******************************************************************
; main code routine starts here
start:
   ; Initialize KERNAL graphics API.
   ; Sets VERA to 320x240 256-colour bitmap mode.
   ; Pass r0 = 0 to use the default palette.
   lda #0
   sta r0L
   sta r0H
   jsr GRAPH_init

   ; Set drawing colour: foreground = 2 (red), background = 0 (black)
   lda #2           ; foreground: red (index 2 in default palette)
   ldx #0           ; background: black
   ldy #0           ; border: black
   jsr GRAPH_set_colors

   ; Draw a diagonal line from (0, 0) to the screen centre (160, 120).
   ; r0 = x1
   lda #<0
   sta r0L
   lda #>0
   sta r0H
   ; r1 = y1
   lda #<0
   sta r1L
   lda #>0
   sta r1H
   ; r2 = x2 = 160
   lda #<160
   sta r2L
   lda #>160
   sta r2H
   ; r3 = y2 = 120
   lda #<120
   sta r3L
   lda #>120
   sta r3H
   jsr GRAPH_draw_line

   ; Halt — loop forever
done:
   jmp done
;******************************************************************
