.segment "ZEROPAGE"
; Locations $22-$7F are available for user zero-page variables
addr_lo: .res 1   ; low byte  of current VRAM pixel address
addr_hi: .res 1   ; high byte of current VRAM pixel address
frac:    .res 1   ; DDA y-fraction accumulator (8-bit fixed-point)
cnt_lo:  .res 1   ; loop counter low  byte (161 pixels: x = 0..160)
cnt_hi:  .res 1   ; loop counter high byte


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
   ; Switch to 320x240 256-colour graphics mode.
   ; A = $80, carry clear = set mode.
   lda #$80
   clc
   jsr SCREEN_MODE

   ; CRITICAL: reset VERA_ctrl to 0 (DCSEL=0, ADDRSEL=0).
   ; Some KERNAL routines leave ADDRSEL=1, which means writes to
   ; VERA_addr_low/high/bank target ADDR1, while VERA_data0 always
   ; reads ADDR0 — so pixels land at the wrong address entirely.
   lda #0
   sta VERA_ctrl

   ; ------------------------------------------------------------------
   ; Clear the screen to black (colour index 0).
   ;
   ; Use VERA auto-increment (stride 1) to stream 76 800 zero bytes
   ; (320 × 240) into VRAM starting at $00000.
   ; 76 800 = 300 pages of 256 bytes; outer counter is 16-bit ($012C).
   ; ------------------------------------------------------------------
   lda #$10             ; bank 0, stride 1 (auto-increment each write)
   sta VERA_addr_bank
   lda #0
   sta VERA_addr_high
   sta VERA_addr_low

   lda #$01             ; outer count high byte  (300 = $012C)
   sta cnt_hi
   lda #$2C             ; outer count low  byte
   sta cnt_lo

clear_outer:
   ldy #0               ; inner counter: 256 bytes per page
clear_inner:
   lda #0
   sta VERA_data0       ; write black pixel; VERA auto-advances address
   dey
   bne clear_inner

   ; decrement 16-bit outer counter
   lda cnt_lo
   bne :+
   dec cnt_hi
:  dec cnt_lo
   lda cnt_lo
   ora cnt_hi
   bne clear_outer

   ; Restore VERA_ctrl (clear ADDRSEL / DCSEL) after auto-increment use.
   lda #0
   sta VERA_ctrl

   ; ------------------------------------------------------------------
   ; Draw a red diagonal line from (0,0) to the screen centre (160,120)
   ; directly into VERA bitmap RAM, bypassing the KERNAL GRAPH_ API.
   ;
   ; SCREEN_MODE $80 places the 320x240 8-bpp bitmap at VRAM $00000.
   ; Pixel (x, y) is at VRAM address  y*320 + x.
   ;
   ; DDA line algorithm: slope = dy/dx = 120/160 = 3/4.
   ; Per x-step we add 192 (= 3/4 * 256) to an 8-bit fraction.
   ; Carry out signals a whole-pixel y advance, so we add 320 ($0140)
   ; to the running VRAM address for that step, then always +1 for x.
   ; Total iterations = 161 (pixels at x = 0, 1, … 160).
   ; ------------------------------------------------------------------

   lda #0
   sta addr_lo          ; start at VRAM $0000 = pixel (0, 0)
   sta addr_hi
   sta frac             ; fraction accumulator = 0

   lda #<161
   sta cnt_lo
   lda #>161
   sta cnt_hi

line_loop:
   ; ---- plot current pixel ----
   ; Point VERA ADDR0 at the current pixel; bank 0, stride 0 (no auto-advance).
   lda #0
   sta VERA_addr_bank
   lda addr_hi
   sta VERA_addr_high
   lda addr_lo
   sta VERA_addr_low
   lda #2               ; colour index 2 = red in the default 256-colour palette
   sta VERA_data0

   ; ---- DDA step ----
   clc
   lda frac
   adc #192             ; advance fraction by 192 (= 3/4 * 256)
   sta frac
   bcc no_y_step        ; no carry → y stays on this scanline

   ; Carry set → y increments: add 320 ($0140) to the VRAM address
   clc
   lda addr_lo
   adc #$40
   sta addr_lo
   lda addr_hi
   adc #$01
   sta addr_hi

no_y_step:
   ; x always increments by 1
   inc addr_lo
   bne cnt_check
   inc addr_hi

cnt_check:
   ; ---- decrement 16-bit loop counter ----
   lda cnt_lo
   bne :+
   dec cnt_hi
:  dec cnt_lo

   lda cnt_lo
   ora cnt_hi
   bne line_loop

   ; Halt — loop forever
done:
   jmp done
;******************************************************************
