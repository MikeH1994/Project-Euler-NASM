; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 problem_01.asm && ld problem_01.o && ./a.out && rm problem_01.o && rm a.out
; ----------------------------------------------------------------------------------------

;Problem description:
;"If we list all the natural numbers below 10 that are multiples of 3 or 5,
; we get 3, 5, 6 and 9. The sum of these multiples is 23.
; Find the sum of all the multiples of 3 or 5 below 1000."

;General problem outline (simple solution):
;loop through all the numbers between 1 and 1000. If i%3 ==0 or i%5==0,
;they add them to the current sum- e.g.
;uint32_t endVal = 1000;
;uint32_t sum = 0;
;for(uint32_t i = 0; i<endVal; i++){
;    if (i%3==0 || i%5==0){
;        sum+=i;
;    }
;}

;rax is used for division
;let rdi store the current sum
;let rsi store the current number we are at
;rdx holds the remainder from division
;let r10 store the max number
;let r9 hold divisor (3 or 5)


%include "../utils.asm"

global    _start

section   .text

problem_1:
    mov rax,0
    mov rdi,0
    mov rsi,0
    mov rdx,0
.main_loop:
    inc rsi           ;increment counter
    mov rdx,0         ;clear remainder
    cmp rsi,r10       ;compare current counter to end value
    jge .finished     ;if i>endVal, exit
    mov rax,rsi       ;move current number in to rax, and divide by 3
    mov r9,3
    div r9
    cmp rdx,0         ;if the remainder is zero, it's a multiple
    je .number_is_multiple
    mov rdx,0         ;clear remainder
    mov rax,rsi       ;move number back in to rax and divide by 5
    mov r9,5
    div r9
    cmp rdx,0         ;if the remainder is zero, it's a multiple
    je .number_is_multiple
    jmp .main_loop
.number_is_multiple:
    add rdi,rsi       ;if it's a multiple, add current value to sum
    jmp .main_loop
.finished:
    mov rax,rdi
    ret
_start:
    mov rax,msg_1
    call print_str   
    mov r10,10
    call problem_1
    call print_uint_LF
    mov rax,msg_2
    call print_str   
    mov r10,1000
    call problem_1
    call print_uint_LF
    call exit
    
section   .data
          msg_1  db  "Solution to problem 1 hint (first 10) is : ",0h
          msg_2  db  "Solution to problem 1 (first 1000) is    : ",0h