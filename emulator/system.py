from emulator.registers import *
from .memory_module import MemoryModule


class System:
    def __init__(self) -> None:
        self.PC = ProgramCounter()
        self.error_flag = Flag()
        self.overflow_flag = Flag()
        self.underflow_flag = Flag()
        self.output_reg = OutputRegister()
        self.special = [
            self.PC,
            FlagsRegister(
                self.error_flag,
                self.overflow_flag,
                self.underflow_flag,
                OutputFullFlag(self.output_reg.que)
            ),
            self.output_reg,
            IORegister(),
            IORegister(),
            IORegister(),
            IORegister(),
            IORegister(),
        ]
        self.registers = [
            ZeroRegister(self.error_flag),
            IORegister(),
            IORegister(),
            IORegister(),
            IORegister(),
            IORegister(),
            IORegister(),
            IORegister(),
        ]
        self.memory = MemoryModule()
