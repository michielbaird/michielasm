 #! /usr/local/env bash

ghdl compile  --ieee=synopsys *.vhd -r  $1 --vcd=$1.vcd --max-stack-alloc=0 --stop-time=700us