from .instruction_type import InstructionType

class SingleImmediate(InstructionType):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(0, 2, "01")]

class LDI(SingleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(2, 4, 0)]
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target_register"),
            (4, 13, "value")
        )

class STI(SingleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(2, 4, 1)]
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "address_register"),
            (4, 13, "value")
        )

class LDIB(SingleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(2, 4, 2)]
    @classmethod
    def params_def(cls):    
        return (
            (13, 16, "target_register"),
            (4, 13, "value")
        )

class STIB(SingleImmediate):
    @classmethod
    def fixed(cls):
        return super().fixed() + [(2, 4, 3)]
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "address_register"),
            (4, 13, "value")
        )
