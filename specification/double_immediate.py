
from .param import SubParam, LParam
from .instruction_type import InstructionType 

class DoubleImmediate(InstructionType):
    """
    Instructions of this type, take 3 parameters. Two register_indexes
    followed by a 7-bit immediate value.
    """
    @classmethod 
    def fixed(cls):
        return super().fixed() + [(0, 1, 1)]
    @classmethod
    def params_def(cls):
        return [
            SubParam(13, 16, "reg_1"),
            SubParam(10, 13, "reg_2"),
            SubParam(3, 10, "immediate_value", param_type="NUM_EXPR"),
            SubParam(1, 3, "opcode")
        ]

class AddI(DoubleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(1, 3, 0)]
    
    @classmethod
    def params_def(cls):
        return [
            LParam(10, 13, "source"),
            LParam(13, 16, "target"),
            LParam(3, 10, "value", param_type="NUM_EXPR")
        ]

class SubI(DoubleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(1, 3, 1)]
    
    @classmethod
    def params_def(cls):
        return [
            LParam(10, 13, "source"),
            LParam(13, 16, "target"),
            LParam(3, 10, "value", param_type="NUM_EXPR")
        ]