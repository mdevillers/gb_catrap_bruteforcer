
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 section .data
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

; D91B-DA1A
map_1 times 64 db 0x80 
; DA1B-DA5A
map_2 times 64 db 0x00

; gd registers
a db 0
b db 0
c db 0
d db 0
e db 0
f db 0
h db 0
l db 0

MAX_PWD_SIZE equ 4

password_and_level times MAX_PWD_SIZE+5 db 0
password_charset db '0123456789ABCEFGHJKLMNPQRTUVWXYZ', 0

MAX_PWD_IDX equ 0x1F
pwdgen_idx times MAX_PWD_SIZE db 0

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 section .bss
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 section .text
;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

global _start

;---------------------------------------------------------------------------
_start:
;---------------------------------------------------------------------------

    call check_passwords

;---------------------------------------------------------------------------
exit:
;---------------------------------------------------------------------------
    mov rdi, rax
    mov rax, 60 ; syscall exit
    syscall

;============================================================================
;  FUNCTIONS
;============================================================================

;---------------------------------------------------------------------------
 check_passwords:
;---------------------------------------------------------------------------

    xor r15, r15

.start:

    lea rdx, [MAX_PWD_SIZE - 1]

.loop:
    cmp byte[pwdgen_idx+rdx], MAX_PWD_IDX
    je .inc_unit2

    call generate_password
    call store_password_to_map
    call check_password
    or rax, rax
    jne .continue
    call print_password

.continue:
    inc r15

    inc byte[pwdgen_idx+rdx]
    
    jmp .loop

.inc_unit2:
    sub rdx, 1
    cmp rdx, -1
    je .end_loop
    inc byte[pwdgen_idx+rdx]
    cmp byte[pwdgen_idx+rdx], MAX_PWD_IDX
    je .inc_unit2

    lea rax, [rdx + 1]
.loop_unit2:
    mov byte [pwdgen_idx+rax], 0
    inc al
    cmp al, MAX_PWD_SIZE
    jne .loop_unit2

    jmp .start

.end_loop:
    ret

;---------------------------------------------------------------------------
 generate_password:
;---------------------------------------------------------------------------

    push rax
    push rbx
    push rcx 
    push rsi
    push rdi

    mov rcx, MAX_PWD_SIZE
    lea rsi, [pwdgen_idx]
    lea rdi, [password_and_level]
.loop:
    lodsb
    mov bl, byte [password_charset+rax]
    mov al, bl
    stosb
    loop .loop

    pop rdi
    pop rsi
    pop rcx
    pop rbx
    pop rax

    ret

;---------------------------------------------------------------------------
 store_password_to_map:
;---------------------------------------------------------------------------

    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r9

    cld

    ;lea rdi, [map_1]
    ;xor rax, rax
    ;mov rcx, 8
    ;rep stosq

    ;lea rdi, [map_2]
    ;mov rax, 0x8080808080808080
    ;mov rcx, 8
    ;rep stosq

    lea rbx, [map_1]
    xor rdx, rdx

    lea rsi, [password_and_level]
.loop:
    lodsb
    or al, al
    je .endsub
    mov rcx, 32
    lea rdi, [password_charset]
    push rdi
    repne scasb
    pop r9
    jne .endsub
    sub rdi, r9
    dec rdi
    mov byte [rbx+rdx], dil
    inc rdx
    jmp .loop

.endsub:
    pop r9
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax
    ret

;---------------------------------------------------------------------------
 check_password:
;---------------------------------------------------------------------------

    push rbx
    push rcx
    push rsi
    push rdi
    push r8
    push r9

.part1:
    lea rsi, [map_1+63]
    lea rdi, [map_2+63]
    std ; set direction flag to go backwards
    mov rcx, 64
    xor rbx, rbx
.loop1:
    lodsb
    ; bit 7 set ? (meaning it is a blank tile)
    mov r8b, al
    shr r8b, 7
    jz .not_bit_7
    stosb
    loop .loop1
.not_bit_7:
    mov r9, rax
    dec rcx
.loop2:
    lodsb
    push rax
    xor al, r9b
    add bl, al
    pop r9
    stosb
    loop .loop2
    mov rax, r9
    stosb

.F1F:
    cld
    lea rsi, [map_2]
    lodsb
    mov byte [b], al
    lodsb
    mov byte [c], al
    lodsb
    mov byte [d], al
    lodsb
    mov byte [e], al

.F2A:
    mov al, byte [c]
    rcl al, 4
    rcl byte [b], 1    
    rcl al, 1
    rcl byte [b], 1    

.F38:
    mov al, byte [d]
    rcl al, 4
    rcl byte [c], 1    
    rcl al, 1
    rcl byte [c], 1    
    rcl al, 1
    rcl byte [c], 1    
    rcl al, 1
    rcl byte [c], 1    

.F4A:
    mov byte [d], al
    mov al, byte [c] 
    and al, 0x7F   
    mov byte [c], al
    mov al, byte [d]
    rcr al, 2
    and al, 0x20
    or al, byte [e]

.F56:
    mov byte [d], al
    mov al, byte [c]
    add al, al
    sub al, byte [b]
    shr al, 1
    and al, 0x3F
    cmp al, byte [d]
    jne .password_not_ok
    mov al, byte [c]
    cmp al, byte [b]
    jc .password_not_ok
    mov al, byte [c]
    cmp al, 0x64
    jnc .password_not_ok

.password_ok:
    cmp byte [b], 0
    je .password_not_ok
    mov rax, 0
    jmp .end

.password_not_ok:
    mov rax, 1

.end:
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rcx
    pop rbx
    ret

;---------------------------------------------------------------------------
 print_password:
;---------------------------------------------------------------------------

    push rax
    push rbx
    push rcx
    push rdx
    push rsi
    push rdi
    push r8
    push r9
    push r15

    mov byte [password_and_level + MAX_PWD_SIZE], 0x20
    movzx ax, byte [b]
    mov bl, 10
    div bl    

    mov cl, al
    mov al, ah
    add al, 0x30
    mov byte [password_and_level + MAX_PWD_SIZE + 2], al
    add cl, 0x30
    mov byte [password_and_level + MAX_PWD_SIZE + 1], cl

    mov byte [password_and_level + MAX_PWD_SIZE + 3], 0x0A

    mov rdi, rax
    mov rax, 1                      ; syscall write
    mov rdi, 1                      ; file descriptor (sysout)
    lea rsi, [password_and_level]   ; buffer to print
    mov rdx, MAX_PWD_SIZE+4         ; buffer len
    syscall

    pop r15
    pop r9
    pop r8
    pop rdi
    pop rsi
    pop rdx
    pop rcx
    pop rbx
    pop rax

    ret
