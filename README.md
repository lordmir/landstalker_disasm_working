# landstalker_disasm

Disassembly of the US Landstalker ROM in IDA Pro 6.8

## Build instructions

1. Open the idb file in IDA pro 6.8
2. In IDA, run the script fix_asm.idc on the disassembly (File->Script File...). This will fix some 68000 instructions that haven't been correctly disassembled by IDA.
3. In IDA, produce an ASM file called landstalker.asm (File->Produce File->Create ASM File...).
4. In IDA, produce a MAP file called landstalker.map (File->Produce File->Create MAP File...). Make sure 'Segmentation information' and 'Dummy names' are selected.
3. Run the build.bat file. This will run a script to prepare the ASM file for assembly by removing structures and RAM segments before running the assembler. You should end up with a .bin file which is identical to the original ROM.
