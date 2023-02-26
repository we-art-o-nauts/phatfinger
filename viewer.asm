//-------------------------------------------------------------------------------------------------------
// Mountainbytes 2023
// Pic displayer, quick'n'dirty
//
// Code:		Dr. Science
//-------------------------------------------------------------------------------------------------------
.var debug 				= false
//-------------------------------------------------------------------------------------------------------
.var maincode				= $c000
.var ScreenRam_1                        = $4000
.var BitmapRam_1                        = $6000
.var ScreenRam_2                        = $8000
.var BitmapRam_2                        = $a000
//-------------------------------------------------------------------------------------------------------
.var    ZP_areg                         = $80
.var    ZP_xreg                         = $81
.var    ZP_yreg                         = $82

.var    ZP_Counter                      = $90
//-------------------------------------------------------------------------------------------------------
.pc = BitmapRam_1 "Bitmap Ram 1"
.import binary "pics/start.map"
.pc = ScreenRam_1 "Screen Ram 1"
.import binary "pics/start.scr"
//-------------------------------------------------------------------------------------------------------
.pc = BitmapRam_2 "Bitmap Ram 2"
.fill $1fff,$00
.pc = ScreenRam_2 "Screen Ram 2"
.fill $0400,00
//-------------------------------------------------------------------------------------------------------
.pc =$0801 "Basic Upstart Program"
:BasicUpstart(maincode)
//--------------------MUSIC  ----------------------------
.var music = LoadSid("Finger.sid")
.pc=music.location "Music"
.fill music.size, music.getData(i)
//-------------------------------------------------------------------------------------------------------
.pc = maincode "main"

         clc
         sei
         lda #$01
         sta $d019
         sta $d01a
         lda #$00
         sta $d011
         sta $d015
         sta $dd00
         lda #$7f
         sta $dc0d
         sta $dd0d
         lda $dc0d
         lda $dd0d
         lda #$35
         sta $01

         lda #$01
         sta $d012
         lda #<irq0
         ldy #>irq0
         sta $fffe
         sty $ffff
         lda #<nmi
        ldy #>nmi
        sta $fffa
        sty $fffb

        lda #$00
        sta ZP_Counter
        tax
        tay
        jsr music.init

#if RELEASE
#else
        lda #$00
        sta $dd00
#endif
        //lda #$3e // $8000-$bfff
        lda #$3d // $4000-$7fff
        sta $dd02

        cli 

!loop:
        ldx ZP_Counter
        cpx #14
        beq !done+
        jsr $0200 // Spindle Loader --> comment this out if run standalone
        jsr Pause
        jsr SwitchPic
        inc ZP_Counter
        jmp !loop-

!done:
        jmp *
        
//-------------------------------------------------------------------------------------------------------
Pause:
        ldx #$60
!:      lda #$00
        sta irqcount
        cmp irqcount
        beq *-3
        dex
        bne !-
        rts
//-------------------------------------------------------------------------------------------------------
SwitchPic:
        lda BankCheck+1
        eor #$01
        sta BankCheck+1
BankCheck:
        lda #$00
        beq !+
        lda #$3e 
        sta Set_Bank+1
        rts
!:      lda #$3d 
        sta Set_Bank+1
        rts
//-------------------------------------------------------------------------------------------------------
irq0:
                        sta ZP_areg
                        stx ZP_xreg
                        sty ZP_yreg

.if (debug)     dec $d020
                        lda #$3b
                        sta $d011
                        lda #$c8 
                        sta $d016
                        lda #%00001000
                        sta $d018

Set_Bank:               lda #$3d // $4000-$7fff
                        sta $dd02


			lda #$2f
                        ldx #<irq1
                        ldy #>irq1
                        jmp irqend

irq1:
                        sta ZP_areg
                        stx ZP_xreg
                        sty ZP_yreg
// Timing
                        ldx #$07 
!:                      dex 
                        bne !-
                        nop
                        nop
                        nop

                        lda #$00
                        sta $d020
                        sta $d021


                        lda #$fd
                        ldx #<irq2
                        ldy #>irq2
                        jmp irqend

irq2:
                        sta ZP_areg
                        stx ZP_xreg
                        sty ZP_yreg

// Timing
                        ldx #$07 
!:                      dex 
                        bne !-
                        nop
                        nop
                        nop

                        lda #$06
                        sta $d020
                        sta $d021

                        inc irqcount

.if (debug)     dec $d020
                        jsr music.play
.if (debug)     inc $d020

                        lda #$01
                        ldx #<irq0
                        ldy #>irq0
                        jmp irqend


//-------------------IRQ END -----
irqend:  
                asl $d019
                sta $d012
                stx $fffe
                sty $ffff

                lda ZP_areg
                ldx ZP_xreg
                ldy ZP_yreg

nmi:            rti 

irqcount:       .byte $00
