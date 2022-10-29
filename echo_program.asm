text:
ldi $r3 16;
ldi $r4 8;
loop:
    rsr $s1 $r2;
    and $r2 $r3 $r2;
    jez $r2 loop;
    rsr $s2 $r1;
    loop2:
        rsr $s1 $r2;
        and $r2 $r4 $r2;
        jez $r2 end_loop_2;
        jmp loop2;
    end_loop_2:
    wsr $s2 $r1;
    jmp loop; 

data:

stack: