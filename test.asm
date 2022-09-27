noop; this is a comment
noop;
noop;
test: mov $r0 $r1;
mov $r0 $r2;
addi $r1 $r1 10;
; comment

test2: jmp test2+6;
loop:
   addi $r2 $r2 0b11;
   subi $r1 $r1 1;
   jez $r1 end_loop;
   jmp loop;
end_loop:
rsr $s0 $r7;
addi $r7 $r7 4;
jez $r0 $r7;
st $r2 stack;
halt;
msg_len: dw 6;
msg: db 'Hello\n';
stack: