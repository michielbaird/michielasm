from emulator.system import System
from specification.binary_op import BinaryOp
from specification.instruction_type import BIT_WIDTH, InstructionType
from .executors import CommandExecutor

class ALU(CommandExecutor):
    def __init__(self, operator, set_overflow=True) -> None:
        self.operator = operator
        self.set_overflow = set_overflow
    
    def execute(self, instruction: BinaryOp, system: System):
        r1_id = instruction.get_arg("reg_1")
        r2_id = instruction.get_arg("reg_2")
        t_id = instruction.get_arg("target")

        result = self.operator(
            system.registers[r1_id].val,
            system.registers[r2_id].val
        )
        mask = (1 << BIT_WIDTH) -1
        if self.set_overflow and result > mask:
            system.overflow_flag.set()
        # TODO(underflow) 
        system.registers[t_id].val = result & mask

    