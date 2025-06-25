from idautils import *
from idaapi import *
from idc import *
import os;
import shutil;
import re
import json

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
        
def copy_file(src, dst):
    ensure_dir(dst)
    shutil.copyfile(src, dst)

def strip_init_label(filename):
    with open(filename, 'r') as file:
        lines = file.readlines()
    lines[0] = re.sub("^[A-Za-z0-9_]+:","\t\t",lines[0])
    with open(filename, 'w') as file:
        file.writelines(lines)

def get_addr(label):
    offset = 0
    if label.endswith("+1"):
        offset = 1
        label = label[:-2]
    elif label.endswith("-1"):
        offset = -1
        label = label[:-2]
    print("*" + label + "*")
    addr = LocByName(label.encode("ascii"))
    if addr == BADADDR:
        raise RuntimeError(label + " not found")
    return addr + offset


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

copy_file(".\\include\\macros.inc", ".\\disassembly\\code\\include\\macros.inc")
copy_file(".\\tools\\build\\asm68k.exe", ".\\disassembly\\tools\\build\\asm68k.exe")
copy_file(".\\tools\\build\\fix_checksum.py", ".\\disassembly\\tools\\build\\fix_checksum.py")
copy_file(".\\tools\\build\\build.bat", ".\\disassembly\\build.bat")
copy_file(".\\tools\\build\\build_expanded.bat", ".\\disassembly\\build_expanded.bat")
copy_file(".\\tools\\decode\\lz77.exe", ".\\disassembly\\tools\\decode\\lz77.exe")
copy_file(".\\tools\\decode\\pal2tpl.exe", ".\\disassembly\\tools\\decode\\pal2tpl.exe")
copy_file(".\\tools\\decode\\map2d.exe", ".\\disassembly\\tools\\decode\\map2d.exe")
copy_file(".\\tools\\decode\\map3d.exe", ".\\disassembly\\tools\\decode\\map3d.exe")
copy_file(".\\tools\\decode\\strings.exe", ".\\disassembly\\tools\\decode\\strings.exe")
copy_file(".\\tools\\decode\\compress.bat", ".\\disassembly\\compress.bat")
copy_file(".\\tools\\decode\\expand.bat", ".\\disassembly\\expand.bat")
copy_file(".\\expanded\\landstalker_expanded.asm", ".\\disassembly\\landstalker_expanded.asm")
copy_file(".\\expanded\\sounddrv_expanded.z80", ".\\disassembly\\sounddrv_expanded.z80")

with open(".\\tools\\ida_scripts\\rom_sections\\sections_eur.json") as f:
    sections = json.load(f)["sections"]

print("Exporting ASM file...")
for section in sections:
    ensure_dir(".\\disassembly\\" + section["filename"])
    start_address = get_addr(section["start"])
    end_address = get_addr(section["end"])
    if section["type"] == types["ASM"]:
        idc.GenerateFile(idc.OFILE_ASM, ".\\disassembly\\" + section["filename"].encode("ascii"), start_address, end_address, 0 )
    elif section["type"] == types["BIN"]:
        extract_binary_data(".\\" + get_root_filename(), start_address, end_address, ".\\disassembly\\" + section["filename"].encode("ascii") )
    
# Post Processing
strip_init_label("disassembly\\code\\pointertables\\strings\\introstringptrs.asm")
strip_init_label("disassembly\\code\\pointertables\\maps\\roomlist.asm")
strip_init_label("disassembly\\code\\script\\characters\\script_charactertable.asm")
strip_init_label("disassembly\\code\\script\\cutscenes\\script_cutscenetable.asm")
strip_init_label("disassembly\\code\\script\\shops\\shoptable.asm")
strip_init_label("disassembly\\code\\script\\shops\\shoptable_specialitems.asm")

print("Done!")


