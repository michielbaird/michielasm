from .models import *

def expand_aliases(statement: Statement) -> Statement:
    commands = []
    for cmd in statement.commands:
        match cmd:
            case Command("JMP", [Address(address, offset)]):
                commands.append(
                    Command("LDW", [Register(7), Address(address, offset)])
                )
                commands.append(
                    Command("JEZ", [Register(0), Register(7)])
                )
            case Command("JEZ", [Register(r), Address(addr, offset)]):
                commands.append(
                    Command("LDW", [Register(7), Address(addr, offset)])
                )
                commands.append(
                    Command("JEZ", [Register(r), Register(7)])
                )
            case Command("NOOP", []):
                commands.append(Command("AND", [Register(0), Register(0), Register(0)]))
            case Command("HALT", []):
                commands.append(Command("RSR", [SpecialRegister(0), Register(7)]))
                commands.append(Command("JEZ", [Register(0), Register(7)]))
            # TODO(make mov more interesting)
            case Command("MOV", [Register(r1), Register(r2)]):
                commands.append(Command("OR", [Register(r1), Register(0), Register(r2)]))
            case _:
                commands.append(cmd)
    return Statement(commands, statement.label)