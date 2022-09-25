from emulator.alu import ALU
from emulator.bin_parser import BinParser
from emulator.executors import AddIExecutor, JezExecutor, LDExecutor, LDIBExecutor, LDIExecutor, LDRExecutor, LDWExecutor, NotExecutor, RSRExecutor, STBExecutor, STBIExecutor, STExecutor, STIExecutor, STRBExecutor, STRExecutor, SubIExecutor, WSRExecutor
from .system import System

class CPU:
    def __init__(self) -> None:
        self.system = System()
        self.PC = self.system.PC
        self.parser = BinParser()
        self.register_executors()

    def processInstruction(self):
        lsb, msb = self.system.memory.read_word(self.PC.val)
        self.PC.inc()
        word = (msb << 8) | lsb
        instruction = self.parser.parse_instruction(
            word,
            self.system
        )
        executor = self.executors[instruction.cmd_name().upper()]
        executor.execute(instruction, self.system)
        #print(instruction)

    def run(self):
        try:
            old = self.system.PC.val
            while True:
                self.processInstruction()
                current = self.system.PC.val
                if old == current:
                    print("Program Halted Successfully!")
                    break
                old = current
        except KeyboardInterrupt:
            print("Program stopped!!")
        joiner = "\n    "
        print("""PC: 0x{pc:04x} ({pc})
Registers: 
    {reg}

SpecialRegisters:
    {spec}
""".format(
            pc=self.system.PC.val, 
            reg=joiner.join(repr(r) for r in self.system.registers),
            spec=joiner.join(repr(r) for r in self.system.special)
        ))
        self.reset()

    def reset(self):
        self.system.PC.val = 0
        for r in self.system.registers[1:]:
            r.val = 0
        self.system.error_flag.reset()
        self.system.overflow_flag.reset()
        self.system.underflow_flag.reset()
        for s in self.system.special[3:]:
            s.val = 0

    # For testing
    def write_blob(self, offset: int,  raw_b: bytes):
        self.system.memory.write_bytes(offset, raw_b)
    
    def register_executors(self):
        executors = {}
        executors["AND"] = ALU(lambda r1, r2: r1 & r2)
        executors["OR"] = ALU(lambda r1, r2: r1 | r2)
        executors["XOR"] = ALU(lambda r1, r2: r1 ^ r2)
        executors["ADD"] = ALU(lambda r1, r2: r1 + r2) # TODO 
        executors["ADDU"] = ALU(lambda r1, r2: r1 + r2)
        executors["SL"] = ALU(lambda r1, r2: r1 << r2)
        executors["SR"] = ALU(lambda r1, r2: r1 >> r2)
        executors["SUB"] = ALU(lambda r1, r2: r1 - r2)

        executors["ADDI"] = AddIExecutor()
        executors["SUBI"] = SubIExecutor()

        executors["JEZ"] = JezExecutor()
        executors["NOT"] = NotExecutor()
        executors["RSR"] = RSRExecutor()
        executors["WSR"] = WSRExecutor()

        executors["LD"] = LDExecutor()
        executors["ST"] = STExecutor()
        executors["LDW"] = LDWExecutor() # TODO(xcxc)
        executors["STB"] = STBExecutor()
        executors["LDI"] = LDIExecutor()
        executors["STI"] = STIExecutor()
        executors["LDIB"] = LDIBExecutor()
        executors["STIB"] = STBIExecutor()

        executors["LDR"] = LDRExecutor()
        executors["STR"] = STRExecutor()
        executors["LDRB"] = LDRExecutor()
        executors["STRB"] = STRBExecutor()


        self.executors = executors
        
        


