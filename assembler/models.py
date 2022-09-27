from dataclasses import dataclass
import struct
from typing import Optional, Sequence, Any, Union
import ast

@dataclass
class Register:
    num: int

@dataclass
class SpecialRegister:
    num: int

@dataclass
class Address:
    label: Optional[str]
    offset: int = 0

@dataclass
class Label:
    name: str

@dataclass
class Command:
    name: str
    params: Sequence[Any] # TODO(fix)

@dataclass
class DataPiece:
    width: str
    args: bytes
    def encode(self):
        return self.args
    @staticmethod
    def fromArgs(t, args):
        r = bytearray()
        match t:
            case "DB":
                n_enc = "<B"
                enc = "utf8"
            case "DW":
                n_enc = "<H"
                enc = "utf16"
            case "DD":
                n_enc = "<I"
                enc = "utf32"
            case "DQ":
                n_enc = "<Q"
                enc = "unknown"
        for arg in args:
            match arg:
                case str(a):
                    if enc == "unknown":
                        raise RuntimeError("Cannot use str for {}", t)
                    b = ast.literal_eval("'" + a + "'") 
                    r.extend(
                        b.encode(enc)
                    )
                case int(v):
                    r.extend(struct.pack(n_enc, v))

        return DataPiece(t, bytes(r))

@dataclass
class Statement:
    commands: Sequence[Command]
    label: Optional[Label] = None