; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 problem_13.asm && ld problem_13.o && ./a.out
; ----------------------------------------------------------------------------------------

;Problem description: 
; "Work out the first ten digits of the sum of the following one-hundred 50-digit numbers."

;General outline:
;As we only have 64 bits in our register, we can't hold the entire number in one register.
;Instead, declare an array that will hold the digits of our final sum. As there are 100 numbers
;to be summed, the maximum length of the sum would be 52 digits.
;Load the file in to memory. Then, sum all the 1's for each number, storing the result in the array
;(carrying over where necessary). Repeat for 10's, 100's, 1000's etc until all complete.

;uint16_t getDigitFromCharBuffer(number,digit,char* buffer){
;    //e.g. for the last digit of the first number in the text file, number would be 0
;    //and digit would be 0.
;    uint index = number*51 + (49-digit)
;    char c = buffer[index]
;    return c-48;
;}
;
;uint problem_13(){
;    uint16_t digit_arr[52] = {0};    
;    char* buffer = readFile("data.txt")    
;    for(uint digit = 0; digit<50; digit++){
;        uint16_t sum = 0; 
;        for(uint n = 0; n<100; n++){
;            sum+=getDigitFromCharBuffer(n,digit,buffer);
;        }
;        digit_arr[digit]+=sum
;    }
;    //carry over any 10s and 100s stored in each element
;    for(uint digit = 0; digit<52; digit++){
;        uint sum = digit_arr[digit];
;        digit_arr[digit]=sum%10;      
;        sum/=10;
;        if (digit+1<52){
;            digit_arr[digit+1]+=sum%10;   //add 10's
;            sum/=10;
;        }
;        if (digit+2<52){
;            digit_arr[digit+2]+=sum%10;   //add 100's
;        }
;    }
;    for(uint digit = 51; digit>=0; digit++){
;        std::cout<<digit_arr[digit];
;    }
;    std::endl;
;
;}


%include "../utils.asm"

;uint getDigitFromCharBuffer(rax = uint number index, rdi = uint digit index)
;    given the char buffer containing the entire text file, return the ith digit
;    for the number on row n. for convenience, digit 0 will be the least significant
;    digit in each number  (the last digit, i.e. 1's). Digit 49 will be the first, 
;    most significant digit (10^49).
;    index in char buffer calculated as n*51 + (49-i)
;
;    rax will be used for arithmetic.
;    rdi will be used to store the digit we want want, i, for the number n.
;    rsi will also be used for arithmetic.
;    rdx will store a remainder (unused)

getDigitFromCharBuffer:
    push rsi
    push rdx
    
                      ;rax = n
                      ;rdi = i
    mov rsi,51        ;rsi = 51
    mul rsi           ;multiply rax by rsi to give rax = n*51
    add rax,49        ;rax = n*51 + 49
    sub rax,rdi       ;rax = n*51 + (49-i)
    mov rsi,rax       ;rsi = n*51 + (49-i)
    mov al,byte[charBuffer + rsi] ;rax now stores charBuffer[rax] in lower byte
    and rax,0ffh      ;mask upper 3 bytes
    sub rax,48        ;'0' = ASCII 48, '1' = ASCII 49, etc. i.e. to go from ascii to number,
                      ;subtract 48
    pop rdx
    pop rsi           ;restore original value of rsi
    ret
    
  
;uint sumDigits(rax = uint digit index)
;    loops over every number in the file, summing the ith digit.
;    for convenience, digit 0 will be the least significant  digit in each number  
;    (the last digit, i.e. 1's). Digit 49 will be the first, most significant digit (10^49).
;    rax will be used for arithmetic.
;    rdi will store the digit index i
;    rsi will store the current number counter n
;    rdx will be used as current sum
sumDigit:
    push rdi
    push rsi
    push rdx
    mov rdi,rax    ;rdi = digit index i
    mov rsi,0      ;rsi = number counter n = 0
    mov rdx,0      ;rdx = current sum = 0
    jmp .mainLoop
.mainLoop:
    cmp rsi,100
    jge .finished
    mov rax,rsi    ;rax = number index
                   ;rdi is already digit index
    call getDigitFromCharBuffer  ;rax now holds digit i in number n
    add rdx,rax    ;add digit i in number n to current sum held in rdx
    inc rsi        ;increment the number counter n
    jmp .mainLoop    
.finished:
    mov rax,rdx    ;store the sum in rax
    pop rdx
    pop rsi
    pop rdi
    ret
    
;void sumAllDigits()
;sum digits over all arrays.
;rax will store current sum for a digit i
;rdi will store digit i counter    
sumAllDigits:  
    push rax
    push rdi
    mov rdi,0
.mainLoop:
    cmp rdi,50
    jge .finished
    mov rax,rdi
    call sumDigit
    mov [digit_arr+rdi*8],rax     ;move the sum to digit_arr
    inc rdi
    jmp .mainLoop    
.finished:
    pop rdi
    pop rax
    ret
    
handleCarryOvers:
    ;rax will be used for arithmetic
    ;rdi will store digit counter i
    ;rsi will be used for arimethic as well
    ;rdx will store remainder
    push rax
    push rdi
    push rsi
    push rdx
    mov rdi,0
    mov rsi,10
    jmp .mainLoop
.mainLoop:
    cmp rdi,52
    jge .finished               ;for(rdi = 0; rdi<52; rdi++)
    mov rax,[digit_arr+rdi*8]   ;rax = digit_arr[rdi] = sum
    mov rdx,0                   ;clear remainder 
    div rsi                     ;sum/=10
    mov [digit_arr+rdi*8],rdx   ;digit_arr[rdi] = sum%10 (1's)
    cmp rdi,51                  ;if (rdi+1>=52){
    jge .increment              ;    continue;
    mov rdx,0                   ;clear remainder 
    div rsi                     ;sum/=10 
    add [digit_arr+rdi*8+8],rdx   ;digit_arr[rdi+1] = sum%10 (10's)
    cmp rdi,50                  ;if (rdi+2>=50)
    jge .increment              ;    continue;
    mov rdx,0                   ;clear remainder               
    div rsi                     ;sum/=100
    add [digit_arr+rdi*8+16],rdx   ;digit_arr[rdi+2] = sum%10 (100's)
    jmp .increment
.increment:
    inc rdi
    jmp .mainLoop    
.finished:    
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret
    
;void printAllDigits
;   print all digits in digit_array, counting down from the most significant digit (#51)
;   rax will be used to store the value in array element i 
;   rdi will be used to store the counter
printAllDigits:
    push rax
    push rdi
    mov rdi,51
    jmp .mainLoop
.mainLoop:
    cmp rdi,0    ;for(rdi=51;rdi>=0;rdi--)
    jl .finished
    mov rax,[digit_arr+rdi*8]  ;store digit in rax
    call print_uint
    dec rdi
    jmp .mainLoop
.finished:
    pop rdi
    pop rax
    call print_LF
    ret
    
;void printFirst10Digits
;   print all digits in digit_array, counting down from the most significant digit (#51)
;   rax will be used to store the value in array element i 
;   rdi will be used to store the counter
printFirst10Digits:
    push rax
    push rdi
    mov rdi,51
    jmp .mainLoop
.mainLoop:
    cmp rdi,42    ;for(rdi=51;rdi>=0;rdi--)
    jl .finished
    mov rax,[digit_arr+rdi*8]  ;store digit in rax
    call print_uint
    dec rdi
    jmp .mainLoop
.finished:
    pop rdi
    pop rax
    call print_LF
    ret
    
problem_13:
    mov rax,filepath
    mov rdi,charBuffer
    mov rsi,bufferSize
    call readFileToBuffer
    
    call sumAllDigits
    call handleCarryOvers
    
    mov rax,msg_1
    call print_str_LF
    call printAllDigits
    mov rax,msg_2
    call print_str_LF
    call printFirst10Digits
    ret
   
global    _start

section   .text
_start:
    call problem_13
    call exit
    
section   .data

filepath  db  "data.txt",0h
lines     db  "--------------------------------------------------",0h 
msg_1     db  "Problem 13: Total sum of 50 digit numbers is:",0h
msg_2     db  "            First 10 digits in sum is:",0h
bufferSize equ 8192
charBuffer  TIMES  bufferSize  DB  0    ;uint8_t[8192]
digit_arr   TIMES  52    DQ  0          ;uint64_t[52]
  