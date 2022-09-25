from .param import SubParam, LParam
from .instruction_type import InstructionType

class BinaryOp(InstructionType):
    """
    Instructions of this type take 3 3-bit parameters.
    Subclasses should overwrite a 3-bit opcode. 
    This set, however, is reserved for binary operations.
    Here register_1 and register_2 is passed to the operator
    and the result is written to the target register.
    """
    @classmethod
    def fixed(cls):
        opc = cls.opcode()
        extra = [] if opc is None else [(4, 7, opc)] 
        return super().fixed() + [(0, 4, "0000")] + extra

    @classmethod
    def opcode(cls):
        return None

    @classmethod
    def params_def(cls):
        return [            
            SubParam(4, 7, "opcode"),
            SubParam(7, 10, "reg_1"),
            SubParam(10, 13, "reg_2"),
            SubParam(13, 16, "target"),
        ]

class AndOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 0
    @classmethod
    def cmd_name(cls):
        return "AND"

class OrOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 1
    @classmethod
    def cmd_name(cls):
        return "OR"

class XorOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 2
    @classmethod
    def cmd_name(cls):
        return "XOR"

class AddOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 3
    @classmethod
    def cmd_name(cls):
        return "ADD"

class AddUOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 4
    @classmethod
    def cmd_name(cls):
        return "ADDU"

class SlOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 5

    @classmethod
    def cmd_name(cls):
        return "SL"

class SrOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 6
    @classmethod
    def cmd_name(cls):
        return "SR"

class SubOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 7
    @classmethod
    def cmd_name(cls):
        return "SUB"