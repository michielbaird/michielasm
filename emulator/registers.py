import queue
import time
from threading import Thread
import sys

class Flag:
    def __init__(self, val: bool = False) -> None:
        self.val = val
    def set(self):
        self.val = True
    def reset(self):
        self.val = False

class OutputFullFlag(Flag):
    def __init__(self, output_fifo: queue.Queue) -> None:
        super().__init__(False)
        self.fifo = output_fifo
    def set(self):
        pass
    def reset(self):
        pass
    @property
    def val(self):
        #print(self.fifo.full())
        return self.fifo.full()
    @val.setter
    def val(self, v):
        pass


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
    def __init__(self) -> None:
        self.thread = None
        self.que = queue.Queue(maxsize=4)

    @property
    def val(self):
        raise NotImplementedError
    @val.setter
    def val(self, v):
        #print("0x{:02x}".format(v))
        raw_v = v & 0xff
        self.que.put(raw_v, block=False)
        if self.thread is None or (not self.thread.is_alive()):
            self.thread = Thread(target=self.run, daemon=True)
            self.thread.start()
    def run(self):
        while not self.que.empty():
            v = self.que.get()
            time.sleep(0.010)
            #print("0x{:02x}".format(v))
            sys.stdout.buffer.write(bytes([v]))
            sys.stdout.buffer.flush()
            #print(chr(v), end="", flush=True)
            self.que.task_done()

    def __repr__(self) -> str:
        return "<OutputRegister>" #b'\xf0\x9f\x98\x80'

class FlagsRegister(InternalRegister):
    # Flags:
    # 0:0 - Error
    # 0:1 - Overflow
    # 0:2 - Underflow
    # ???
    def __init__(
        self, error: Flag, 
        overflow: Flag, 
        underflow: Flag,
        output: OutputFullFlag
    ) -> None:
        self.__error = error
        self.__underflow = underflow
        self.__overflow = overflow
        self.__output = output

    @property
    def val(self):
        e = 1 if self.__error.val else 0
        o = (1 << 1) if self.__underflow.val else 0
        u = (1 << 2) if self.__overflow.val else 0
        of = (1 << 3) if self.__output.val else 0
        return e | o | u | of
    
    @val.setter
    def val(self, v):
        self.__error.val = (v & 1) == 1
        self.__overflow.val = ((v >> 1) & 1) == 1
        self.__underflow.val = ((v >> 2) & 1) == 1
    
    def __repr__(self) -> str:
        return "<FlagsRegister err={} overflow={} undeflow={} of={}>".format(
            self.__error.val,
            self.__overflow.val,
            self.__underflow.val,
            self.__output.val
        )