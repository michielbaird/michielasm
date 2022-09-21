class MemoryModule(object):
    def __init__(self) -> None:
        self.__storage = [0]*0x10000

    def read_byte(self, address: int) -> int:
        return self.__storage[address & 0xffff]
    
    def read_word(self, address: int) -> tuple[int, int]:
        first = self.__storage[address & 0xffff]
        second = self.__storage[(address + 1) & 0xffff]
        return first, second
    
    def write_byte(self, address:int, val: int):
        self.__storage[address & 0xffff] = val & 0xff
    
    def write_word(self, address:int, first: int, second: int):
        self.__storage[address & 0xffff] = first & 0xff
        self.__storage[(address + 1) & 0xffff] = second & 0xff

    # FOR TESTING
    def write_bytes(self, offset, data):
        for i, d in enumerate(data):
            self.__storage[(i + offset) & 0xffff] = d & 0xff