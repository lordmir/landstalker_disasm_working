from idautils import *
from idaapi import *
from idc import *
import os;
import shutil;

types = {"ASM":0, "BIN":1, "ORG":2, "PAD":3, "PADTO":4}

class Section():
    def __init__(self, type, start_address, end_address, filename, label, align = 2):
        self.type = type
        self.start_address = start_address
        self.end_address = end_address
        self.filename = filename
        self.label = label
        self.align = align

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
    
def strip_struct_defs(intext, outfile):
    write_out = False
    for line in intext:
        # Only copy lines after struct definitions, as the assembler does not recognise
        # the struc directive, and structures are not required to assemble the code.
        if(line.find("; enum") == 0):  
            write_out = True
        if write_out:
            outfile.write(line)
            
def extract_binary_data(filename, start_address, end_address, out):
    with open(filename,'rb') as infile:
        infile.seek(start_address)
        with open(out,'wb') as outfile:
            data = infile.read(end_address - start_address)
            outfile.write(data)

def ensure_dir(file_path):
    directory = os.path.dirname(file_path)
    if not os.path.exists(directory):
        os.makedirs(directory)

if os.path.exists(".\\disassembly"):
    response = -1
    while response != 0 and response != 1:
        response = askbuttons_c("","","",0,"Error! \'disassembly\' directory exists. Proceeding will delete ALL files in the \'disassembly\' directory. Proceed?")
    if response == 0:
        exit()
    else:
        for root, dirs, files in os.walk(".\\disassembly"):
            for f in files:
                os.unlink(os.path.join(root, f))
            for d in dirs:
                shutil.rmtree(os.path.join(root, d))
        
print("Exporting MAP file...")
idc.GenerateFile(idc.OFILE_MAP, ".\\landstalker.map", 0x0, 0xFFFFFF, idc.GENFLG_MAPSEG | idc.GENFLG_MAPNAME)
print("Exporting INC file...")
idc.GenerateFile(idc.OFILE_ASM, ".\\landstalker.inc", 0x0, 0x0, idc.GENFLG_ASMTYPE )


print("Generating ram.inc file from MAP output")
# Create RAM/REG symbol file from MAP file produced by IDA
with open(".\\landstalker.map", 'r') as mapfile:
    maptext = mapfile.read()
    ensure_dir(".\\disassembly\\code\\include\\ram.inc")
    with open(".\\disassembly\\code\\include\\ram.inc", 'wb') as rw:
        export_ram_labels(maptext, rw)
        
print("Stripping structure definitions from INC file...")
with open("landstalker.inc", 'r') as incfile:
    inctext = incfile.readlines()
ensure_dir(".\\disassembly\\code\\include\\landstalker.inc")
with open(".\\disassembly\\code\\include\\landstalker.inc", 'w') as iw:
    strip_struct_defs(inctext, iw)
ensure_dir(".\\disassembly\\code\\include\\macros.inc")
shutil.copyfile(".\\include\\macros.inc", ".\\disassembly\\code\\include\\macros.inc")
ensure_dir(".\\disassembly\\build\\asm68k.exe")
shutil.copyfile(".\\tools\\build\\asm68k.exe", ".\\disassembly\\build\\asm68k.exe")
ensure_dir(".\\disassembly\\build.bat")
shutil.copyfile(".\\tools\\build\\build.bat", ".\\disassembly\\build.bat")

execfile(".\\tools\\ida_scripts\\rom_sections\\us_release.py")
sections = get_sections()

print("Exporting ASM file...")
for section in sections:
    if section.type == types["ASM"]:
        ensure_dir(".\\disassembly\\" + section.filename)
        idc.GenerateFile(idc.OFILE_ASM, ".\\disassembly\\" + section.filename, section.start_address, section.end_address, 0 )
    elif section.type == types["BIN"]:
        ensure_dir(".\\disassembly\\" + section.filename)
        extract_binary_data(".\\landstalker.bin", section.start_address, section.end_address, ".\\disassembly\\" + section.filename )

print("Producing main assembly file...")
lastorg = 1
with open(".\\disassembly\\landstalker.asm", 'w') as asmfile:
    asmfile.write(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n")
    asmfile.write(";; LANDSTALKER US ROM Disassembly ;;\n")
    asmfile.write(";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n")
    asmfile.write(";;\n")
    asmfile.write(";; To build, run:\n")
    asmfile.write(";; ..\\tools\\asm68k.exe /p /o ae-,e+,w+,c+,op+,os+,ow+,oz+ landstalker.asm,landstalker.bin\n")
    asmfile.write("\n")
    asmfile.write("%-26s  include \"%s\"\n" % ("","code\\include\\landstalker.inc"))
    asmfile.write("%-26s  include \"%s\"\n" % ("","code\\include\\ram.inc"))
    asmfile.write("%-26s  include \"%s\"\n" % ("","code\\include\\macros.inc"))
    asmfile.write("\n\n")
    for section in sections:
        label = ""

        if section.type == types["BIN"] or section.type == types["ASM"]:
            if section.align > 1 and lastorg % section.align > 0:
                asmfile.write("%-26s  Align   $%X\n" % ("", section.align))
        if section.type == types["ORG"] or section.type == types["PADTO"]:
            lastorg = section.start_address
        else:
            lastorg = 1

        if len(section.label) > 0:
            label = "%s:" % section.label

        if section.type == types["ASM"]:
            asmfile.write("%-26s  include \"%s\"\n" % (label, section.filename))
        elif section.type == types["BIN"]:
            asmfile.write("%-26s  incbin  \"%s\"\n" % (label, section.filename))
        elif section.type == types["ORG"]:
            asmfile.write("%-26s  org     $%06X\n" % (label, section.start_address))
        elif section.type == types["PAD"]:
            asmfile.write("%-26s  dcb.b   $%X, $FF\n" % (label, section.end_address - section.start_address))
        elif section.type == types["PADTO"]:
            asmfile.write("%-26s  PadTo   $%06X\n" % (label, section.end_address))

print("Done!")


