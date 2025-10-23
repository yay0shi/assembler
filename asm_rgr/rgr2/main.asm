		includelib	../kernel32.lib
		includelib	../user32.lib

extern SystemParametersInfoA: proc
extern MessageBoxA: proc
extern ExitProcess: proc

.data
HIGHCONTRAST struct
    cbSize          dd ?
    dwFlags         dd ?
    lpszDefaultScheme dq ?
HIGHCONTRAST ends

hcontrast HIGHCONTRAST <>

SPI_SETHIGHCONTRAST equ 67
SPI_GETHIGHCONTRAST equ 66
SPIF_UPDATEINIFILE  equ 1
SPIF_SENDCHANGE     equ 2

HCF_HIGHCONTRASTON  equ 1
HCF_HIGHCONTRASTOOFF equ 0

szTitle        db "HighContrast Control",0
szEnabled      db "HighContrast mode ENABLED",0
szDisabled     db "HighContrast mode DISABLED",0
szToggleOn     db "Enable HighContrast mode?",0
szToggleOff    db "Disable HighContrast mode?",0
szError        db "Error changing HighContrast mode",0

.code
WinMain proc
    ; Выровнять стек
    sub rsp, 28h
    
    ; Получить текущее состояние HighContrast
    mov hcontrast.cbSize, sizeof HIGHCONTRAST; размер структуры
    lea rcx, hcontrast; Загружаем в RCX указатель на структуру hcontrast
    mov rdx, 0 ; устанавливаем 0 - получить состояние
    call GetHighContrastState
    
    ; Проверить текущее состояние и переключить
    test hcontrast.dwFlags, HCF_HIGHCONTRASTON; Проверяем, включен ли режим высокой контрастности
    jnz DisableHighContrast; если включен, переходим к отключению
    
EnableHighContrast:
    ; Запрос на включение
    mov rcx, 0 ; hWnd - окно
    lea rdx, szToggleOn ; текст
    lea r8, szTitle  ; заголовок окна
    mov r9, 4 ; MB_YESNO (4) yesnocancel(3)
    call MessageBoxA
    
    cmp rax, 6 ; IDYES? проверяем результат
    jne Exit
    
    ; Включить HighContrast
    mov hcontrast.cbSize, sizeof HIGHCONTRAST; размер структурыдля включения
    mov hcontrast.dwFlags, HCF_HIGHCONTRASTON; устанавливаем флгаг HCF_HIGHCONTRASTON
    mov hcontrast.lpszDefaultScheme, 0; обнуляем указатель
    
    lea rcx, hcontrast;загружаем указатель на структуру
    mov rdx, 1; флаг для применения узменений
    call SetHighContrastState
    
    jmp ShowResult

DisableHighContrast:
    ; Запрос на выключение
    mov rcx, 0  ; окнор
    lea rdx, szToggleOff ; текст
    lea r8, szTitle; заголовок
    mov r9, 4 ; MB_YESNO (4) кнопки
    call MessageBoxA
    
    cmp rax, 6; IDYES?проверяем результат
    jne Exit
    
    ; Выключить HighContrast
    mov hcontrast.cbSize, sizeof HIGHCONTRAST; размер структурыдля включения
    mov hcontrast.dwFlags, HCF_HIGHCONTRASTOOFF;  устанавливаем флгаг HCF_HIGHCONTRASTOFF
    mov hcontrast.lpszDefaultScheme, 0; указатель на цветовую схему 0, те схема по умолчанию
    
    lea rcx, hcontrast;загружаем указатель на структуру
    mov rdx, 1; флаг для применения узменений
    call SetHighContrastState

ShowResult:
    ; Показать результат
    test rax, rax; проверяем результат установки RAX = 0 если ошибка
    jz ShowError
    
    ; Получить обновленное состояние для отображения
    mov hcontrast.cbSize, sizeof HIGHCONTRAST
    lea rcx, hcontrast
    mov rdx, 0; флаг "только получить состояние"
    call GetHighContrastState
    
    test hcontrast.dwFlags, HCF_HIGHCONTRASTON; проверяет бит High Contrast ON
    jz ShowDisabled
    
ShowEnabled:
    mov rcx, 0
    lea rdx, szEnabled ; "HighContrast mode ENABLED"
    lea r8, szTitle ; "HighContrast Control" 
    mov r9, 0; MB_OK только кнопка OK
    call MessageBoxA
    jmp Exit

ShowDisabled:
    mov rcx, 0
    lea rdx, szDisabled; "HighContrast mode DISABLED"
    lea r8, szTitle; "HighContrast Control"
    mov r9, 0
    call MessageBoxA
    jmp Exit

ShowError:
    mov rcx, 0
    lea rdx, szError ; "Error changing HighContrast mode"
    lea r8, szTitle
    mov r9, 0
    call MessageBoxA

Exit:
    xor rcx, rcx
    call ExitProcess

WinMain endp

; Функция получения состояния HighContrast
; RCX = указатель на HIGHCONTRAST структуру
; RDX = флаг (0 - только получить, 1 - показать диалог)
GetHighContrastState proc
    sub rsp, 28h
    
    mov r8, rcx ; HIGHCONTRAST структура указатель на структуру
    mov rcx, SPI_GETHIGHCONTRAST  ; Action =66, получаем параметр высокой контрастности
    mov rdx, sizeof HIGHCONTRAST ; Size = 16 байт
    mov r9, 0 ; fWinIni флаг обновления профился 0- не обновлять
    
    call SystemParametersInfoA
    
    add rsp, 28h; восстанаввливаем указатель стека
    ret
GetHighContrastState endp

; Функция установки состояния HighContrast
; RCX = указатель на HIGHCONTRAST структуру
; RDX = флаг (0 - только установить, 1 - показать диалог)
SetHighContrastState proc
    sub rsp, 28h
    
    mov r8, rcx; HIGHCONTRAST структура
    mov rcx, SPI_SETHIGHCONTRAST ; Action =67 устанавливаем параметр
    mov rdx, sizeof HIGHCONTRAST; Size
    
    test rdx, rdx; проверяем флаг если 0 то устанавливаем без уведомления
    jz NoChangeNotify
    
    ; SPIF_UPDATEINIFILE | SPIF_SENDCHANGE; если не ноль то сохраняем в реестр
    mov r9, SPIF_UPDATEINIFILE or SPIF_SENDCHANGE; уведомляем приложения
    jmp CallSystemParams
    
NoChangeNotify:
    mov r9, 0 ; Без уведомления
    
CallSystemParams:
    call SystemParametersInfoA
    
    add rsp, 28h
    ret
SetHighContrastState endp
		end
