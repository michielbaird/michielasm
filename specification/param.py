
class Parameter(object):
    def __init__(self, name: str, description: str = "", param_type="REGISTER"):
        self.__name = name
        self.__description = description
        self.__param_type = param_type
    
    @property
    def name(self):
        return self.__name
    
    @property
    def description(self):
        return self.__description
    
    @property
    def param_type(self):
        return self.__param_type

    def is_value_valid(self, val):
        return False
        
    

class PositionalParameter(Parameter):
    def __init__(self, start: int, end: int, name: str, description: str = "", param_type="REGISTER"):
        super().__init__(name, description, param_type)
        self.__start = start
        self.__end = end
    
    @property
    def start(self):
        return self.__start
    
    @property
    def end(self):
        return self.__end

    def is_value_valid(self, val):
        upper = 1 << (self.end - self.start)
        return val >= 0 and val < upper
    
class SubParam(PositionalParameter):
    def __init__(self, start: int, end: int, name: str, description: str = "", param_type="REGISTER"):
        super().__init__(start, end, name, description, param_type)

class LParam(PositionalParameter):
    def __init__(self, start: int, end: int, name: str, description: str = "", param_type="REGISTER"):
        super().__init__(start, end, name, description, param_type)

class NextWordParam(Parameter):
    def __init__(self, name: str, description: str = "", param_type="NUM_EXPR"):
        super().__init__(name, description, param_type)
    
    def is_value_valid(self, val):
        # TODO(support negative numbers)         
        upper = 1 << 16
        return val >= 0 and val < upper

        