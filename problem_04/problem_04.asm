;Problem description:

;A palindromic number reads the same both ways. The largest palindrome made from the product of two 2-digit numbers 
;is 9009 = 91 � 99
;Find the largest palindrome made from the product of two 3-digit numbers.
;General problem outline (simple solution):

;bool countDigitsInNumber(val){
;    uint32_t nDigits = 1;
;    while(true){
;        val/=10;
;        if (val<10){
;          break;
;        }
;        nDigits++;
;    }
;    return nDigits;
;}
;
;uint32_t getDigit(val,digitIndex){
;    for(uint32_t i = 0; i<digitIndex; i++){
;        val/=10;
;    }
;    return val%10;
;}
;
;bool checkIfPalindrome(val){
;    nDigits = countDigitsInNumber(val)
;    for(uint32_t i1 = 0; i1<nDigits; i1++){
;        i2 = nDigits-1-i1;
;        if (i1>=i2){
;            return True;
;        }
;        uint32_t d1 = getDigit(val,i1);
;        uint32_t d2 = getDigit(val,i2);
;        if (d1!=d2){
;            return false
;        }
;    }
;}
;
;uint32_t largestPalindrome(minVal,maxVal){
;    uint32_t maxPalindrome = 0;
;    for(uint32_t v1 = minVal; v1<=maxVal; v1++){
;        for(uint32_t v2 = v1; v2<=maxVal; v2++){
;            uint32_t val = v1*v2;
;            if (checkIfPalindrome(val)){
;                maxPalindrome = val
;            }
;        }
;    }
;}

%include "../utils.asm"

section   .text


;uint countDigitsInNumber(rax val)
;rax - used to store current val after applying sequential divisions
;rsi - used to store current number of digits we are at
;rdi - used to store divisor (10)
;rdx - used to store remainder of divisions

countDigitsInNumber:
    push rsi
    push rdi
    push rdx
    mov rsi,1
    mov rdi,10
.main_loop:
    mov rdx,0   ;clear remainder
    div rdi     ;rax/=10
    cmp rax,0
    je .exit    ;if remainder less than zero, exit
    inc rsi     ;nDigits++
    jmp .main_loop
.exit:
    mov rax,rsi
    pop rdx
    pop rdi
    pop rsi
    ret
    
;uint getDigit(rax val,rsi index)
;rax - stores current val after each division
;rsi - stores index we want
;rdi - stores current digit
;rdx - stores remainder
;r10 - stores divisor (10)
getDigit:  
    push rsi
    push rdi
    push rdx
    push r10
    
    push rax
    call countDigitsInNumber  ;rax = nDigits
    cmp rsi,rax
    jge .outOfBounds         ;if index>=nDigits, exit
    
    
    ;flip digits for convenience (i.e. so 0 is leftmost digit)
    ;mov r10,rax               
    ;sub r10,rsi              
    ;sub r10,1                 ;rsi = nDigits - rsi - 1
    ;mov rsi,r10
    pop rax                   ;rax = val
    
    mov rdi,0 ;current digit
    mov r10,10;divisor
    jmp .main_loop
.main_loop:
    mov rdx,0 ;clear remainder
    div r10   ;val/=10
    cmp rdi,rsi
    je .exit
    inc rdi
    jmp .main_loop
.outOfBounds:
    pop rax
    mov rdx,0
    jmp .exit
.exit:
    mov rax,rdx
    pop r10
    pop rdx
    pop rdi
    pop rsi
    ret
    
;uint isPalindrome(rax val)
;rax - left for return values of functions
;rsi - used to store value
;rdi - used to store number of digits
;r8  - used to store index 1
;r9  - used to store index 2
;r10 - used to store value at index 1
isPalindrome:
    push rsi
    push rdi
    push r8
    push r9
    push r10
    
    mov rsi,rax ;rsi = val
    
    call countDigitsInNumber
    mov rdi,rax ;rdi = nDigits
    
    mov r8,0   ;r8 = i1 = 0
    mov r9,rdi
    dec r9     ;r9 = i2 = nDigits - 1
.main_loop:
    cmp r8,r9   ;if i1>=i2, exit loop
    jge .endOfLoop
    push rsi

    ;get value at i1
    mov rax,rsi   ;rax = val
    mov rsi,r8    ;rsi = i1
    call getDigit ;rax = value at index i1
    mov r10,rax   ;r10 = value at index i1
    
    ;get value at i2
    pop rax       ;rax = val
    push rax      ;store val on stack again
    mov rsi,r9    ;rsi = i2
    call getDigit ;rax = value at index i2
    
    pop rsi       ;rsi = val
    cmp rax,r10
    jne .digitsNotEqual
    
    inc r8 
    dec r9
    jmp .main_loop
.endOfLoop:
    mov rax,1    ;return true
    jmp .exit
.digitsNotEqual:
    mov rax,0
    jmp .exit
.exit:
    pop r10
    pop r9
    pop r8
    pop rdi
    pop rsi
    ret

;uint largestPalidromeFromProduct(rax minValue, rsi maxValue)    
;rax - store current product
;rsi - v1
;rdi - v2
;r10  - max value
;r9  - stored palindrome
largestPalidromeFromProduct:
    push rsi
    push rdi
    push r8
    push r9
    
    mov r8,rsi
    mov r9,0
    mov rsi,rax
    mov rdi,rax
    mov rax,0
    
    jmp .outer_loop    
.outer_loop:    
    cmp rsi,r8
    jg .exit             ;if v1>maxVal, break
    mov rdi,rsi          ;v2 = v1

    jmp .inner_loop
.inner_loop:
    cmp rdi,r8    
    jg .inner_loop_break ;if v2>maxval, break
        
    mov rax,rsi
    mul rdi              ;rax = rsi*rdi = v1*v2
    push rax             ;store product on the stack
    call isPalindrome    
    cmp rax,1            ;check if isPalindrome() returned 1 (i.e. true)
    je .palindromeFound
    inc rdi
    pop rax
    jmp .inner_loop
.palindromeFound:   
    inc rdi 
    pop rax  
    cmp rax,r9
    jle .inner_loop
    mov r9,rax  
    jmp .inner_loop
.inner_loop_break:
    inc rsi
    jmp .outer_loop
.exit:
    mov rax,r9
    pop r9
    pop r8
    pop rdi
    pop rsi
    ret
    
