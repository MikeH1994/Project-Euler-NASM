; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 run.asm && ld run.o && ./a.out && rm run.o && rm a.out
; ----------------------------------------------------------------------------------------

%include "problem_04.asm"

global    _start

section   .text

problem_4:
    mov rax,msg_1
    call print_str_LF
    
    mov rax,msg_2
    call print_str   
    mov rax,10
    mov rsi,99
    call largestPalidromeFromProduct
    call print_uint_LF    
    
    mov rax,msg_3
    call print_str   
    mov rax,100
    mov rsi,999
    call largestPalidromeFromProduct
    call print_uint_LF    
    ret
_start:
    call problem_4
    call exit

section   .data
          msg_1  db  "Problem 4",0h
          msg_2  db  "Solution to problem 4 hint  is : ",0h
          msg_3  db  "Solution to problem 4 is    : ",0h