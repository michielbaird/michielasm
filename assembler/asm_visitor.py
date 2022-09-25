from parsimonious import NodeVisitor
from parsimonious.nodes import Node
from typing import Sequence, Any, Union
from .models import *
from .simplifier_map import *

from specification.instruction_type import leaf_command_dict


class AsmVisitor(NodeVisitor):
    def __init__(self) -> None:
        super().__init__()
        self.labels = {}
    
    def visit_DECIMAL(self, node, _) -> int:
        return int(node.text)
    
    def visit_HEXADECIMAL(self, node, _) -> int:
        return int(node.text[2:], 16)

    def visit_BINARY(self, node, _) -> int:
        return int(node.text[2:], 2)

    def visit_VALUE(self, node, visited_children) -> int:
        if isinstance(visited_children[0], int) :
            return visited_children[0]
        else:
            return visited_children[0][1][1]

    def visit_REGISTER(self, node, visited_children) -> Register:
        return Register(int(node.text[2:]))
    
    def visit_SPECIAL_REGISTER(self, node, vistited_children):
        return SpecialRegister(int(node.text[2:]))
    
    def visit_ADDRESS_EXPR(self, node, visited_children) -> Address:
        if isinstance(visited_children[0], int):
            return Address(label=None, offset=visited_children[0])
        elif isinstance(visited_children[0], str):
            return Address(label=visited_children[0])
        match visited_children[0][1]:                
            case str(lbl), str(op), int(val):
                if op == "-": 
                    val *= -1
                return Address(lbl, val)
            case int(val), str(op), str(lbl):
                return Address(lbl, val)
            case _:
                raise RuntimeError("Should be unreachable")
    
    def visit_LABEL_IDENT(self, node, visted_children) -> str:
        return node.text
    
    def visit_LABEL(self, node, visited_children) -> Label:
        name = visited_children[0]
        self.labels[name] = -1
        return Label(name)

    def visit_PRODUCT(self, node, visited_children) -> int:
        #print("PRODUCT", len(visited_children), visited_children)
        val = visited_children[0]
        children = visited_children[1][1]
        for  _, rhs in children:
                val *= rhs[1]
        return val
    
    def visit_NUM_EXPR(self, node, visited_children) -> int:
        #print("SUM", visited_children)
        val = visited_children[0]
        children = visited_children[1][1]
        for  _, rhs in children:
            if rhs[0] == "+":
                val += rhs[1]
            else:
                val -= rhs[1]
        return val
    
    def visit_SEP(self, node, visited_children) -> None:
        return None
    
    def visit_PLUSMINUS(self, node, visited_children) -> str:
        return visited_children[1][0].text
    
    def visit_MUL(self, node, visited_children) -> str:
        return "*"
    
    def visit_NUM(self, node, visited_children) -> int:
        return visited_children[0]

    def visit_COMMAND(self, node, visited_children) -> Command:
        expression = visited_children[0][0]
        expr_name = expression.expr_name
        #print(expr_name)
        params = []
        if len(visited_children[0][1]) > 1:
            params = visited_children[0][1][2::2]
        return Command(expr_name, params)
    
    def visit_STATEMENT(self, node, visited_children) -> Statement:
        m = visited_children[0][1][0][1]
        if len(m) == 0:
            return Statement([])
        elif len(m) == 1:
            return Statement([m[0]])
        else:
            return Statement([m[2]], m[0])

    def visit_LINE(self, node, visited_children) -> Statement:
        meat = visited_children[1][1][0]
        match meat:
            case Label(name):
                return Statement([], label=Label(name))
        return meat[1][0]
    
    def visit_PROGRAM(self, node, visited_children) -> bytes:
        program = list(map(expand_aliases, visited_children))
        result = build_binary(program)
        return result

    def visit_ADDR_OR_REG(self, node, visited_children) -> Union[Address, Register]:
        return visited_children[0]
    
    def generic_visit(self, node: Node, visited_children: Sequence[Any]) -> Any:
        #print(type(node))
        return (node, visited_children)

def build_binary(program: Sequence[Statement]) -> bytes:
    cmd_dict = leaf_command_dict()
    label_dict = calculate_labels(program)
    result = []
    for statement in program:
        for cmd in statement.commands:
            cmd_type = cmd_dict[cmd.name]
            args = {}
            for p_t, p in zip(cmd_type.floating_params(), cmd.params):
                match p:
                    case int(v):
                        val = v
                    case Address(label, offset):
                        val = offset
                        if label is not None:
                            val += label_dict[label]
                    case Register(num):
                        val = num
                    case SpecialRegister(num):
                        val = num
                args[p_t.name] = val
            result.append(cmd_type(**args))
    raw_b = b"".join(x.encode() for x in result)
    #print("\n".join(repr(s) for s in result))
    return raw_b
    

def calculate_labels(statements: Sequence[Statement], offset=0) -> dict[str, int]:
    cmd_dict = leaf_command_dict()
    label_dict = {}
    current = offset
    for stmt in statements:
        if stmt.label is not None:
            label_dict[stmt.label.name] = current
        for cmd in stmt.commands:
            current += 2
            if cmd_dict[cmd.name].should_consume_next_word():
                current += 2
    return label_dict
    



