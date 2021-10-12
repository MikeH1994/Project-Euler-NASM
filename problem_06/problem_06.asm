; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 problem_06.asm && ld problem_06.o && ./a.out
; ----------------------------------------------------------------------------------------

;Problem description:
;"The sum of the squares of the first ten natural numbers is
;        1^2 + 2^2 + ... + 10^2 = 385
; The square of the sum of the first ten natural numbers is
;       (1+2+...+10)^2 = 55^2 = 3025
; Hence the difference between the sum of the squares of the first ten natural numbers and the square of the sum is
;       3025 - 385 = 2640
; Find the difference between the sum of the squares of the first one hundred natural numbers and the square of the sum."

; General problem outline:
; uint problem_6(uint n_max){
;     uint sum = n_max/2(1+n_max);
;     uint sqsum = sum*sum
;     uint sumsq = 0; 
;     for(uint i = 0; i<=n_max; i++){ 
;         sumsq+=i*i;
;     }
;     return sumsq;
; }

%include "../utils.asm"

;uint sumsq(rax = int maxVal)
;calculate the sum of the squares of all natural numbers from 1 to maxVal
sumsq:
    ;rax will be used to calculate the square of current value
    ;rdi will be used to store the rolling sum
    ;rsi will be used to store the counter i
    ;r10 will be used to store the max value
    push rdi
    push rsi
    push r10
    
    mov r10,rax    ;move maxVal to r10
    mov rax,0
    mov rdi,0
    mov rsi,0
    
    jmp .mainLoop
.mainLoop:
    inc rsi        ;increment rsi
    cmp rsi,r10    ;compare i to maxVal
    jg .finished   ;if i>maxVal, exit
    mov rax,rsi    ;move i to rax
    mul rsi        ;multiply rax by rsi to get i^2
    add rdi,rax    ;add i^2 to sum
    jmp .mainLoop
.finished:
    mov rax,rdi    ;move the sum to rax to be returned
    pop r10        ;restore registers
    pop rsi
    pop rdi
    ret
    
;uint sumsq(rax = int maxVal)
;calculate the square of the sum of all natural numbers from 1 to maxVal
sqsum:
    ;rax will return the value
    ;rdi will be used to store numbers for multiplication
    ;sum of all numbers between a and l is n/2(a+l).
    ;Here n = l = maxVal, a = 1
    
    push rdi
                     ;rax = n
    mov rdi,rax      ;rdi = n = l
    add rdi,1        ;rdi = 1 + l = (a + l)
    mul rdi          ;rax = n(a+l)
    mov rdi,2
    div rdi          ;rax = n/2(a+l) = sum
    mov rdi,rax      ;rdi = sum
    mul rdi          ;rax = sum^2
    
    pop rdi
    ret

;uint problem_6(rax = uint maxVal)
;
problem_6:
    push rdi
    push rax      ;store the maxVal for later
    call sumsq
    mov rdi,rax   ;rdi = sumsq 
    pop rax
    call sqsum    ;rax = sumsq
    sub rax,rdi   ;rax = sqsum - sumsq
    pop rdi
    ret 

global    _start

section   .text

_start:
    mov rax,msg_1       ;set rax to point to message
    call print_str      ;print "... for first 10 natural numbers is: "
    mov rax,10          ;set number of natural numbers we are calculating over
    call problem_6      ;get the result in rax
    call print_uint_LF  ;print answer for first 10 numbers
    mov rax,msg_2       ;set rax to point to message 
    call print_str      ;print "... for first 100 natural numbers is: "
    mov rax,100         ;set number of natural numbers we are calculating over
    call problem_6      ;get the result in rax
    call print_uint_LF  ;print answer for first 100 numbers
    call exit
    
section   .data
          msg_1  db  "Solution to problem 6 for first 10 natural numbers is  : ",0h
          msg_2  db  "Solution to problem 6 for first 100 natural numbers is : ",0h