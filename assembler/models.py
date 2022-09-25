from dataclasses import dataclass
from typing import Optional, Sequence, Any

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
class Statement:
    commands: Sequence[Command]
    label: Optional[Label] = None