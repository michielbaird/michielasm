import argparse
from email import parser

def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("in_file")
    parser.add_argument("out_file")
    args = parser.parse_args()
    with open(args.in_file, "rb") as in_f:
        contents = in_f.read()
        
    with open(args.out_file, "w") as out_f:
        for b in contents:
            out_f.write('' + '{}'.format(bin(b)[2:]).rjust(8,"0") + '\n')


if __name__ == "__main__":
    main()