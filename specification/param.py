
class Parameter(object):
    def __init__(self, name: str, description: str = ""):
        self.__name = name
        self.__description = description
    
    @property
    def name(self):
        return self.__name
    
    @property
    def description(self):
        return self.__description
        
    

class PositionalParameter(Parameter):
    def __init__(self, start: int, end: int, name: str, description: str = ""):
        super().__init__(name, description)
        self.__start = start
        self.__end = end
    
    @property
    def start(self):
        return self.__start
    
    @property
    def end(self):
        return self.__end
    
class SubParam(PositionalParameter):
    def __init__(self, start: int, end: int, name: str, description: str = ""):
        super().__init__(start, end, name, description)

class LParam(PositionalParameter):
    def __init__(self, start: int, end: int, name: str, description: str = ""):
        super().__init__(start, end, name, description)

class NextWordParam(Parameter):
    def __init__(self, name: str, description: str = ""):
        super().__init__(name, description)

        