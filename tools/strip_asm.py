import errno
import struct
import sys
import re
import os

def export_ram_labels(text, file):

    r = re.compile(r'^ [0-9A-F]{4}:([0-9A-F]{8})\s+([\w\.]+)', re.MULTILINE)
    mm = r.findall(text)

    # Search map file for all labels after the end of the ROM section, and put
    # them in a separate include file as named constants.
    for m in mm:
        if int(m[0],16) > 0x001FFFFF:
            sym = m[1] + ":"
            loc = "$" + m[0]
            file.write("%-20s equ %s\n" % (sym, loc))
    return

def strip_struct_defs_and_ram_segments(intext, outfile):
    write_out = False
    i = 0
    r = re.compile(r'\s+org\s+\$([0-9A-F]{1,8})')
    for line in intext:
        i+=1
        # Only copy lines after struct definitions, as the assembler does not recognise
        # the struc directive, and structures are not required to assemble the code.
        if(line.find("; enum") == 0):  
            write_out = True
        else:
            # Stop copying after the end of the ROM. Look out for org directives, and check
            # the address falls within the ROM address range. Otherwise, the assembler will
            # pad out the ROM to fill the entire address space.
            m = r.findall(line)
            if len(m) == 1:
                org_address = int(m[0],16)
                if(org_address == 0):
                    write_out = True
                elif(org_address > 0x1FFFFF):
                    write_out = False
        if write_out:
            outfile.write(line)

def main(argv):
    if len(argv) != 4:
        print("Strips structure definitions and RAM sections from an IDA 6.8 generated")
        print("ASM file, ready for assembly using the asm68k.exe assembler.\n")
        print("Usage: %s romfile.asm romfile.map outputromfile.asm" % argv[0])
    else:
        with open(argv[2], 'rb') as mapfile:
            with open(argv[1], 'rb') as asmfile:
                directory = os.path.dirname(argv[1])
                pre, ext = os.path.splitext(argv[1])
                
                maptext = mapfile.read()
                asmtext = asmfile.readlines()

                with open(os.path.join(directory, 'ram.inc'), 'wb') as rw:
                    with open(os.path.join(directory, pre + "_new" + ext), 'wb') as aw:
                        export_ram_labels(maptext, rw)
                        aw.write("           include \"%s\"\n\n" % "ram.inc")
                        strip_struct_defs_and_ram_segments(asmtext, aw)

if __name__ == '__main__':
    main(sys.argv)