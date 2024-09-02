; ----------------------------------------------------------------------------------------
;     Compile and run as:
;     nasm -felf64 problem_04_tests.asm && ld problem_04_tests.o && ./a.out && rm problem_04_tests.o && rm a.out
; ----------------------------------------------------------------------------------------

%include "./problem_04.asm"
    
global    _start

section   .text    
            
test_countDigitsInNumber:
    mov rax,msg_header
    call print_str_LF
    mov rax,msg_test_countDigits_header
    call print_str_LF
    mov rax,msg_header
    call print_str_LF
    
    mov rsi,9
    call .print
    mov rsi,13
    call .print
    mov rsi,427
    call .print
    mov rsi,9409
    call .print
    mov rsi,12345678
    call .print
     
    ret
.print:
    mov rax,msg_test_countDigits_1
    call print_str
    mov rax,rsi
    call print_uint
    mov rax,msg_test_countDigits_2
    call print_str
    mov rax,rsi
    call countDigitsInNumber  
    call print_uint_LF
    ret
    
test_getDigit:
    mov rax,msg_header
    call print_str_LF
    mov rax,msg_test_getDigit_header
    call print_str_LF
    mov rax,msg_header
    call print_str_LF
    
    mov rdi,9
    call .print    
    mov rdi,13    
    call .print
    mov rdi,427
    call .print
    mov rdi,9409
    call .print
    mov rdi,9409
    call .print    
    mov rdi,123456789098
    call .print       
    ret          
;void .print(rdi number)
.print:
    mov rax,msg_test_getDigit_1
    call print_str
    mov rax,rdi     ;rax = number
    call print_uint
    mov rax,msg_test_getDigit_2
    call print_str
    mov rax,rdi     ;rax = number
    call countDigitsInNumber
    mov rsi,rax    ;
    dec rsi        ;current index = nDigits - 1 
    jmp .main_loop
.main_loop:
    mov rax,rdi       
    call getDigit
    call print_uint
    cmp rsi,0
    je .exit_loop
    dec rsi
    jmp .main_loop
.exit_loop:
    mov rax,msg_test_getDigit_3
    call print_str_LF
    ret
    
test_isPalindrome:
    mov rax,msg_header
    call print_str_LF
    mov rax,msg_test_isPalindrome_header
    call print_str_LF
    mov rax,msg_header
    call print_str_LF
    
    mov rsi,9
    call .print
    mov rsi,13
    call .print
    mov rsi,99
    call .print
    mov rsi,101
    call .print
    mov rsi,222
    call .print
    mov rsi,123
    call .print
    mov rsi,2002
    call .print
    mov rsi,1234
    call .print
    mov rsi,9409
    call .print
    mov rsi,12021
    call .print
    mov rsi,12031
    call .print
    mov rsi,9981002899
    call .print
    mov rsi,9982002899
    call .print
    mov rsi,99820002899
    call .print
    ret
.print:
    mov rax,rsi
    call print_uint
    mov rax,msg_test_isPalindrome
    call print_str
    mov rax,rsi
    call isPalindrome
    call print_uint_LF
    ret    
    
_start:
    call test_countDigitsInNumber
    call test_getDigit
    call test_isPalindrome
    call exit
    
section   .data
    msg_header             db "=======================",0h
    msg_test_countDigits_header    db  "Test- count digits",0h
    msg_test_countDigits_1  db  "Number of digits in ",0h
    msg_test_countDigits_2  db  " = ",0h
    
    msg_test_getDigit_header       db  "Test- get digit",0h
    msg_test_getDigit_1  db  "Digits in ",0h
    msg_test_getDigit_2  db  "- ",0h
    msg_test_getDigit_3  db  " ",0h
    
    msg_test_isPalindrome_header db  "Test- isPalindrome",0h     
    msg_test_isPalindrome        db  " is palindrome: "  