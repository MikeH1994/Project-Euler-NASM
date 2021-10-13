; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 problem_03.asm && ld problem_03.o && ./a.out && rm problem_03.o && rm a.out
; ----------------------------------------------------------------------------------------

;Problem description:
;The prime factors of 13195 are 5, 7, 13 and 29.
;What is the largest prime factor of the number 600851475143?


;General outline
;Any number can be expressed as the product of prime numbers,
;e.g. 156 can be expressed as 2x2x3x13.
;Starting from k = 2, loop through every number and see n is evenly divisible by k.
;If it is, divide n by k and reset k to 2.
;Otherwise, increment k and keep going until n == k.
;As we are checking divisors from the smallest up, the last divisor will be the biggest.
;
;uint lpf(uint n){
;    uint k = 2;
;    while(k<n){
;        if (n%k==0){
;            n/=k;
;            k=2;
;        }
;        else{
;            k++;
;        }    
;    }
;    return k
;}

%include "../utils.asm"

;uint largestPrimeFactor(rax = uint n)
;returns the largest prime factor for n.
largestPrimeFactor:
                    ;rax will be used for arithmetic
                    ;rdi will store the current n
                    ;rsi will store the current k
                    ;rdx will store the remainder on division 
    push rdi
    push rsi
    push rdx
    mov rdi, rax    ;rdi = n
    mov rsi, 2      ;start with k = 2 (lowest prime number)
.mainLoop:
    cmp rsi,rdi
    jge .finished   ;if (k>=n), exit 
    mov rax, rdi    ;rax = n
    mov rdx,0       ;clear remainder 
    div rsi         ;rax = n/k
    cmp rdx,0
    je .divisible   ;if n%k==0 jmp to .divisible
    inc rsi         ;k++ 
    jmp .mainLoop
.divisible:
    mov rdi,rax ;use new value of n = n/k
    mov rsi,2   ;reset rsi back to k=2
    jmp .mainLoop
.finished:
    mov rax,rsi ;current k value is largest prime factor- move to rax for return
    pop rdx
    pop rsi
    pop rdi
    ret
     
problem_3:
    mov rax,msg_1           ;set rax to point to message
    call print_str          ;print "... largest prime factor for 13195 is: "
    mov rax,13195           ;set the number we want to find LPF for
    call largestPrimeFactor ;LPF now in rax
    call print_uint_LF      ;print answer for hint
    mov rax,msg_2           ;set rax to point to message 
    call print_str          ;print "... largest prime factor for 600851475143 is  : "
    mov rax,600851475143    ;set the number we want to find LPF for
    call largestPrimeFactor ;LPF now in rax
    call print_uint_LF      ;print answer for problem 3
    ret
    
global    _start

section   .text

_start:
    call problem_3
    call exit
    
section   .data
    msg_1  db  "Problem 3- largest prime factor for 13195 is         : ",0h
    msg_2  db  "Problem 3- largest prime factor for 600851475143 is  : ",0h



