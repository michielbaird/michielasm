from .instruction_type import InstructionType

class TripleParam(InstructionType):
    @classmethod
    def fixed(cls):
        opc = cls.opcode()
        extra = [] if opc is None else [(4, 7, opc)]
        return super().fixed() + [(0, 4, "0001")] + extra

    @classmethod
    def opcode(cls):
        return None

class LDR(TripleParam):
    @classmethod
    def opcode(cls):
        return 0
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "address_register"),
            (10, 13, "target_register"),
            (7, 10, "offset_register")
        )

class STR(TripleParam):
    @classmethod
    def opcode(cls):
        return 1
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "address_register"),
            (10, 13, "source_register"),
            (7, 10, "offset_register")
        )

class LDRB(TripleParam):
    @classmethod
    def opcode(cls):
        return 2
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "address_register"),
            (10, 13, "target_register"),
            (7, 10, "offset_register")
        )

class STRB(TripleParam):
    @classmethod
    def opcode(cls):
        return 3
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "address_register"),
            (10, 13, "source_register"),
            (7, 10, "offset_register")
        )
