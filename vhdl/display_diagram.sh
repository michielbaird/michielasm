 #! /usr/local/env bash

echo $1
yosys -m ghdl -p "ghdl --ieee=synopsys --latches $1 -e; show"
