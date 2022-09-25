#! /usr/bin/env python

# ? - free
# 0 - fixed
# 1 - fixed
from functools import cache, reduce
from typing import Optional, Sequence, Type, TypeVar, Tuple, Union
from unicodedata import name
from .param import LParam, Parameter, PositionalParameter, SubParam, NextWordParam

BIT_WIDTH = 16


class InstructionType(object):        
    """
    Base instruction type. All values are can be overwritten by 
    subclasses of this type. 
    """
    __children = []
    def __init__(self, **kwargs) -> None:
        params = self.floating_params()
        clean_args = {}
        for p in params:
            val = kwargs[p.name]
            assert p.is_value_valid(val), \
                 "Value is not in range {} {}".format(p.name, val)
            clean_args[p.name] = val

        self.__args = clean_args
    
    def __init_subclass__(cls, *args, **kwargs):
        super().__init_subclass__(*args, *kwargs)
        cls.__children = []

        superclass = cls.__base__

        assert (cls.mask() & superclass.mask()) == superclass.mask() and \
            (cls.mask_value() & superclass.mask()) == superclass.mask_value(), \
                "Child masks have to extend the parent {:b} {:b}".format(superclass.mask(), superclass.mask_value())
        

        assert all(((cls.mask_value() ^ c.mask_value()) & cls.mask() & c.mask()) != 0 for c in superclass.__children), \
            "Fixed values must be able to uniquely divide the space: {}".format(cls)
        cls.check_params_valid()
        superclass.__children.append(cls)
    
    @classmethod
    def check_params_valid(cls) -> bool:
        format = cls.format()
        test_overlap = 0
        
        for p in filter(lambda x: isinstance(x, PositionalParameter), cls.params_def()):
            start, end = p.start, p.end
            section = ((1 << end) - 1) ^ ((1 << start) - 1)
            assert (test_overlap & section) == 0, "parameters cannot overlap"
            test_overlap |= section

        for p in filter(lambda x: isinstance(x, LParam), cls.params_def()):
            start, end = p.start, p.end
            assert all(v == "?" for v in format[start:end]), "Parameter cannot be on a fixed value"

        for p in filter(lambda x: isinstance(x, SubParam), cls.params_def()):
            start, end = p.start, p.end
            assert all(v == "?" for v in format[start:end]) or \
                all(v != "?" for v in format[start:end]), "SubParams cannot be partially fixed"

        assert sum(1 for p in cls.params_def() if isinstance(p, NextWordParam)) <= 1, "Maximum of 1 NextWordParam"

    @classmethod
    def mask(cls) -> int:
        return reduce(lambda a, b: a | b, ((1 << i) if v != "?" else 0 for (i, v) in enumerate(cls.format())))
    
    @classmethod
    def mask_value(cls) -> int:
        return reduce(lambda a, b: a | b, ((1 << i) if v == "1" else 0 for (i, v) in enumerate(cls.format())))

    @classmethod
    def format(cls) -> str:
        result = ["?"] * BIT_WIDTH
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
    def cmd_name(cls) -> str:
        return cls.__name__

    @classmethod
    def fixed(cls) -> Sequence[Tuple[int, int, Union[str, int]]]:
        return []

    @classmethod 
    def params_def(cls) -> Sequence[Parameter]:
        return ()

    @classmethod
    def floating_params(cls) -> Sequence[Parameter]:
        result = []
        fmt = cls.format()
        for p in cls.params_def():
            if isinstance(p, SubParam):
                if fmt[p.start] == "?":
                    result.append(p)
            else:
                result.append(p)
        return result
    
    @classmethod
    def children(cls):
        return cls.__children[:]
    
    @classmethod
    def should_consume_next_word(cls) -> bool:
        return sum(1 for p in cls.params_def() if isinstance(p, NextWordParam)) > 0
    
    def get_arg(self, name) -> Optional[name]:
        return self.__args.get(name)

    def encode(self) -> bytes:
        word = 0
        second_word = None
        for (start, _, val) in self.fixed():
            match val:
                case str(v):
                    val = int(val[::-1], 2)
            word = word | (val << start)
        
        for p in self.floating_params():
            val = self.__args[p.name]
            if isinstance(p, PositionalParameter):
                word = word | (val << p.start)
            elif isinstance(p ,NextWordParam):
                second_word = val
        r = [word & 0xff, (word >> 8) & 0xff]
        if second_word is not None:
            r.extend([second_word & 0xff, (second_word >> 8) & 0xff])
        return bytes(r)

InstructionTypeU = TypeVar('InstructionTypeU', bound=InstructionType)


@cache
def all_leaf_commands() -> Sequence[Type[InstructionTypeU]]:
    commands = []
    def dfs(ins):
        if len(ins.children()) == 0:
            commands.append(ins)
        for c in ins.children():
            dfs(c)
    dfs(InstructionType)
    return commands

@cache
def leaf_command_dict() -> dict[str, Type[InstructionTypeU]]:
    cmds = all_leaf_commands()
    result = {}
    for cmd in cmds:
        result[cmd.cmd_name().upper()] = cmd
    return result
    