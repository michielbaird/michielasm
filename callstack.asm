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
    ldw $r6 stack       ; <d084> <02bb>
    ldi $r1 2           ; <2022>
    str $r6 $r1 $r6     ; <d898>
    add $r1 $r6 $r6     ; <d8b0>
; sp 0
; ra 0 - offset 2
; ra 0 - offset 4
; int result =  - offset 6
; int div       - offset 8
; int mod       - offset 10
; frame_size = 12
    addi $r6 $r7 6      ; -- Result address <f831>
    ldi $r1 (12 + 4)    ; <2120>
    str $r6 $r1 $r7     ; <dc98>
    ldw $r7 get_result  ; <f084> <002e>
    ldi $r1 (12 + 2)    ; <20e2>
    str $r6 $r1 $r7     ; <98dc>
    ldw $r7  input      ; <f084> <02ac> --input
    ldr $r7 $r0 $r7     ; <fc08>
    ldi $r1 (12 + 6)    ; <2122>
    str $r6 $r1 $r7     ; <dc98>
    ldi $r1 12          ; <02c2>
    str $r6 $r1 $r6     ; <d898>
    addi $r6 $r6 12     ; <d861>
    jmp fib             ; <f084> <007e> <1c04>
    get_result:

    ldw $r1 mn_pre      ; <3084> <0046>
    ldi $r7 12 + 2      ; <e0e2>
    str $r6 $r7 $r1     ; <c798>
    ldw $r1 prefix_ptr  ; <3084> <02ae>
    ldi $r7 12          ; <e0c2>
    str $r6 $r7 $r6     ; <db98>
    addi $r6 $r6 12     ; <d861>
    jmp print_array     ; <f084> <027a> <1c04>
    mn_pre:


    ldi $r7 12 + 2      ; <e0e2>
    ldw $r2 end_main    ; <5084> <0062>
    str $r6 $r7 $r2     ; <cb98> 
    ldi $r7 6           ; <e062>
    ldr $r6 $r7 $r1     ; <c788>
    ldi $r7 12 + 6      ; <e122>
    str $r6 $r7 $r1     ; <c798>
    ldi $r7 12          ; <e0c2>
    str $r6 $r7 $r6     ; <db98>
    addi $r6 $r6 12     ; <db61>
    jmp print_number    ; <f084> <01ee> <1c04>
    end_main:

    ldw $r1 mn_suf      ; <3084> <007a>
    ldi $r7 12 + 2      ; <e0e2> <c798>
    str $r6 $r7 $r1     ; <3084>
    ldw $r1 suffix_ptr  ; 
    ldi $r7 12;
    str $r6 $r7 $r6;
    addi $r6 $r6 12;
    jmp print_array;
    mn_suf:

    

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
    ldi $r1 6       ; <2062>
    ldr $r6 $r1 $r2 ; <c888>
    ldi $r1 3       ; <2032>
    lt $r2 $r1 $r1  ; <2548>
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
        ldi $r7 2;
        and $r5 $r7 $r5;
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
    str $r7 $r0 $r0; 
    addi $r7 $r7 2;
    str $r7 $r0 $r1; 


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

; Register func
; $r1 = address of message
rev_vec:
    ldr $r1 $r0 $r2; len;
    addi $r1 $r3 2;  START
    add $r3 $r2 $r4;
    subi $r4 $r4 1; end
    rv_loop:
        lt $r3 $r4 $r5;
        jez $r5 rv_next;
        jmp end_rv_loop;
        rv_next: ldrb $r3 $r0 $r1;
        ldrb $r4 $r0 $r2;
        strb $r3 $r0 $r2;
        strb $r4 $r0 $r1;
        addi $r3 $r3 1;
        subi $r4 $r4 1;
        jmp rv_loop;
    end_rv_loop:
    ldi $r7 2;
    ldr $r6 $r7 $r7;
    ldr $r6 $r0 $r6;
    jez $r0 $r7;

; - ret - offset 2
; - res - offset 4 -- Not used
; n/div - offset 6
; mod  - offset 8
; start of tmp array - offset 10
; start of raw_temp  - offset 12
; Frame Length = 22
print_number:
    ldi $r7 10;
    str $r6 $r7 $r0;
    
    pn_loop:
        ldw $r1 pn_edm;
        ldi $r7 22 + 2;
        str $r6 $r7 $r1;
        addi $r6 $r1 6;
        ldi $r7 22 + 4;
        str $r6 $r7 $r1;
        ldi $r7 6;
        ldr $r6 $r7 $r1;
        ldi $r7 22 + 6;
        str $r6 $r7 $r1;
        ldi $r1 10;
        ldi $r7 22 + 8;
        str $r6 $r7 $r1;
        ldi $r7 22;
        str $r6 $r7 $r6;
        addi $r6 $r6 22;
        jmp divmod;
        pn_edm: ldw $r1 pn_eaa;
        ldi $r7 22 + 2;
        str $r6 $r7 $r1; 
        ldi $r7 8;
        ldr $r6 $r7 $r2; Maybe add it here?
        addi $r2 $r2 48; 
        addi $r6 $r1 10;
        ldi $r7 22;
        str $r6 $r7 $r6;
        addi $r6 $r6 22;
        jmp add_to_vec;
        pn_eaa: ldi $r7 6;
        ldr $r6 $r7 $r1;
        jez $r1 pn_endloop;
        jmp pn_loop;
    pn_endloop:
    ; Reverse
    ldw $r1 pn_er;
    ldi $r7 22 + 2;
    str $r6 $r7 $r1;
    addi $r6 $r1 10;
    ldi $r7 22;
    str $r6 $r7 $r6;
    addi $r6 $r6 22;
    jmp rev_vec;

    pn_er:
    ldw $r1 pn_pp;
    ldi $r7 22 + 2;
    str $r6 $r7 $r1;
    addi $r6 $r1 10;
    ldi $r7 22;
    str $r6 $r7 $r6;
    addi $r6 $r6 22;
    jmp print_array;
    pn_pp:
    
    
    ldi $r7 2;
    ldr $r6 $r7 $r7;
    ldr $r6 $r0 $r6;
    jez $r0 $r7;

;
; $r1 msg_start
;
print_array:
    ldr $r1 $r0 $r2;
    addi $r1 $r1 2;
    pa_loop:
        jez $r2 end_pa_loop;
        ldrb $r1 $r0 $r3;
        pa_full: ldi $r7 8;
        rsr $s1 $r5;
        and $r7 $r5 $r5;
        jez $r5 pa_empty;
        jmp pa_full;
        pa_empty: wsr $s2 $r3;
        subi $r2 $r2 1;
        addi $r1 $r1 1;
        jmp pa_loop;
    end_pa_loop:
    
    ldi $r7 2;
    ldr $r6 $r7 $r7;
    ldr $r6 $r0 $r6;
    jez $r0 $r7;


data:
input: dw 24;
prefix_ptr: dw 8;
prefix_raw: db 'Result: ';
suffix_ptr: dw 2;
suffix_raw: db '\n\r';


stack:
