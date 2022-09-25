class Flag:
    def __init__(self, val: bool = False) -> None:
        self.val = val
    def set(self):
        self.val = True
    def reset(self):
        self.val = False

class InternalRegister:
    @property
    def val(self):
        raise NotImplementedError
    @val.setter
    def val(self, v):
        raise NotImplementedError
    
    def __repr__(self) -> str:
        n = self.__class__.__name__
        return "<{} val={}>".format(n, self.val)

class ZeroRegister(InternalRegister):
    def __init__(self, error_flag: Flag) -> None:
        super().__init__()
        self.__error = error_flag
    @property
    def val(self):
        return 0
    @val.setter
    def val(self, v):
        if v != 0:
            self.__error.set()
 

class IORegister(InternalRegister):
    def __init__(self, val=0) -> None:
        self._val = val
    @property
    def val(self):
        return self._val
    @val.setter
    def val(self, v):
        self._val = v

class ProgramCounter(IORegister):
    def inc(self):
        self._val += 2

class OutputRegister(InternalRegister):
    @property
    def val(self):
        raise NotImplementedError
    @val.setter
    def val(self, v):
        print("{0} 0x{0:04x}".format(v))
    def __repr__(self) -> str:
        return "<OutputRegister>"

class FlagsRegister(InternalRegister):
    # Flags:
    # 0:0 - Error
    # 0:1 - Overflow
    # 0:2 - Underflow
    # ???
    def __init__(self, error: Flag, overflow: Flag, underflow: Flag) -> None:
        self.__error = error
        self.__underflow = underflow
        self.__overflow = overflow

    @property
    def val(self):
        e = 1 if self.__error.val else 0
        o = (1 << 1) if self.__underflow.val else 0
        u = (1 << 2) if self.__overflow.val else 0
        return e | o | u
    
    @val.setter
    def val(self, v):
        self.__error.val = (v & 1) == 1
        self.__overflow.val = ((v >> 1) & 1) == 1
        self.__underflow.val = ((v >> 2) & 1) == 1
    
    def __repr__(self) -> str:
        return "<FlagsRegister err={} overflow={} undeflow={}>".format(
            self.__error.val,
            self.__overflow.val,
            self.__underflow.val
        )