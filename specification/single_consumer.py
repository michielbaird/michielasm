from .param import SubParam, LParam, NextWordParam
from .instruction_type import InstructionType

class SingleConsumer(InstructionType):
    """
    Instructions of this type take two parameters but are somewhat special.
    The first instrcution points to a 3-bit register. The second parameter is a the word
    following this instruction. The documentation/spec cannot represent this yet.
    Subclass have to overwrite a unique 2-bit opcode.
    """
    @classmethod
    def opcode(cls):
        return None

    @classmethod
    def fixed(cls):
        opc = cls.opcode()
        extra = [] if opc is None else [(11, 13, opc)] 
        return super().fixed() + [(0, 11, 132)] + extra
    
    @classmethod
    def params_def(cls):
        return (
            SubParam(13, 16, "register"),
            SubParam(11, 13, "opcode")
        )

class LD(SingleConsumer):
    @classmethod
    def opcode(cls):
        return 0
    
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "target"),
            NextWordParam(
                "address", 
                param_type="ADDR_OR_REG"
            )
        ]

class ST(SingleConsumer):
    @classmethod
    def opcode(cls):
        return 1
    
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "source"),
            NextWordParam(
                "address", 
                param_type="ADDR_OR_REG"
            )        
        ]

class LDW(SingleConsumer):
    @classmethod
    def opcode(cls):
        return 2
    
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "target"),
            NextWordParam(
                "value", 
                param_type="ADDR_OR_REG"
            )        
        ]

class STB(SingleConsumer):
    @classmethod
    def opcode(cls):
        return 3
    
    @classmethod
    def params_def(cls):
        return [
            LParam(13, 16, "source"),
            NextWordParam(
                "address", 
                param_type="ADDR_OR_REG"
            )        
        ]
