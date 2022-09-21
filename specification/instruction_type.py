#! /usr/bin/env python

# ? - free
# 0 - fixed
# 1 - fixed
from functools import reduce
from .param import LParam, PositionalParameter, SubParam,NextWordParam
BIT_WIDTH = 16


class InstructionType(object):        
    """
    Base instruction type. All values are can be overwritten by 
    subclasses of this type. 
    """
    __children = []
    def __init__(self, **kwargs) -> None:
        self.__args = kwargs
    
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
    def check_params_valid(cls):
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
    
    @classmethod
    def children(cls):
        return cls.__children[:]
    
    @classmethod
    def should_consume_next_word(cls):
        return sum(1 for p in cls.params_def() if isinstance(p, NextWordParam)) > 0
  