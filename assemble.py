#! /usr/bin/env python3
from argparse import ArgumentParser
from assembler.core import parse_and_encode

def run(input_file, output_file):
    with open(input_file, "r") as f:
        raw_program = f.read()
    program = parse_and_encode(raw_program)
    with open(output_file, "wb") as f:
        f.write(program)



def main():
    parser = ArgumentParser("Michiel ASM Assembler")
    parser.add_argument("input_file")
    parser.add_argument("--out", default="a.out")
    args = parser.parse_args()
    run(args.input_file, args.out)
    
if __name__ == "__main__":
    main()