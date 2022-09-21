
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
        return (
            (13, 16, "reg_1"),
            (10, 13, "reg_2"),
            (3, 10, "immediate_value"),
            (1, 3, "opcode")
        )   

class AddI(DoubleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(1, 3, 0)]
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target"),
            (10, 13, "source"),
            (3, 10, "value")
        )

class SubI(DoubleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(1, 3, 1)]
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target"),
            (10, 13, "source"),
            (3, 10, "value")
        )