#! /usr/bin/env python3
from argparse import ArgumentParser
from assembler.core import parse_and_encode

def main():
    parser = ArgumentParser("Michiel ASM Assembler")
    parser.add_argument("input_file")
    parser.add_argument("--out", default="a.out")
    args = parser.parse_args()
    
    with open(args.input_file, "r") as f:
        raw_program = f.read()

    program = parse_and_encode(raw_program)

    with open(args.out, "wb") as f:
        f.write(program)

if __name__ == "__main__":
    main()