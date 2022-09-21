noop; this is a comment
noop;
noop;
test: mov $r0 $r1;
mov $r0 $r2;
addi $r1 256;
; comment
loop:
   addi $r2 1;
   subi $r1 1;
   jez $r1 end_loop;
   jmp loop;
end_loop:
st $r2 memory+1;
halt;


memory:
