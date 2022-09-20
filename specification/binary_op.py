from .instruction_type import InstructionType

class BinaryOp(InstructionType):
    @classmethod
    def fixed(cls):
        opc = cls.opcode()
        extra = [] if opc is None else [(4, 7, opc)] 
        return super().fixed() + [(0, 4, "0000")] + extra

    @classmethod
    def opcode(cls):
        return None

    @classmethod
    def params_def(cls):
        return (
            (13, 16, "target_register"),
            (10, 13, "register_2"),
            (7, 10, "register_1"),
        )

class AndOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 0

class OrOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 1

class XorOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 2

class AddOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 3

class AddUOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 4

class SlOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 5

class SrOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 6

class SubOperator(BinaryOp):
    @classmethod
    def opcode(cls):
        return 7