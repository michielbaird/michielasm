 #! /usr/local/env bash

ghdl compile --ieee=synopsys *.vhd -r $1 --vcd=$1.vcd