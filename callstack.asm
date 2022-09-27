; 
; $r6 will be our stack pointer :)
; $r7 is used by the compiler
; Caller should preserve registers on stack
;
;  +--------------------+
;  | Stack pointer      |
;  +--------------------+
;  | Return Address     | - the address the program should jump to when complete
;  +--------------------+
;  | result address     |
;  +--------------------+
;  | arg                | Defined by the Caller
;  +--------------------+
;            :
;  +--------------------+
;  | end of local vars  |
;  +--------------------+
;                         <--- end of frame

   
main:
    ldw $r6 stack       ;
    ldi $r1 2           ;
    str $r6 $r1 $r6     ;
    add $r1 $r6 $r6     ;
; sp 0
; ra 0 - offset 2
; ra 0 - offset 4
; int result =  - offset 6
; int div       - offset 8
; int mod       - offset 10
; frame_size = 12
    addi $r6 $r7 6      ; -- Result address
    ldi $r1 (12 + 4)     ;
    str $r6 $r1 $r7     ;
    ldw $r7 get_result  ;
    ldi $r1 (12 + 2)     ;
    str $r6 $r1 $r7     ;
    ldw $r7  input      ; --input
    ldr $r7 $r0 $r7     ;
    ldi $r1 (12 + 6)     ;
    str $r6 $r1 $r7     ;
    ldi $r1 12          ;
    str $r6 $r1 $r6     ;
    addi $r6 $r6 12     ; 
    jmp fib             ;
    get_result:
    ldi $r7 8           ;
    str $r6 $r7 $r0     ;
    addi $r7 $r7 2      ;
    str $r6 $r7 $r0     ;
    ldw $r7 ddone       ;
    ldi $r1 12 + 2      ;
    str $r6 $r1 $r7     ;
    ldi $r7 8           ;
    add $r6 $r7 $r7     ;
    ldi $r1 12 + 4      ;
    str $r6 $r1 $r7     ;
    ldi $r7 6           ;
    ;ldw $r7 1234       ;
    ldr $r6 $r7 $r7     ;
    ldi $r1 12 + 6      ;
    str $r6 $r1 $r7     ;
    ldi $r7 10          ;
    ldi $r1 12 + 8      ;
    str $r6 $r1 $r7     ;
    ldi $r1 12          ;
    str $r6 $r1 $r6     ;
    addi $r6 $r6 12     ;
    jmp divmod          ;
    ddone:
    ldi $r7 6           ;
    ldr $r6 $r7 $r1     ;
    ldi $r7 8           ;
    ldr $r6 $r7 $r2     ;
    ldi $r7 10          ;
    ldr $r6 $r7 $r3     ;   

    halt;

; fn fib(n: int) -> {
;    if n < 2 {
;       return 1;
;    }    
;    let prev: int = fib(n - 1);
;    let pprev: int = fib(n - 2);
;    return prev + pprev
; }
; Frame:
;   - sp
;   - return address = 2
;   - result address = 2
;   - int n == 2
;   - int prev == 2
;   - int pprev == 2
; -- 12 bytes
; Will preserve as much as posible even though I don't need to
; $r1 offset register (not preserved)
; $r2 n
; $r3 -- result
; $r4 -- f(n-1)
; $r5 -- f(n - 2)
; $r6 stack pointer 
; $r7 scratch (not preserved)

fib:
    ldi $r1 6;
    ldr $r6 $r1 $r2;
    ldi $r1 2;
    lt $r2 $r1 $r1;
    ldi $r3 1;
    jez $r1 fib_final;
    ; Preserve registers
    ldi $r1 12;
    str $r6 $r1 $r2;
    ldi $r1 14;
    str $r6 $r1 $r3;
    ldi $r1 16;
    str $r6 $r1 $r4;
    ldi $r1 18;
    str $r6 $r1 $r5;
    ; Set up next frame
    subi $r2 $r2 1      ; -- Param
    ldi $r1 26          ;
    str $r6 $r1 $r2     ; -- store n-1 on callstack as param
    ldi $r1 24          ;
    addi $r6 $r2 8      ; result address
    str $r6 $r1 $r2     ;
    ldi $r1 22;         ;
    ldw $r7 fibn1_done  ;
    str $r6 $r1 $r7     ;
    ldi $r1 20          ;
    str $r6 $r1 $r6     ;
    addi $r6 $r6 20     ; 
    jmp fib             ;
    fibn1_done:
    ldi $r1 12          ; Setup call to fib(n-2)
    ldr $r6 $r1 $r2     ;
    subi $r2 $r2 2      ;
    ldi $r1 26          ;
    str $r6 $r1 $r2     ; -- store n-2 on callstack as param
    ldi $r1 24          ;
    addi $r6 $r2 10     ; result address
    str $r6 $r1 $r2     ;
    ldi $r1 22;         ;
    ldw $r7 fibn2_done  ;
    str $r6 $r1 $r7     ;
    ldi $r1 20          ;
    str $r6 $r1 $r6     ;
    addi $r6 $r6 20     ;
    jmp fib             ;
    fibn2_done:
    ; Restore registers ;
    ldi $r1 12          ;
    ldr $r6 $r1 $r2     ;
    ldi $r1 14          ;
    ldr $r6 $r1 $r3     ;
    ldi $r1 16          ;
    ldr $r6 $r1 $r4     ;
    ldi $r1 18          ;
    ldr $r6 $r1 $r5     ;
    ; Load up results   ;
    ldi $r1 8           ;
    ldr $r6 $r1 $r4     ;
    ldi $r1 10          ;
    ldr $r6 $r1 $r5     ;
    add $r4 $r5 $r3     ; 
    fib_final: 
    ldi $r7 4;
    ldr $r6 $r7 $r7;
    str $r7 $r0 $r3;
    ldi $r7 2;
    ldr $r6 $r7 $r7;
    ldr $r6 $r0 $r6;
    jmp $r7;

; return address - offset = 2
; result address - address to the START of 4 bytes
;                - the first 2 bytes stores a / b
;                - the second 2 bytes store a % b
;                - offset = 4
; a              - offset = 6
; b              - offset = 8
divmod:
    ldi $r7 6;
    ldr $r6 $r7 $r1;
    ldi $r7 8;
    ldr $r6 $r7 $r2;
    jez $r2 dm_div_zero;

    lt $r1 $r2 $r3;
    jez $r3 dm_base;
    
    ldi $r3 1;
    

    dm_loop1:
        wsr $s1 $r0; 
        ldi $r7 1;
        sl $r2 $r7 $r4;
        ; check overflow
        rsr $s1 $r5;
        jez $r5 dm_no_overflow;
    dm_step2:
        wsr $s1 $r0;
        mov $r0 $r4;
        jmp dm_loop2;
    dm_no_overflow:
        lt $r1 $r4 $r5;
        jez $r5 dm_step2;
        mov $r4 $r2;
        ldi $r7 1;
        sl $r3 $r7 $r3;
        jmp dm_loop1;
    ; $r3 high-bit
    ; $r2 subtractor
    ; $r1 subtractee
    ; $r4 cumlulator
    dm_loop2:
        jez $r3 dm_loop2_end;
        lt $r1 $r2 $r5;
        jez $r5 dm_loop2_s2;
        add $r4 $r3 $r4;
        sub $r1 $r2 $r1;
        dm_loop2_s2:
        ldi $r7 1;
        sr $r3 $r7 $r3;
        sr $r2 $r7 $r2;
        jmp dm_loop2;
    dm_loop2_end:
    ldi $r7 4;
    ldr $r6 $r7 $r7;
    str $r7 $r0 $r4;
    addi $r7 $r7 2;
    str $r7 $r0 $r1;
    jmp dm_return;

    dm_div_zero:
    ldi $r7 4;
    ldr $r6 $r7 $r7;
    ldw $r1 0xffff;
    st $r7 $r1; 
    addi $r7 $r7 2;
    st $r7 $r1;
    jmp dm_return;

    dm_base:
    ldi $r7 4;
    ldr $r6 $r7 $r7;
    st $r7 $r0; 
    addi $r7 $r7 2;
    st $r7 $r1; 


    dm_return:
    ldi $r7 2;
    ldr $r6 $r7 $r7;
    ldr $r6 $r0 $r6;
    jez $r0 $r7; 

; Register func
; $r1 = address of message
; $r2 = character
add_to_vec:
    ldr $r1 $r0 $r3; len;
    addi $r1 $r4 2;
    add $r4 $r3 $r4;
    strb $r4 $r0 $r2;
    addi $r3 $r3 1;
    str $r1 $r0 $r3;

    ldi $r7 2;
    ldr $r6 $r7 $r7;
    ldr $r6 $r0 $r6;
    jez $r0 $r7; 

data:
input: dw 12;
msg_ptr: dw 0;
msg_raw: db 0,0,0,0,0,0,0,0;

stack: