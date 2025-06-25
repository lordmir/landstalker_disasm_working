from idautils import *
from idaapi import *
from idc import *

def decodeSingleWord(cmdaddr):
    cmd = Word(cmdaddr)
    text = "0x%04X: " % cmd
    msg = ""
    print text
    if ((cmd & 0x8000) > 0):
       stridx = (cmd & 0x1FFF) + 0x4D
       text += "PRINT MSG 0x%04X" % (stridx)
    else:
       action = (cmd & 0x1C00) >> 10
       wparam = cmd & 0x3FF
       lparam = cmd & 0x3FF
       if wparam == 0x3FF:
          wparam = Word(Dword(cmdaddr + 2))
          lparam = Dword(Dword(cmdaddr + 2))
          text += "LOAD FROM POINTER 0x%08X!  " % Dword(cmdaddr + 2)
       if action < 4:
          text += "LOAD 0x%04X INTO 0x%06X" % (wparam, 0xFF1196 + action * 2)
       elif action == 4:
          text += "LOAD %d INTO NUMERIC VARIABLE" % (lparam)
       elif action == 5:
          if wparam < 1000:
             text += "SET BIT %01X OF FLAG 0x%03X" % ((wparam & 0x07),(wparam >> 3))
          elif wparam == 1000:
             text += "RECEIVE ITEM [0xFF1196]"
          elif wparam == 1001:
             text += "RECEIVE [NUMERIC_VAR] GOLDS"
          elif wparam == 1002:
             text += "PLAY MUSIC TRACK 36"
          elif wparam == 1003:
             text += "PLAY MUSIC TRACK 14"
          else:
             text += "INVALID ACTION"
       elif action == 6:
          if wparam < 1000:
             text += "LOAD CHARACTER SCRIPT 0x%04X" % (wparam)
          else:
             text += "LOAD SPECIAL CHARACTER 0x%02X" % ((wparam - 1000))
       elif action == 7:
          offset = LocByName("CustomScriptActionTable") + 4 * wparam
          text += "LOAD CUSTOM ACTION 0x%02X (0x%06X CSA_%04X)" % (wparam, offset, wparam) 
    if ((cmd & 0x4000) > 0):
       text += ", MSGBOX CLEARED"
    if ((cmd & 0x2000) > 0):
       text += ", END"
    return text + msg

def decodeScript(cmdaddr):
    text = "Run text script at offset 0x%06X" % (cmdaddr)
    msg = ""
    while True:
        text += "\n"
        cmd = Word(cmdaddr)
        text += decodeSingleWord(cmdaddr)
        if ((cmd & 0x2000) > 0):
           break
        cmdaddr += 2
    return text
    
def decodeMessageIDOperand():
   op = GetOperandValue(ScreenEA(),0)
   offset = LocByName("CutsceneScriptTable") + op * 2
   MakeComm(ScreenEA(), "Cutscene 0x%03X: 0x%06X" % (op, offset))
   

def convoffset():
   convoffsetatbase(ScreenEA(), ScreenEA())
     
def convoffsetatbase(addr, base):
      offset = (addr - base) / 2
      if((Word(addr) & 1) == 1):
         index = (base + Word(addr) - LocByName("Script") - 1)/2
         MakeWord(addr)
         OpHex(addr,0)
         SetManualInsn(addr, "ScriptID    $%X,$%X" % (index,offset))
         cmdaddr = Word(addr) + base - 1
         text = decodeScript(cmdaddr)
      else:
         jumpaddr = base + Word(addr)
         if Word(addr) > 0x7FFF:
            jumpaddr -= 0x10000 # Treat as signed int
         name = get_name(0, jumpaddr)
         print name
         if name == "" or name == None:
            print "A"
            name = "loc_%X" % jumpaddr
            MakeName(jumpaddr, name)
         MakeWord(addr)
         OpHex(addr,0)
         SetManualInsn(addr, "ScriptJump  %s,$%X" % (name,offset))
         text = "Jump to address 0x%06X" % (Word(addr) + base)
      MakeComm(addr, text)
      return text

def convtextcmdat(addr):
   MakeComm(addr, decodeScript(addr))

def convtextcmd():
   convtextcmdat(ScreenEA())
       
def decodeflagat(addr):
   MakeComm(addr, "Bit %01X of flag 0x%03X" % (Word(addr) & 0x7, Word(addr) >> 3))

def decodeflag():
   decodeflagat(ScreenEA())

def decodeflagmsg():
   MakeWord(ScreenEA())
   decodeflagat(ScreenEA())
   MakeWord(ScreenEA() + 2)
   MakeComm(ScreenEA() + 2, "Flag clear: " + convoffsetatbase(ScreenEA()+2, ScreenEA()))
   MakeWord(ScreenEA() + 4)
   MakeComm(ScreenEA() + 4, "Flag set:   " + convoffsetatbase(ScreenEA()+4, ScreenEA()))
   Jump(ScreenEA() + 6)

def decodeflagmsg2():
   MakeWord(ScreenEA())
   decodeflagat(ScreenEA())
   MakeWord(ScreenEA() + 2)
   MakeComm(ScreenEA() + 2, "Flag set:   " + convoffsetatbase(ScreenEA()+2, ScreenEA()))
   MakeWord(ScreenEA() + 4)
   MakeComm(ScreenEA() + 4, "Flag clear: " + convoffsetatbase(ScreenEA()+4, ScreenEA()))
   Jump(ScreenEA() + 6)

def decodedialogue():
   convtextcmdat(ScreenEA())
   Jump(ScreenEA() + 2)

def convshopoffsets():
   MakeWord(ScreenEA())
   MakeComm(ScreenEA(),     "Sale prompt:       " + convoffsetatbase(ScreenEA(), ScreenEA()))
   MakeWord(ScreenEA() + 2)
   MakeComm(ScreenEA() + 2, "Sale confirmation: " + convoffsetatbase(ScreenEA()+2, ScreenEA()))
   MakeWord(ScreenEA() + 4)
   MakeComm(ScreenEA() + 4, "Not enough money:  " + convoffsetatbase(ScreenEA()+4, ScreenEA()))
   MakeWord(ScreenEA() + 6)
   MakeComm(ScreenEA() + 6, "Sale declined:     " + convoffsetatbase(ScreenEA()+6, ScreenEA()))
   Jump(ScreenEA() + 8)

def convchurchoffsets():
   MakeWord(ScreenEA())
   MakeComm(ScreenEA(),     "Normal priest:   " + convoffsetatbase(ScreenEA(), ScreenEA()))
   MakeWord(ScreenEA() + 2)
   MakeComm(ScreenEA() + 2, "Skeleton priest: " + convoffsetatbase(ScreenEA() + 2, ScreenEA()))
   Jump(ScreenEA() + 4)

def convyesnooffsets():
   MakeWord(ScreenEA())
   MakeComm(ScreenEA(),     "Prompt:       " + convoffsetatbase(ScreenEA(), ScreenEA()))
   MakeWord(ScreenEA() + 2)
   MakeComm(ScreenEA() + 2, "Answer 'yes': " + convoffsetatbase(ScreenEA()+2, ScreenEA()))
   MakeWord(ScreenEA() + 4)
   MakeComm(ScreenEA() + 4, "Answer 'no':  " + convoffsetatbase(ScreenEA()+4, ScreenEA()))
   Jump(ScreenEA() + 6)
   
def convscriptoffsetarray():
   addr = ScreenEA()
   elems = ItemSize(addr)/2
   for i in range(elems):
      MakeWord(addr + i * 2)
      MakeComm(addr + i * 2, "%s (0x%02X) : %s" % (GetCharacterName(i), i, convoffsetatbase(addr + i * 2, addr)))
   Jump(addr + i * 2 + 2)

def convscriptarray():
   addr = ScreenEA()
   elems = ItemSize(addr)/2
   for i in range(elems):
      MakeWord(addr + i * 2)
      MakeComm(addr + i * 2, convoffsetatbase(addr + i * 2, addr))
   Jump(addr + i * 2 + 2)

def convcutsceneoffsetarray():
   addr = ScreenEA()
   elems = ItemSize(addr)/2
   for i in range(elems):
      MakeWord(addr + i * 2)
      MakeComm(addr + i * 2, "ID 0x%03X : %s" % (i, convoffsetatbase(addr + i * 2, addr)))
   Jump(addr + i * 2 + 2)

def convroomscriptarray():
   addr = ScreenEA()
   i = 0
   MakeWord(addr + i * 2)
   while Word(addr + i * 2) != 0xFFFF:
      MakeWord(addr + i * 2)
      room = Word(addr + i * 2) & 0x7FF
      sz = (Word(addr + i * 2) & 0x7800) >> 11
      MakeComm(addr + i * 2, "Room 0x%03X, size %d bytes" % (room, sz))
      idx_base = 0
      for j in range(0,sz):
         if Word(addr + i * 2 + j * 2 + 2) == 0xFFFF:
            break
         MakeWord(addr + i * 2 + j * 2 + 2)
         count = (Word(addr + i * 2 + j * 2 + 2) & 0x7800) >> 11
         speaker_base = Word(addr + i * 2 + j * 2 + 2) & 0x7FF
         comment = []
         for k in range(count):
            idx = idx_base + k
            speaker = speaker_base + k
            comment += ["ID 0x%01X, Speaker 0x%02X : 0x%06X" % (idx, speaker, LocByName("CharacterScriptTable") + speaker * 2)]
         idx_base += count
         MakeComm(addr + i * 2 + j * 2 + 2, '\n'.join(comment))
      i += sz + 1
      MakeWord(addr + i * 2)
   Jump(addr + i * 2 + 2)

def convinntable():
   addr = ScreenEA()
   MakeByte(addr)
   MakeByte(addr + 1)
   MakeWord(addr + 2)
   elems = Byte(addr + 1)/2 - 2
   for i in range(elems):
      MakeWord(addr + i * 2 + 4)
      convoffsetatbase(addr + i * 2 + 4, addr)
   Jump(addr + i * 2 + 6)

def convshoptable():
   addr = ScreenEA()
   base = addr
   MakeWord(addr)
   while Word(addr) != 0xFFFF:
      MakeByte(addr + 2)
      MakeByte(addr + 3)
      elems = 5
      for i in range(elems):
         MakeWord(addr + i * 2 + 4)
         convoffsetatbase(addr + i * 2 + 4, base)
      addr += 0x0E
      MakeWord(addr)
   Jump(addr + i * 2 + 2)

def convscriptoffsets():
   addr = ScreenEA()
   base = addr
   while Word(addr) != 0xFFFF:
      MakeWord(addr)
      ctext = "Params %02X, %02X" % (Word(addr) >> 8, Word(addr) & 0xFF)
      MakeComm(addr, ctext)
      MakeWord(addr + 2)
      MakeComm(addr + 2,convoffsetatbase(addr + 2, base) + "\n")
      addr += 4
   MakeWord(addr)
   Jump(addr + 2)

charset = " 0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz*.,?!/<>:-\'\"%#&()="

def decodeString():
   addr = ScreenEA()
   length = Byte(addr)
   MakeByte(addr)
   decode = ""
   for i in range(length):
      c = Byte(addr + i + 1)
      if c < len(charset):
         decode += charset[c]
      else:
         decode += "{%02X}" % c
   MakeArray(addr, length + 1)
   MakeComm(addr, "\"" + decode + "\"")
   
def GetCharacterName(idx):
   if idx < len(names1):
      return names1[idx]
   else:
      return defaultname[0]

def GetSpecialCharacterName(idx):
   if idx < len(names2):
      return names2[idx]
   else:
      return defaultname[0]

def GetItemName(idx):
   if idx < len(items):
      return items[idx]
   else:
      return ""

def loadStringTable(addr, total):
   ret = []
   for i in range(total):
      decode = ""
      length = Byte(addr)
      for j in range(length):
         c = Byte(addr + j + 1)
         if c < len(charset):
            decode += charset[c]
         elif c == 0x69:
            decode += '-'
         elif c == 0x6A:
            decode += ' '
         elif c == 0x6B:
            pass
         else:
            decode += "{%02X}" % c
      print decode
      addr += length + 1
      ret.append(decode)
   return ret

def makeSingleInsn(addr):
    r = MakeCode(addr)
    autoWait()
    if(r == 0):
        return addr
    last_inst = addr
    while isCode(GetFlags(last_inst)) and Name(ScreenEA()) not in (BADADDR, ""):
        last_inst = ItemEnd(last_inst)
    while PrevNotTail(last_inst) > addr:
        last_inst = PrevNotTail(last_inst)
        MakeUnkn(last_inst, 0)
        autoWait()
    return ItemEnd(addr)

def processScript():
    orig_ea = ScreenEA()
    for i in range(100):
        ea = makeSingleInsn(ScreenEA())
        mnem = GetMnem(ScreenEA())
        op = GetOpnd(ScreenEA(), 0)
        print(hex(ea), mnem, op)
        Jump(ea)
        if mnem == "bsr":
            if op == "HandleYesNoPrompt":
                convyesnooffsets()
            elif op == "HandleProgressDependentDialogue":
                convscriptoffsets()
            elif op == "SetFlagBitOnTalking":
                decodeflagmsg()
            elif op == "CheckFlagAndDisplayMessage":
                decodeflagmsg2()
            elif op == "DisplayItemPriceMessage":
                convoffset()
                Jump(ea + 2)
            elif op == "HandleShopInterraction":
                convshopoffsets()
            elif op == "HandleChurchInterraction":
                convchurchoffsets()
            elif op == "Sleep_0":
                MakeWord(ea)
                OpDecimal(ea, 0)
                Jump(ea + 2)
        elif mnem == "trap":
            if op == "#$01":
                convoffset()
            else:
                MakeWord(ea)
            Jump(ea + 2)
        Refresh()
        if Name(ScreenEA()) not in (BADADDR, ""):
            break
    final_ea = ScreenEA()
    Jump(orig_ea)
    Jump(final_ea)

names1 = []
names2 = []
defaultname = []
items = []
system = []

def loadAllStrings():
   global names1
   global names2
   global defaultname
   global items
   global system
   names1 = loadStringTable(LocByName("CharacterNameTable"), 61)
   names2 = loadStringTable(LocByName("SpecialCharacterNameTable"), 15)
   defaultname = loadStringTable(LocByName("DefaultName"), 1)
   items = loadStringTable(LocByName("ItemNameTable"), 64)
   system = loadStringTable(LocByName("MenuStringTable"), 29)
   
with open("out_jp.txt") as f:
    strings = f.readlines()
strings = [x.strip() for x in strings]
with open("out_jp_chrs.txt") as f:
    names1 = f.readlines()
names1 = [x.strip() for x in names1]
with open("out_jp_schrs.txt") as f:
    names2 = f.readlines()
names2 = [x.strip() for x in names2]
with open("out_jp_dchr.txt") as f:
    defaultname = f.readlines()
defaultname = [x.strip() for x in defaultname]
with open("out_jp_items.txt") as f:
    items = f.readlines()
items = [x.strip() for x in items] 
with open("out_jp_system.txt") as f:
    system = f.readlines()
system = [x.strip() for x in system]

idaapi.add_hotkey("Ctrl-Alt-R", convroomscriptarray)
idaapi.add_hotkey("Ctrl-Alt-S", convshopoffsets)
idaapi.add_hotkey("Ctrl-Alt-T", convshoptable)
idaapi.add_hotkey("Ctrl-Alt-I", convinntable)
idaapi.add_hotkey("Ctrl-Alt-A", convscriptarray)
idaapi.add_hotkey("Ctrl-Alt-O", convscriptoffsetarray)
idaapi.add_hotkey("Ctrl-Alt-X", convcutsceneoffsetarray)
idaapi.add_hotkey("Ctrl-Alt-C", convchurchoffsets)
idaapi.add_hotkey("Ctrl-Alt-1", convoffset)
idaapi.add_hotkey("Ctrl-Alt-Y", convyesnooffsets)
idaapi.add_hotkey("Ctrl-Alt-F", decodeflag)
idaapi.add_hotkey("Ctrl-Alt-D", decodeMessageIDOperand)
idaapi.add_hotkey("Ctrl-Alt-Q", decodeflagmsg)
idaapi.add_hotkey("Ctrl-Alt-W", decodeflagmsg2)
idaapi.add_hotkey("Ctrl-Alt-Z", convscriptoffsets)
idaapi.add_hotkey("Ctrl-Alt-N", decodeString)
idaapi.add_hotkey("Ctrl-Alt-L", processScript)