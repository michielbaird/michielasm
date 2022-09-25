from argparse import ArgumentError

from specification.param import NextWordParam, PositionalParameter
from .system import System

from specification.instruction_type import InstructionType


class BinParser:

    def parse_instruction(self, word, system: System):
        current = InstructionType
        matched = True
        while matched and len(children := current.children()) > 0:
            matched = False
            for c in children:
                if (word & c.mask()) == c.mask_value():
                    matched = True
                    current = c
                    break
        if not matched:
            raise ArgumentError("Could not match word to an instruction")
        args = {}
        for p in current.floating_params():
            if isinstance(p, NextWordParam):
                lsb, msb = system.memory.read_word(system.PC.val)
                system.PC.inc()
                args[p.name] = (msb << 8) | lsb
            elif isinstance(p, PositionalParameter):
                mask = (1 << (p.end - p.start)) - 1
                args[p.name] = (word >> p.start) & mask
            else:
                raise ArgumentError("Unknown parameter type")
        return current(**args)





        