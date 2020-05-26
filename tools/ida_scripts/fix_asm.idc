#define UNLOADED_FILE   1
#include <idc.idc>

static main(void) {
	auto addr;
	auto val;

	// Start from the first piece of code found...
	addr = FindCode(0x00000000, SEARCH_DOWN);
	// ... and keep going until we run out of code to process
	while (addr != BADADDR) {
		// Get opcode and check it
		val = Word(addr);
		if ((val & 0xFFBF) == 0x4EB8) {
			// (jmp|jsr) (XXX).w
			FixOperand(addr, 0, "(%s).w");
		} else if ((val & 0xFFBF) == 0x4EB9) {
			// (jmp|jsr) (XXX).l
			FixOperand(addr, 0, "(%s).l");
		} else if ((val & 0xF1FF) == 0x41FA || (val & 0xFFBF) == 0x4EBA || val == 0x487A) {
			// (jmp|jsr|lea|pea) XXX(pc)
			FixOperand(addr, 0, "%s(pc)");
		} else if ((val & 0xFFF8) == 0x4E60) {
			// (move a*,usp)
			ChangeInstruction(addr, "move.l");
		}
		else if ((val & 0xF138) == 0x0108)
		{
			// movep - fix for negative offsets
			FixMovepInst(addr);
		}
		else if ((val & 0xC03F) == 0x003A)
		{
			//move source PC relative:
			FixOperand(addr, 0, "(%s,pc)");
		}
		else if ((val & 0xF1FF) == 0x41F9)
		{
			// 4-byte LEA fix
			Fix4ByteLeaInst(addr);
		}
		addr = FindCode(addr, SEARCH_DOWN);
	}
}

static Fix4ByteLeaInst(addr)
{
	// Use all four bytes of LEA operand.
	// IDA, by default, truncates LEA params to three bytes
	auto mnem = GetDisasm(addr);
	auto data = Dword(addr+2);
	if((data >> 24) > 0)
	{
		OpAlt(addr, 0, "");
		OpOff(addr, 0, 0);
		auto newop = sprintf("($%08X).l",data);
		OpAlt(addr, 0, newop);
		Message("%s:%08X: %-60s\t%-60s\n", SegName(addr), addr, mnem, newop);
	}
}

static FixMovepInst(addr)
{
	// IDA interprets signed 16 bit offsets as unsigned
	// Fix this by converting out of range positive offsets to negative
	auto mnem = GetDisasm(addr);
	auto val = Word(addr);
	auto data = Word(addr + 2);
	if(data > 0x7FFF) // 16 bit signed - should be 2s complement negative
	{
		data = (~data + 1) & 0xFFFF;
		auto address_reg = (val & 0x0007);
		auto newop = sprintf("-$%04X(a%d)", data, address_reg);
		if((val & 0x0080) > 0) // move reg to address
		{
			OpAlt(addr, 1, newop);
		}
		else // move address to reg
		{
			OpAlt(addr, 0, newop);
		}
		Message("%s:%08X: %-60s\t%-60s\n", SegName(addr), addr, mnem, newop);
	}
}

static ChangeInstruction(addr, newmnem)
{
	auto inst = GetDisasm(addr);
	auto mnem = substr(inst, 0, strstr(inst, " "));
	auto params = substr(inst, strstr(inst, " ")+1, strlen(inst));
	auto new_inst = inst;
	if (strstr(mnem, newmnem) <0)
	{
		new_inst = sprintf("%s %s", newmnem, params);
		SetManualInsn(addr, new_inst);
	}
	Message("%s:%08X: %-60s\t%-60s\n", SegName(addr), addr, mnem, new_inst);
}

static FixOperand(addr, opnum, fmt) {
	auto mnem;
	auto opnd;
	auto name;
	// Get current disassembly line for comparison
	mnem = GetDisasm(addr);
	// Reset offset (fixes an issue with pc-relative addresses)
	OpAlt(addr, opnum, "");
	OpOff(addr, opnum, 0);
	// Get value of operand (the instructions we are looking for only have one)
	opnd = GetOpnd(addr, opnum);
	// Generate new representation
	if (strstr(opnd, "(") == 0) {
		name = sprintf(fmt, substr(opnd, 1, strlen(opnd)-3));
		if (strstr(name, opnd) != -1) {
			return;
		}
	} else if (strstr(opnd, "(pc)") > -1) {
		name = sprintf(fmt, substr(opnd, 0, strlen(opnd)-4));
		if (strstr(name, opnd) != -1) {
			return;
		}
	}
	name = sprintf(fmt, opnd);
	// Set manual operand representation
	OpAlt(addr, opnum, name);
	// Log what we did
	Message("%s:%08X: %-60s\t%-60s\n", SegName(addr), addr, mnem, GetDisasm(addr));
}