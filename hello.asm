text:
    ld $r1 msg_len;
    ldw $r2 msg;
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
; Prints out value in the $r3 to the console
; overwrites $r5, $r7
; jumps back to $r6 will do a stack at some point    
print:
    full: addi $r0 $r7 8;
    rsr $s1 $r5;
    and $r7 $r5 $r5;
    jez $r5 empty;
    jmp full;
    empty: wsr $s2 $r3;
    jmp $r6;




data:
msg_len: DW 17;
msg: DB 'Hello World😀!\n';
stack:
