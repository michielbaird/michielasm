from .param import SubParam, LParam
from .instruction_type import InstructionType

class TripleParam(InstructionType):
    """
    Instructions of this type take 3 3-bit parameters.
    Subclasses should overwrite a 3-bit opcode.
    """
    @classmethod
    def fixed(cls):
        opc = cls.opcode()
        extra = [] if opc is None else [(4, 7, opc)]
        return super().fixed() + [(0, 4, "0001")] + extra
    
    @classmethod
    def params_def(cls):
        return [
            SubParam(13, 16, "param_1"),
            SubParam(10, 13, "param_2"),
            SubParam(7, 10, "param_3"),
            SubParam(4, 7, "opcode")
        ]

    @classmethod
    def opcode(cls):
        return None

class LDR(TripleParam):
    @classmethod
    def opcode(cls):
        return 0
    
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "address_register"),
            LParam(7, 10, "offset_register"),
            LParam(10, 13, "target_register"),
        ]

class STR(TripleParam):
    @classmethod
    def opcode(cls):
        return 1
    
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "address_register"),
            LParam(7, 10, "offset_register"),
            LParam(10, 13, "value_register"),
        ]

class LDRB(TripleParam):
    @classmethod
    def opcode(cls):
        return 2
    
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "address_register"),
            LParam(7, 10, "offset_register"),
            LParam(10, 13, "target_register"),
        ]

class STRB(TripleParam):
    @classmethod
    def opcode(cls):
        return 3
    
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "address_register"),
            LParam(7, 10, "offset_register"),
            LParam(10, 13, "value_register"),
        ]

class LtOperator(TripleParam):
    @classmethod
    def opcode(cls):
        return 4
    @classmethod
    def cmd_name(cls):
        return "LT"
    
    @classmethod
    def params_def(cls):
        return [
            LParam(7, 10, "reg_1"),
            LParam(10, 13, "reg_2"),
            LParam(13, 16, "target"),
        ]