#! /usr/bin/env python

# ? - free
# 0 - fixed
# 1 - fixed
from functools import reduce
BIT_WIDTH = 16


class InstructionType(object):
    __children = []
    def __init_subclass__(cls, *args, **kwargs):
        super().__init_subclass__(*args, *kwargs)
        cls.__children = []

        superclass = cls.__base__

        assert (cls.mask() & superclass.mask()) == superclass.mask() and \
            (cls.mask_value() & superclass.mask()) == superclass.mask_value(), \
                "Child masks have to extend the parent {:b} {:b}".format(superclass.mask(), superclass.mask_value())
        

        assert all(((cls.mask_value() ^ c.mask_value()) & cls.mask() & c.mask()) != 0 for c in superclass.__children), \
            "Fixed values must be able to uniquely divide the space: {}".format(cls)
        format = cls.format()
        test_overlap = 0
        for (start, end, _) in cls.params_def():
            assert all(v == "?" for v in format[start:end]), "Parameter cannot be on a fixed value"
            section = ((1 << end) - 1) ^ ((1 << start) - 1)
            assert (test_overlap & section) == 0, "parameters cannot overlap"
            test_overlap |= section
        superclass.__children.append(cls)

    @classmethod
    def mask(cls):
        return reduce(lambda a, b: a | b, ((1 << i) if v != "?" else 0 for (i, v) in enumerate(cls.format())))
    
    @classmethod
    def mask_value(cls):
        return reduce(lambda a, b: a | b, ((1 << i) if v == "1" else 0 for (i, v) in enumerate(cls.format())))

    @classmethod
    def format(cls):
        result = ["?"] * 16
        #print(cls.fixed())
        for (start, end, value) in cls.fixed(): 
            if type(value) == int:
                value = bin(value)[2:][::-1].ljust(end-start, "0")
            assert len(value) == end - start
            for i, j in enumerate(range(start, end)): 
                assert value[i] in ("1", "0"), f"Fixed values can only be \"1\" or \"0\" found \"{value[i]}\""
                assert result[j] == value[i] or result[j] == "?"
                result[j] = value[i]
        return "".join(result)
            
    @classmethod
    def fixed(cls):
        return []

    @classmethod 
    def params_def(cls):
        return ()

        
    
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
