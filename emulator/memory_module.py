
class MemoryModule(object):
    def __init__(self) -> None:
        self.__storage = [0]*0x10000

    def read_byte(self, address: int) -> int:
        return self.__storage[address & 0xffff]
    
    # LSB, MSB
    def read_word(self, address: int) -> tuple[int, int]:
        first = self.__storage[address & 0xffff]
        second = self.__storage[(address + 1) & 0xffff]
        return first, second
    
    def write_byte(self, address:int, val: int) -> None:
        self.__storage[address & 0xffff] = val & 0xff
    
    def write_word(self, address:int, msb: int, lsb: int) -> None:
        self.__storage[address & 0xffff] = lsb & 0xff
        self.__storage[(address + 1) & 0xffff] = msb & 0xff

    # FOR TESTING
    def write_bytes(self, offset: int, data: bytes) -> None:
        for i, d in enumerate(data):
            self.__storage[(i + offset) & 0xffff] = d