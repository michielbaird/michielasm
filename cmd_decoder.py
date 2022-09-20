import specification
from collections import namedtuple
from typing import Union

specification.AddI

parse_raw_double_immediate = lambda x: (
                (x>>1) & 0b11,
                (x>>3) & 0b111,
                (x>>6) & 0b111,
                (x>>9) & 0b1111111,
            )  if x&0b1 == 1 else None

RawDoubleImmediate = tuple[int, int, int, int]

# TODO: Redo as classes to help self document
LDR = namedtuple("LDR", ("addr_r", "target_r", "offset"))
STR = namedtuple("STR", ("addr_r", "value_r", "offset"))
ADDI = namedtuple("ADDI", ("source_r", "target_r", "value"))
SUBI = namedtuple("SUBI", ("source_r", "target_r", "value"))

DoubleImmediate = Union[LDR, STR, ADDI, SUBI] 

def resolve_double_immediate(double_immediate: RawDoubleImmediate) -> DoubleImmediate:
    if double_immediate[0] == 0:
        t = LDR
    elif double_immediate[0] == 1:
        t = STR
    elif double_immediate[0] == 2:
        t = ADDI
    else:
        t = SUBI
    t(double_immediate[1], double_immediate[2], double_immediate[3])

parse_raw_single_immediate = lambda x: (
    (x >> 2) & 0b11,
    (x >> 4) & 0b111,
    (x >> 6) & 0b1111111111
) if x & 0b11 == 0b10 else None
RawSingleImmediate = tuple[int, int, int]

LDI = namedtuple("LDI", ("target_register", "value"))
STI = namedtuple("STI", ("address_register", "value"))
LDIB = namedtuple("LDI", ("target_register", "value"))
STIB = namedtuple("STI", ("address_register", "value"))
SingleImmediate = Union[LDI, STI, LDIB, STIB]

def resolve_single_immediate(single_immediate: RawSingleImmediate) -> SingleImmediate:
    if single_immediate[0] == 0:
        t = LDI
    else:
        t = STI
    t(single_immediate[1], single_immediate[2])

RawBinaryOp = tuple[int, int, int, int]
parse_raw_binary_op = lambda x: (
    (x >> 4) & 0b1111,
    (x >> 7) & 0b111,
    (x >> 10) & 0b111,
    (x >> 13) & 0b111,
) if x & 0b1111 == 0 else None

AND = namedtuple("AND", ("register_1", "register_2", "target_register"))
OR = namedtuple("OR", ("register_1", "register_2", "target_register"))
XOR = namedtuple("XOR", ("register_1", "register_2", "target_register"))
ADD = namedtuple("ADD", ("register_1", "register_2", "target_register"))
ADDU = namedtuple("ADDU", ("register_1", "register_2", "target_register"))
SL = namedtuple("SL", ("register_1", "register_2", "target_register"))
SR = namedtuple("SR", ("register_1", "register_2", "target_register"))
SUB = namedtuple("SUB", ("register_1", "register_2", "target_register"))

BinaryOp = Union[AND, OR, XOR, ADD, ADDU, SL, SR, SUB]

def resolve_binary_op(raw_binary_op: RawBinaryOp) -> BinaryOp:
    {
        0: AND,
        1: OR,
        2: XOR,
        3: ADD,
        4: ADDU,
        5: SL,
        6: SR,
        7: SUB,
    }[raw_binary_op[0]](raw_binary_op[1], raw_binary_op[2], raw_binary_op[3])

parse_raw_double = lambda x: (
    (x >> 8) & 0b11,
    (x >> 11) & 0b111,
    (x >> 13) & 0b111,
) if x & ((1 << 8) - 1) == 0b100 else None

RawDouble = tuple[int, int, int]

JEZ = namedtuple("JEZ", ("address_register", "check_register"))
NOT = namedtuple("NOT", ("source_register", "target_register"))
RSR = namedtuple("RSR", ("special_register", "target_register"))
WSR = namedtuple("WSR", ("special_register", "source_register"))

Double = Union[JEZ, NOT, RSR, WSR]

def resolve_double(raw_double: RawDouble) -> Double:
    t = {0: JEZ, 1: NOT, 2: RSR, 3: WSR}[raw_double[0]]
    t(raw_double[1], raw_double[2], raw_double[3])


parse_single_consumer = lambda x, y: (
    (x >> 12) & 0b1,
    (x >> 13) & 0b111,
    y
) if x & 0b1111_1111_1111 == 0b1000_0100 else None

RawSingleConsumer = tuple[int, int, int]

LD = namedtuple("LD", ("targer_register", "address"))
ST = namedtuple("ST", ("source_register", "address"))

SingleConsumer = Union[LD, ST]
def resolve_single_consumer(raw_single_consumer: RawSingleConsumer) -> SingleConsumer:
    if raw_single_consumer[0] == 0:
        t = LD
    else:
        t = ST
    t(raw_single_consumer[1], raw_single_consumer[2])