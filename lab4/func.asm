; Процедура Long2Str - преобразование 32-битного числа в строку
.386
.model flat
; функции, определяемые в этом DLL

public Long2Str
.code
start:
mov al, 1
ret 12

Long2Str proc
    push ebp
    mov ebp, esp			; Установка базового указателя
    push ecx			; Сохраняем регистр CX (будем использовать как счётчик цифр)



    mov edi, [ebp + 12]       ; DI = адрес строки
    mov eax, [ebp + 8]      ; Число для преобразования

    xor ecx, ecx           ; ECX = 0 (счётчик цифр)
    mov ebx, 10            ; EBX = 10 (делитель)

    cmp eax, 0
    jns skip_sign		; Если число >= 0, пропускаем установку минуса

    neg eax                ; Инвертируем число (делаем его положительным)
    mov edx, eax           ; Сохраняем модуль числа в EDX
    mov al, '-'            ; Записываем знак минус
    stosb                  ; Записываем знак в строку
    mov eax, edx           ; Восстанавливаем число (модуль)

skip_sign:
    cmp eax, 0
    jne next_digit         ; Если EAX != 0, начинаем деление

    mov al, '0'            ; Если EAX == 0, просто пишем '0'
    stosb
    jmp finish			; Переход к завершению

next_digit:
    xor edx, edx           ; Очищаем EDX перед делением
    div ebx                ; EAX / EBX -> результат в EAX, остаток в EDX
    push edx               ; Сохраняем остаток (цифру) в стек
    inc ecx                ; Увеличиваем счётчик цифр
    cmp eax, 0
    jnz next_digit         ; Повторяем, пока EAX != 0

print_digits:
    pop edx                ; Достаём цифру из стека
    mov al, dl
    add al, '0'            ; Преобразуем цифру в ASCII
    stosb                  ; Записываем цифру в строку
    loop print_digits      ; Повторяем для всех цифр

finish:
    mov al, 0            ; Завершаем строку символом '$'
    stosb

    pop ecx				; Восстанавливаем CX
    pop ebp				; Восстанавливаем BP
    ret 8				; Возвращаемся и убираем 8 байт с стека
Long2Str endp	

end start