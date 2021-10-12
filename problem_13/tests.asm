testSumDigits:
    mov rax,0
    mov rdi,0
    call sumDigit
    ret   
    
    
testGetDigitFromCharBuffer:
    mov rax,-1
    jmp .numberLoop
.numberLoop:
    call print_LF
    inc rax
    cmp rax,100
    jge .finished
    mov rdi,49
    jmp .digitLoop
.digitLoop:
    cmp rdi,0
    jl .numberLoop
    push rax
    call getDigitFromCharBuffer
    call print_uint
    pop rax
    dec rdi
    jmp .digitLoop
.finished:
    ret
    
testPrintDigits:
    ;call printDigits
    ;call print_LF
    ;call print_LF
    mov rdi,49
.mainLoop:
    cmp rdi,0
    jl .finished
    mov rax,0
    call getDigitFromCharBuffer
    mov [digit_arr+rdi*8],rax
    dec rdi
    jmp .mainLoop
.finished:
    call printDigits
    ret