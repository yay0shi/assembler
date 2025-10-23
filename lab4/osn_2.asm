includelib import32.lib

extrn MessageBoxA:near
extrn ExitProcess:near
extrn LoadLibraryA:near
extrn FreeLibrary:near
extrn GetProcAddress:near
MessageBox equ MessageBoxA

.386
.model flat,stdcall

.data 
    mas db 12 dup(?)        ; строка + '$' для DOS вывода
    number1 dd 2147483647           ; число для преобразования
    number2 dd 12
    number3 dd -2147483648
    number4 dd -12
    title_str db 'result :',0
	
    dll_name db 'func.dll',0
    func_name db 'Long2Str',0
    hDll dd ?
    pLong2Str dd ?           ; сюда сохраним адрес функции
    
.code 

start:
    call LoadLibraryA, offset dll_name
    mov hDll, eax
    
    ; Получаем адрес Long2Str
    call GetProcAddress, hDll, offset func_name 
    mov pLong2Str, eax
        
    ; Цикл по числам
    lea esi, number1         ; Загружаем адрес первого числа в SI
    mov ecx, 4               ; Количество чисел (4 числа)
    
next_number:
    push ecx
    mov eax, [esi]          ; Загружаем текущее число в EAX
    ;push eax                ; Кладём число в стек
    ;push offset mas 		 ; Кладём адрес буфера строки в стек
    

    call pLong2Str, eax, offset mas           ; Вызов процедуры преобразования
    ; ret 8 внутри очистит 6 байт со стека
    
    call MessageBox, 0,  offset mas, offset title_str, 0
    
    
    
    ; Переходим к следующему числу
    add esi, 4               ; Переход к следующему числу (каждое число - 4 байта)
    pop ecx
    loop next_number        ; Повторяем, пока CX != 0

    ; Завершаем программу
     call ExitProcess,0
       


end start