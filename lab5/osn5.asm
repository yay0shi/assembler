.386
.model flat, stdcall

includelib import32.lib

extrn MessageBoxA:near
extrn ExitProcess:near

MessageBox equ MessageBoxA
MB_OK equ 0

.data
buffer db 512 dup(0)        ; буфер для текста
title_str db 'EFLAGS state :',0

flag_ptrs dd offset flag_cf, offset flag_pf, offset flag_af, offset flag_zf, offset flag_sf, offset flag_tf, offset flag_if, offset flag_df, offset flag_of, offset flag_iopl, offset flag_nt, offset flag_rf, offset flag_vm
flag_cf    db "CF",0
flag_pf    db "PF",0
flag_af    db "AF",0
flag_zf    db "ZF",0
flag_sf    db "SF",0
flag_tf    db "TF",0
flag_if    db "IF",0
flag_df    db "DF",0
flag_of    db "OF",0
flag_iopl  db "IOPL",0
flag_nt    db "NT",0
flag_rf    db "RF",0
flag_vm    db "VM",0

flag_bits db 0,2,4,6,7,8,9,10,11,12,14,16,17
flag_count equ 13

.code
start:

    ; Получаем EFLAGS
    pushfd
    pop eax

    mov edi, offset buffer    ; указатель на буфер
    xor ebx, ebx              ; индекс текущего флага

next_flag:
    cmp ebx, flag_count
    jge show_message          ; если все флаги обработаны, показать MessageBox

    mov esi, [flag_ptrs + ebx*4]     ; Текущий адрес имени флага

copy_name:
    mov al, [esi]
    cmp al, 0
    je after_name
    mov [edi], al
    inc esi
    inc edi
    jmp copy_name

after_name:
    mov byte ptr [edi], ':'
    inc edi
    mov byte ptr [edi], ' '
    inc edi
    movzx edx, byte ptr flag_bits[ebx]  ; edx = номер бита (0..31)
    ; если это IOPL  печатаем 2 бита
    cmp ebx, 9
    jne single_bit
    
    ;IOPL 
     bt eax, 13        ; старший бит
    setc al
    add al, '0'
    mov [edi], al
    inc edi

    bt eax, 12        ; младший бит
    setc al
    add al, '0'
    mov [edi], al
    inc edi

    jmp after_value

single_bit:
    bt eax, edx       ; CF  бит eax[edx]
    setc cl           ; CL = 0/1
    add cl, '0'
    mov [edi], cl
    inc edi


after_value:
    mov byte ptr [edi], 13
    inc edi
    mov byte ptr [edi], 10
    inc edi

    inc ebx           ; следующий флаг
    jmp next_flag

show_message:
    ; Показываем MessageBox
    push 0
    push offset title_str
    push offset buffer
    push MB_OK
    call MessageBox

    ; Завершение процесса
    push 0
    call ExitProcess

end start
