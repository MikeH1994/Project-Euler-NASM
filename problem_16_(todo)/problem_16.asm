; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 problem_16.asm && ld problem_16.o && ./a.out && rm problem_16.o && rm a.out
; ----------------------------------------------------------------------------------------

;Problem description: 
;215 = 32768 and the sum of its digits is 3 + 2 + 7 + 6 + 8 = 26.
;What is the sum of the digits of the number 2^1000? 

;General outline:
;Define a sufficiently long array. Each element defines the digit
;in the number
;Starting with 2^0 = [0,0,0,0,0,...,1], 
;at each step, starting with the lowest digit, and up to the highest non-zero digit,
;double each digit and carry over where necessary
;
;uint32_t compute(max){
;  uint32_t n=1000;
;  uint32_t maxIndex = 0;
;  uint8_t arr[n];
;  arr[0] = 1;
;  for(uint32_t n_i = 1; n_i<n; n_i++){
;    for(uint32_t i = 0; i<=maxIndex; i++){
;        arr[i]<<1;
;        if (arr[i]>9){
;            uint32_t quotient  = arr[i]/10;
;            uint32_t remainder = arr[i]%10;
;            arr[i] = remainder;
;            arr[i+1]+=quotient;
;            if (i+1>maxIndex){
;              maxIndex = i+1;
;            }
;        }
;    }
;  }
;  uint32_t sum = 0;
;  for(uint32_t n_i = 1; n_i<=maxIndex; n_i++){
;      sum+=arr[i];
;  }
;  return sum;
;}

clearArray:
    ;rdi used for counter
    push rdi
    mov rdi,0
.mainLoop:
    cmp rdi,arr_size
    jge .finished
    mov [digit_arr+rdi],byte 0
    inc rdi
    jmp .mainLoop
.finished:
    pop rdi
    ret
    
;uint compute(rax = n)
;computes the sum of digits in 2^n.
compute:
   ;rax will be used for arithmetic
   ;rdi will be used as a counter
   ;rsi will store n
   ;rdx will be used for arithmetic
   ;r10 will store max index
    push rdi
    push rsi
    push rdx
    push r10
                                  
    call clearArray
    mov [digit_arr], byte 1      ;start with 1 as 2^0 is 1
    mov rdi,1                    ;Starting with 2^0 precomputed so set counter n_i to 1
    mov rsi,rax                  ;rsi = n
    mov r10,0                    ;r10 = maxIndex
    jmp .mainLoop
.outerLoop
    cmp rdi,rsi
    jge .finished                ;if n_i>=n, jmp .finished
    push rdi                     ;store value of rdi (i) as we will now use it to increment over digits 
    mov rdi,0                    ;
.innerLoop
    cmp rdi,r10                  
.innerLoopDone
    pop rdi
.outerLoopDone

    
    
    


global    _start

section   .text
_start:
    call problem_13
    call exit
    
section   .data

msg_1     db  "Problem 16: sum of digits in 2^10 is   :",0h
msg_2     db  "            sum of digits in 2^1000 is :",0h
arr_size equ 1000
digit_arr   TIMES  arr_size    DB  0          ;uint8_t[1000]
