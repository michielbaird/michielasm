from .instruction_type import InstructionType

class BinaryOp(InstructionType):
    """
    Instructions of this type take 3 3-bit parameters.
    Subclasses should overwrite a 3-bit opcode. 
    This set, however, is reserved for binary operations.
    Here register_1 and register_2 is passed to the operator
    and the result is written to the target register.
    """
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
        extra = [ (4, 7, "opcode") ] if cls.opcode() is None else []
        return [
            (13, 16, "target"),
            (10, 13, "reg_2"),
            (7, 10, "reg_1"),
        ] + extra

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