from .param import SubParam, LParam
from .instruction_type import InstructionType

class SingleImmediate(InstructionType):
    """
    Instructions of this form have two parameters. The first
    is a 3-bit register identifier and the second is an 9-bit immediate value.

    Each instruction can be distinguished by a 2-bit opcode that should 
    be set for each subclass.
    """
    @classmethod
    def fixed(cls):
        return super().fixed() + [(0, 2, "01")]
    
    @classmethod
    def params_def(cls):
        return [
            SubParam(13, 16, "register"),
            SubParam(4, 13, "immediate_value"),
            SubParam(2, 4, "opcode")
        ]

class LDI(SingleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(2, 4, 0)]
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "target_register"),
            LParam(4, 13, "value")
        ]

class STI(SingleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(2, 4, 1)]
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "address_register"),
            LParam(4, 13, "value")
        ]

class LDIB(SingleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(2, 4, 2)]
    @classmethod
    def params_def(cls):    
        return [
            LParam(13, 16, "target_register"),
            LParam(4, 13, "value")
        ]

class STIB(SingleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(2, 4, 3)]
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "address_register"),
            LParam(4, 13, "value")
        ]
