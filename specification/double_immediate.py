
from .instruction_type import InstructionType 

class DoubleImmediate(InstructionType):
    @classmethod 
    def fixed(cls):
        return super().fixed() + [(0, 1, 1)]

class AddI(DoubleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(1, 3, 0)]
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target_register"),
            (10, 13, "source_register"),
            (3, 10, "value")
        )

class SubI(DoubleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(1, 3, 1)]
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target_register"),
            (10, 13, "source_register"),
            (3, 10, "value")
        )