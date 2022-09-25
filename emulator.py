#! /usr/bin/env python3
from emulator.cpu import CPU
from argparse import ArgumentParser

def main():
    parser = ArgumentParser("Run programs written in MichielAsm")
    parser.add_argument("binary")
    args = parser.parse_args()
    with open(args.binary, "rb") as f:
        raw_b = f.read()

    cpu = CPU()
    cpu.write_blob(0, raw_b)
    cpu.run()

if __name__ == "__main__":
    main()