# Commander X16 Graphics

This repository is a collaborative project between a human developer and Claude (Anthropic's AI) to explore graphics programming on the [Commander X16](https://www.commanderx16.com/) retro computer.

## About the Project

We are writing 6502 assembly language programs targeting the Commander X16, starting with simple graphics commands and gradually building up to more sophisticated techniques. The aim is to learn the X16's VERA (Versatile Embedded Retro Adapter) graphics chip and the X16 KERNAL API through hands-on experimentation.

## Programs

### GRAPHIC.asm
The first program. Sets the screen to 320×240 256-colour bitmap mode and draws a red diagonal line from the top-left corner (0, 0) to the centre of the screen (160, 120) using a DDA (Digital Differential Analyzer) line algorithm with direct VERA bitmap writes.

## Building

Requires the [cc65](https://cc65.github.io/) assembler toolchain.

```bash
cl65 -t cx16 -o GRAPHIC.PRG -l GRAPHIC.LIST GRAPHIC.asm
```

## Running

Requires the [x16emu](https://github.com/X16Community/x16-emulator) Commander X16 emulator.

```bash
x16emu -prg GRAPHIC.PRG -run
```

## Tools & Environment

- **Assembler:** ca65 / cl65 (part of the cc65 toolchain)
- **Target:** Commander X16 (ROM R38)
- **Emulator:** x16emu
- **Language:** 6502 Assembly
