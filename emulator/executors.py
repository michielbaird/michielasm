from specification import InstructionType
from specification.double import JEZ, NOT, RSR, WSR
from specification.double_immediate import AddI, SubI
from specification.instruction_type import BIT_WIDTH
from specification.single_consumer import LD, LDW, ST, STB
from specification.single_immediate import LDI, LDIB, STI, STIB
from specification.triple_param import LDRB, LDR, STR, STRB
from .system import System

class CommandExecutor:
    def execute(self, instruction: InstructionType, system: System):
        raise NotImplementedError

class AddIExecutor(CommandExecutor):
    def execute(self, instruction: AddI, system: System):
        source_id = instruction.get_arg("source")
        target_id = instruction.get_arg("target")
        value = system.registers[source_id].val + instruction.get_arg("value")
        mask = (1 << BIT_WIDTH) - 1
        if value > mask:
            system.overflow_flag.set()
        system.registers[target_id].val = value & mask


class SubIExecutor(CommandExecutor):
    def execute(self, instruction: SubI, system: System):
        source_id = instruction.get_arg("source")
        target_id = instruction.get_arg("target")
        value = system.registers[source_id].val - instruction.get_arg("value")
        mask = (1 << BIT_WIDTH) - 1
        # TODO(underflow)
        system.registers[target_id].val = value & mask

class JezExecutor(CommandExecutor):
    def execute(self, instruction: JEZ, system: System):
        chk_id = instruction.get_arg("check_register")
        if system.registers[chk_id].val != 0:
            return
        addr_id = instruction.get_arg("address_register")
        address = system.registers[addr_id].val
        system.PC.val = address

class NotExecutor(CommandExecutor):
    def execute(self, instruction: NOT, system: System):
        source_id = instruction.get_arg("source_register")
        target_id = instruction.get_arg("target_register")
        mask = 1 << BIT_WIDTH
        result = system.registers[source_id].val ^ mask
        system.registers[target_id].val = result

class RSRExecutor(CommandExecutor):
    def execute(self, instruction: RSR, system: System):
        special_id = instruction.get_arg("special_register")
        target_id = instruction.get_arg("target_register")
        system.registers[target_id].val = system.special[special_id].val

class WSRExecutor(CommandExecutor):
    def execute(self, instruction: WSR, system: System):
        special_id = instruction.get_arg("special_register")
        source_id = instruction.get_arg("source_register")
        system.special[special_id].val = system.registers[source_id].val

class LDExecutor(CommandExecutor):
    def execute(self, instruction: LD, system: System):
        target_id = instruction.get_arg("target")
        address = instruction.get_arg("address")
        lsb, msb = system.memory.read_word(address)
        system.registers[target_id].val = (msb << 8) | lsb

class STExecutor(CommandExecutor):
    def execute(self, instruction: ST, system: System):
        source_id = instruction.get_arg("source")
        address = instruction.get_arg("address")

        value = system.registers[source_id].val       
        system.memory.write_word(address, (value >> 8) & 0xff, value & 0xff)

class LDWExecutor(CommandExecutor):
    def execute(self, instruction: LDW, system: System):
        target_id = instruction.get_arg("target")
        value = instruction.get_arg("value")
        system.registers[target_id].val = value

class STBExecutor(CommandExecutor):
    def execute(self, instruction: STB, system: System):
        source_id = instruction.get_arg("source")
        address = instruction.get_arg("address")

        value = system.registers[source_id].val       
        system.memory.write_byte(address, value & 0xff)


class LDIExecutor(CommandExecutor):
    def execute(self, instruction: LDI, system: System):
        target_id = instruction.get_arg("target")
        value = instruction.get_arg("value")
        system.registers[target_id].val = value

class STIExecutor(CommandExecutor):
    def execute(self, instruction: STI, system: System):
        address_id = instruction.get_arg("address_register")
        value = instruction.get_arg("value")
        address = system.registers[address_id].val
        system.memory.write_word(address, (value >> 8) & 0xff, value & 0xff)

class LDIBExecutor(CommandExecutor):
    def execute(self, instruction: LDIB, system: System):
        target_id = instruction.get_arg("target")
        value = instruction.get_arg("value")
        system.registers[target_id].val = value & 0xff

class STBIExecutor(CommandExecutor):
    def execute(self, instruction: STIB, system: System):
        address_id = instruction.get_arg("address_register")
        value = instruction.get_arg("value")
        address = system.registers[address_id].val
        system.memory.write_byte(address, value & 0xff)

class LDRExecutor(CommandExecutor):
    def execute(self, instruction: LDR, system: System):
        addr_id = instruction.get_arg("address_register")
        offset_id = instruction.get_arg("offset_register")
        target_id = instruction.get_arg("target_register")
        address = system.registers[addr_id].val
        offset = system.registers[offset_id].val
        lsb, msb = system.memory.read_word(address + offset)
        system.registers[target_id].val = (msb << 8) | lsb 

class STRExecutor(CommandExecutor):
    def execute(self, instruction: STR, system: System):
        addr_id = instruction.get_arg("address_register")
        offset_id = instruction.get_arg("offset_register")
        value_id = instruction.get_arg("value_register")
        address = system.registers[addr_id].val
        offset = system.registers[offset_id].val
        value = system.registers[value_id].val
        system.memory.write_word(address + offset, (value >> 8) & 0xff, value & 0xff)

class LDRBExecutor(CommandExecutor):
    def execute(self, instruction: LDRB, system: System):
        addr_id = instruction.get_arg("address_register")
        offset_id = instruction.get_arg("offset_register")
        target_id = instruction.get_arg("target_register")
        address = system.registers[addr_id].val
        offset = system.registers[offset_id].val
        value = system.memory.read_byte(address + offset)
        system.registers[target_id].val = value 

class STRBExecutor(CommandExecutor):
    def execute(self, instruction: STRB, system: System):
        addr_id = instruction.get_arg("address_register")
        offset_id = instruction.get_arg("offset_register")
        value_id = instruction.get_arg("value_register")
        address = system.registers[addr_id].val
        offset = system.registers[offset_id].val
        value = system.registers[value_id].val
        system.memory.write_byte(address + offset, value & 0xff)        