from parsimonious.grammar import Grammar
from assembler.asm_visitor import AsmVisitor
from specification.instruction_type import InstructionType, all_leaf_commands

from specification.param import PositionalParameter, SubParam

BASE_GRAMMAR = r"""
PROGRAM = LINE*
LINE = SEP? ((STATEMENT COMMENT?) / LABEL / "") ("\n" / ~"$")
STATEMENT = ((LABEL SEP? COMMAND) / COMMAND?) SEP? ";"

{command}
MOV = ~"mov"i SEP REGISTER SEP REGISTER
NOOP = ~"noop"i
HALT = ~"halt"i
JMP = ~"jmp"i SEP ADDR_OR_REG
DATA = DB / DW / DD / DQ
DB = ~"DB"i SEP DATA_EXPR
DW = ~"DW"i SEP DATA_EXPR
DD = ~"DD"i SEP DATA_EXPR
DQ = ~"DQ"i SEP DATA_EXPR
DATA_EXPR = DEX (SEP? "," SEP? DEX)* 

DEX = NUM_EXPR / STRING
STRING = ~"'((:?\\\'|[^\'])*?)'"

{details}

ADDR_OR_REG = ADDRESS_EXPR / REGISTER
ADDRESS_EXPR = (LABEL_IDENT PLUSMINUS NUM_EXPR) / (NUM_EXPR PLUSMINUS LABEL_IDENT) / NUM_EXPR / LABEL_IDENT
NUM_EXPR = PRODUCT (PLUSMINUS PRODUCT)*
PRODUCT = VALUE (MUL VALUE)*
VALUE = NUM / ( "(" NUM_EXPR ")" )


PLUSMINUS = SEP? ("+"/"-") SEP?
MUL = SEP? "*" SEP?
NUM =  HEXADECIMAL / BINARY / DECIMAL
DECIMAL = ("0" / ~"[1-9]\d*")
HEXADECIMAL = ~"0x[\dabcdef]+"
BINARY = ~"0b[01]+" 
REGISTER  = ~"\$r[0-7]"i
SPECIAL_REGISTER = ~"\$s[0-7]"i
SEP = ~"\s+"
LABEL = LABEL_IDENT ":"
LABEL_IDENT = ~"[\w][\w\d]+"i
COMMENT = ~".*"
"""

def collect_commands(instruction):
    commands = all_leaf_commands()
    grammars = []
    top = ["COMMAND = MOV / NOOP / JMP / HALT / DATA"]
    for cmd in commands:
        name = cmd.cmd_name()
        top.append(name.upper())
        gmr = ["{} = ~\"{}\"i".format(name.upper(), name.lower())]
        fmt = cmd.format()
        for p in filter(lambda x: not isinstance(x, SubParam) or fmt[x.start] == "?" ,  cmd.params_def()):
            gmr.append(" SEP {}".format(p.param_type))
        grammars.append("".join(gmr))
    return "\n".join(grammars), " / ".join(top)

details, names = collect_commands(InstructionType)


grammar = Grammar(
    BASE_GRAMMAR.format(
        command=names,
        details=details
    ))


def parse_and_encode(raw_program):
    tree = grammar.parse(raw_program)
    visitor = AsmVisitor()
    return visitor.visit(tree)




__all__ = [parse_and_encode]