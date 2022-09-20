from .instruction_type import InstructionType

class SingleConsumer(InstructionType):
    @classmethod
    def opcode(cls):
        return None

    @classmethod
    def fixed(cls):
        opc = cls.opcode()
        extra = [] if opc is None else [(11, 13, opc)] 
        return super().fixed() + [(0, 11, 132)] + extra

class LD(SingleConsumer):
    @classmethod
    def opcode(cls):
        return 0
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target_register"),
            #TODO(next_byte)
        )

class ST(SingleConsumer):
    @classmethod
    def opcode(cls):
        return 1
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "source_register"),
            #TODO(next_byte)
        )

class LDB(SingleConsumer):
    @classmethod
    def opcode(cls):
        return 2
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target_register"),
            #TODO(next_byte)
        )

class STB(SingleConsumer):
    @classmethod
    def opcode(cls):
        return 3
    
    @classmethod
    def params_def(cls):
        return (
            (13, 16, "source_register"),
            #TODO(next_byte)
        )
