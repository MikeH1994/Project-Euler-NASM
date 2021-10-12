SYSCALL_READ      equ 0
SYSCALL_WRITE     equ 1
SYSCALL_OPEN      equ 2
SYSCALL_CLOSE     equ 3
SYSCALL_EXIT      equ 60

SYSCALL_STDIN     equ 0
SYSCALL_STDOUT    equ 1
SYSCALL_OPEN_R    equ 0
SYSCALL_OPEN_W    equ 1
SYSCALL_OPEN_RW   equ 2 

;----------------------------------------------------------
; void exit()
; Exits program
;----------------------------------------------------------
exit:
    mov rdi,0
    mov rax, SYSCALL_EXIT
    syscall
    ret

;----------------------------------------------------------
; int strlen(char* message)
; String length calculation function
;----------------------------------------------------------
strlen:
    
    ;let rax point to the current element of the char buffer being checked
    ;let rdi point to the start of the char buffer
    push rdi
    mov rdi,rax        ;rdi and rax now both point to the start of the buffer
    
.nextchar:
    cmp byte[rax],0h   ;compare char at rax to null byte
    jz .finished       ;if [rax] == 0h, jump to .finished
    inc rax            ;else, increment the pointer and jump back to .nextchar
    jmp .nextchar
    
.finished:
    sub rax,rdi
    pop rdi
    ret


;----------------------------------------------------------
; void print(char* message)
; print string to stdout (without a linefeed at end)
;----------------------------------------------------------
print_LF:
    push rax
    push 0Ah         ;push a linefeed on to the stack (Don't need a null byte as next byte in rax is 0)
    
    mov rax, rsp    ;put the pointer to the top of the stack (i.e. the linefeed) in rax 
    call print_str
    
    pop rax         ;remove linefeed    
    pop rax         ;restore original value of rx
    ret

;----------------------------------------------------------
; void print(char* message)
; print string to stdout (without a linefeed at end)
;----------------------------------------------------------
print_str:
    push rax
    push rdi
    push rsi
    push rdx
    
    ;for printing to stdout as syscall we want:
    ;rax = SYSCALL_WRITE, rdi = SYSCALL_STDOUT, rsi = message ptr, rdx = strlen
    
    mov rsi,rax        ;move the str ptr to rsi first
    call strlen        ;calculate the length of the string (strlen is now in rax)
    mov rdx,rax        ;move the string length to rdx
    mov rax, SYSCALL_WRITE
    mov rdi, SYSCALL_STDOUT
    syscall
    
    ;pop stack back in order then exit
    pop rdx
    pop rsi
    pop rdi
    pop rax
    ret

;----------------------------------------------------------
; void sprint_LF(char* message)
; print a string
;----------------------------------------------------------
print_str_LF:
    call print_str
    call print_LF
    ret
    
;----------------------------------------------------------
; void print_int_withSignCheck(int num, bool isSigned)
; print an integer, with checks to see if it is signed
;----------------------------------------------------------

print_int_withSignCheck:
    ;let rax be the current value
    ;let rdi be the number of characters to print
    ;let rsi be used to store the char representation of each digit
    ;rdx will store the remainder of the divides
    push rax
    push rdi
    push rsi
    push rdx
    cmp rdi,1        ;if flag is passed, rdi is signed
    mov rdi,0        ;set rdi to zero as we are now using it as a counter
    je .raxIsSigned  ;handle signed int
    jmp .divideLoop  ;else, ignore
.raxIsSigned:
    cmp rax,0        ;check if rax is negative
    jge .divideLoop  ;not negative, no need to handle this
    
    push rax        ;store rax
    push '-'        ;push a linefeed on to the stack (Don't need a null byte as next byte in rax is 0)
    mov rax, rsp    ;put the pointer to the top of the stack (i.e. the minus sign) in rax 
    call print_str
    pop rax         ;remove minus sign    
    pop rax         ;restore original value of rax
    
    mov  rsi, -1     ;move divisor
    imul rsi         ;times rax by -1 so we know it is now positive
    
    jmp .divideLoop  ;carry on as normal now
.divideLoop:
    inc rdi        ;increment the number of bytes counter
    mov rdx,0      ;clear rdx (where remainder will be stored)
    mov rsi,10     ;put the divisor in rsi
    div rsi        ;divide rax by 10
    add rdx,48     ;add 48 to the quotient (to get the corresponding ascii)
    push rdx       ;add this character to the stack
    cmp rax,0      ;if the quotient is zero, we don't need to go further 
    jnz .divideLoop
    jmp .printLoop
.printLoop:
    mov rax, rsp   ;move the pointer to top stack element to rax
    call print_str ;print this character
    pop rax        ;remove this character from stack
    dec rdi        ;decrement counter
    cmp rdi,0      ;check if we are done
    jnz .printLoop
    jmp .finishedPrinting
.finishedPrinting:   
    ;restore values 
    pop rdx
    pop rsi
    pop rdi
    pop rax
    
    ret
;----------------------------------------------------------
; void print_int(int num)
; print a signed integer
;----------------------------------------------------------
print_int:
    push rdi
    mov rdi,1
    call print_int_withSignCheck
    pop rdi
    ret
   
;----------------------------------------------------------
; void print_int_LF(int num)
; print a signed integer plus linefeed
;----------------------------------------------------------
    
print_int_LF:
    call print_int
    call print_LF
    ret
    
;----------------------------------------------------------
; void print_int(uint)
; print an unsigned integer
;----------------------------------------------------------
print_uint:
    push rdi
    mov rdi,0
    call print_int_withSignCheck
    pop rdi
    ret
    
;----------------------------------------------------------
; void print_int(uint)
; print an unsigned integer
;----------------------------------------------------------
print_uint_LF:
    call print_uint
    call print_LF
    ret
    
;----------------------------------------------------------
; void readFileToBuffer(rax=char* fpath, rdi = char* buffer,rsi = uint bufferSize)
; read file to buffer
;----------------------------------------------------------

readFileToBuffer:

    
    push rdi                ;store so we can restore on return
    push rsi
    push rdx
    
    ;syscall 'open'-
    ;int open(const char *pathname, int flags);
    push rdi                ;store char buffer ptr for read call
    push rsi                ;store buffer size for read call
    mov rdi,rax             ;rdi = fpath
    mov rax,SYSCALL_OPEN    ;set rax for syscall
    mov rsi,SYSCALL_OPEN_R  ;set read only option
    syscall                 ;rax now contains file descriptor
    
    ;syscall 'read'-
    ;void read(uint fd, char* buff, uint count)
    pop rdx                 ;store buffer size in rdx 
    pop rsi                 ;store char buffer ptr in rsi
    mov rdi,rax             ;store fd in rdi
    mov rax,SYSCALL_READ     
    syscall
    
    ;syscall 'close'
    ;void close(uint fd)
    mov rax,SYSCALL_CLOSE   ;file descriptor already in rdi 
    syscall
    
    pop rdx                 ;restore initial values
    pop rsi
    pop rdi
    ret