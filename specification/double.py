from .param import SubParam, LParam
from .instruction_type import InstructionType

class Double(InstructionType):
    """
    This class of instruction is defined by having two
    3-bit instructions. Subclasses have to set a unique
    2-bit opcode.
    """
    @classmethod
    def fixed(cls):
        opc = cls.opcode()
        extra = [] if opc is None else [(8, 10, opc)] 
        return super().fixed() + [(0, 8, 4)] + extra
    @classmethod
    def params_def(cls):
        return [
            SubParam(13, 16, "reg_1"),
            SubParam(10, 13, "reg_2"),
            SubParam(8, 10, "opcode"),
        ]
    @classmethod
    def opcode(cls):
        return None

class JEZ(Double):
    @classmethod
    def opcode(cls):
        return 0
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "check_register"),
            LParam(10, 13, "address_register"),
        ]
class NOT(Double):
    @classmethod
    def opcode(cls):
        return 1
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "target_register"),
            LParam(10, 13, "source_register"),
        ]

class RSR(Double):
    @classmethod
    def opcode(cls):
        return 2
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "target_register"),
            LParam(10, 13, "special_register"),
        ]

class WSR(Double):
    @classmethod
    def opcode(cls):
        return 3
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "source_register"),
            LParam(10, 13, "special_register"),
        ]
