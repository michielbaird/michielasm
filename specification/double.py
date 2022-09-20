from .instruction_type import InstructionType

class Double(InstructionType):
    @classmethod
    def fixed(cls):
        opc = cls.opcode()
        extra = [] if opc is None else [(8, 10, opc)] 
        return super().fixed() + [(0, 8, 4)] + extra

    @classmethod
    def opcode(cls):
        return None

class JEZ(Double):
    @classmethod
    def opcode(cls):
        return 0
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "check_register"),
            (10, 13, "address_register"),
        )
class NOT(Double):
    @classmethod
    def opcode(cls):
        return 1
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target_register"),
            (10, 13, "source_register"),
        )

class RSR(Double):
    @classmethod
    def opcode(cls):
        return 2
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target_register"),
            (10, 13, "special_register"),
        )

class WSR(Double):
    @classmethod
    def opcode(cls):
        return 3
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "source_register"),
            (10, 13, "special_register"),
        )   
