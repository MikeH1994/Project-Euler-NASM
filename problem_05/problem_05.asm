; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 problem_05.asm && ld problem_05.o && ./a.out && rm problem_05.o && rm a.out
; ----------------------------------------------------------------------------------------

;Problem description: 
;2520 is the smallest number that can be divided by each of the numbers from 1 to 10 without any remainder.
;What is the smallest positive number that is evenly divisible by all of the numbers from 1 to 20?

;General outline:
;The number n is be divisible by 2,3,4,...,20
;As there are no common factors between prime numbers, the number n must be a multiple of the product of all
;the prime numbers between 1 and 20.
;Starting with the number k_0 = 2*3*5*7*..*19 = k, check if k is divisible by every number between 1 and 20.
;If it isn't, k+=k_0 and check again. This should reduce the number of numbers to check substantially.

;rough solution:
;uint calculateProductOfSums(uint nPrimes,std::vector<uint> list_of_primes){
;    uint k = 1;
;    for(uint i = 0; i<nPrimes; i++){
;        k*=list_of_primes[i];
;    }
;    return k;
;}
;


%include "../utils.asm"

;uint productOfFirstNPrimes(rax = nPrimes)
;calculate the produce of the first n primes.
productOfFirstNPrimes:
    ;rax will be used for arithmetic
    ;rdi will be used for the index counter
    ;rsi will be used to store nPrimes
    ;rdx will be used to store current prime
    push rdi
    push rsi
    push rdx
    mov rsi,rax                ;rsi = nPrimes
    mov rdi,0                  ;current index
    mov rax,1                  ;rax = product = 1 
    jmp .mainLoop                  
.mainLoop:
    cmp rdi,rsi
    jge .finished              ;if index>=nPrimes, exit
    mov rdx,[prime_arr + rdi*8];rdx = prime_arr[index]
    mul rdx                    ;rax*= prime_arr[index]
    inc rdi
    jmp .mainLoop
.finished:
    pop rdx
    pop rsi
    pop rdi
    ret

;uint problem_5(rax = uint n_upTo, rdi = uint nPrimes)
;returns the smallest number that can be divided by each of the numbers from 
;1 to n_upTo without any remainder.
problem_5:    
    ;rax will be used for arithmetic
    ;rdi will store the counter i that goes from 1 to n_upTo
    ;rsi will store n_upTo
    ;rdx will be used for remainder
    ;r10 will store the product of all primes between 1 and n_upTo, k_0
    push rdi                      ;preserve values on stack
    push rsi    
    push rdx
    push r10
    
    mov rsi,rax                   ;rsi = n_upTo
    mov rax,rdi                   ;rax = nPrimes
    call productOfFirstNPrimes    ;rax = k_0
    mov r10,rax                   ;r10 = k_0
    mov rdi,2                     ;rdi = 2
.mainLoop:
    cmp rdi,rsi
    jg .finished                  ;if we got up to rdi > n_upTo, we have found n
    push rax                      ;preserve the current value of k for later
    mov rdx,0                     ;clear remainder 
    div rdi                       ;k/=i
    pop rax                       ;restore rax = k
    cmp rdx,0                     
    jne .notEqual                 ;if k%i!=0, jmp to .notEqual  
    inc rdi
    jmp .mainLoop
.notEqual:
    add rax,r10                   ;k+=k_0
    mov rdi,2                     ;reset the counter
    jmp .mainLoop
.finished:
    pop r10
    pop rdx
    pop rsi
    pop rdi
    ret
    
global    _start

section   .text
_start:
    
    ;compute hint and print out
    mov rax,msg_1
    call print_str
    mov rax,10
    mov rdi,n_primes_up_to_10
    call problem_5
    call print_uint_LF
    ;compute solution
    mov rax,msg_2
    call print_str
    mov rax,20
    mov rdi,n_primes_up_to_20
    call problem_5
    call print_uint_LF
    call exit
    
section   .data

msg_1     db  "Problem 5: Smallest number that can be divided by 1 to 10 is:",0h
msg_2     db  "           Smallest number that can be divided by 1 to 20 is:",0h

n_primes_up_to_10 equ 4
n_primes_up_to_20 equ 8
prime_arr   dq 2, 3, 5, 7, 11, 13, 17, 19
