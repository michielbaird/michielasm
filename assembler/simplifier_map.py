import re

EXPAND_MAP = {
    r"^mov (\$r[0-8]) (\$r[0-8])$": ["add {1} $r0 {2}"],
    r"^noop$": ["and $r0 $r0 $r0"],
    r"^jmp (\w[w\d]*)$": [
        "ld $r7 {1}",
        "jez $r0 $r7"
    ],
    r"^jez (\$r[0-8]) (\w[w\d]*)$": [
        "ld $r7 {2}",
        "jez {1} $r7"
    ],
    r"^halt$": [
        "RSR $s0 $r7"
        "jez $r0 $r7"
    ]
}