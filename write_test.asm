text:
    ; copy this overflo
    ld $r1 msg_len;
    st $r1 stack;
    ldw $r2 msg;
    ldw $r4 stack + 2;
    loop1:
        jez $r1 end_loop1;
        ldrb $r2 $r0 $r3;
        strb $r4 $r0 $r3;
        subi $r1 $r1 1;
        addi $r2 $r2 1;
        addi $r4 $r4 1;
        jmp loop1;
    end_loop1:
    ld $r1 stack;
    ldw $r2 stack + 2;
    loop:
        jez $r1 end_loop;
        ldrb $r2 $r0 $r3;
        ldw $r6 s1s1;
        jmp print;
        s1s1: subi $r1 $r1 1;
        addi $r2 $r2 1;
        jmp loop;
    end_loop:
    halt;
print:
    full: addi $r0 $r7 8;
    rsr $s1 $r5;
    and $r7 $r5 $r5;
    jez $r5 empty;
    jmp full;
    empty: wsr $s2 $r3;
    jmp $r6;

data:
msg_len: DW 10;
msg: DB 'This is a\n';
stack:
