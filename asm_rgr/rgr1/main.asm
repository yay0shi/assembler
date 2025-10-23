		includelib	../kernel32.lib
		includelib	../user32.lib
		extern	ExitProcess: proc
		extern  MessageBoxA: proc
		extern  wsprintfA: proc

.data
s1 db 13 dup(0) ;vendor id
s2 db 50 dup(0) ;brand string
s3 db "Brand string not supported",0
s4 db "RNDRAND is not supported",0
s5 db "RNDRAND is supported",0
MsgCaption db "cpuid",0
fmt db "Vendor ID: %s",13,10
	db "CPU: %s",13,10
	db "RNDRAND: %s",0
MsgBoxText	db	256 dup(0)

.code
WinMain		proc
		sub	rsp, 7 * 8	; выделить стек для передачи параметров + выравнивание
		lea	rdi, s1

		xor	rax, rax	; eax = 0
		cpuid			; получить Vendor ID
		mov	[rdi], ebx	; сохранить
		mov	[rdi + 4], edx	; в строку
		mov	[rdi + 8], ecx

		mov	eax, 80000000h	; проверить поддержку
		cpuid			; строки бренда
		test	eax, 80000000h	; если не поддерживается
		jz	no_brand		; то перейти
		cmp	eax, 80000004h	; или поддерживается не полностью
		jb	no_brand

		lea	rdi, s2
		mov	eax, 80000002h	; получить 1-ю часть
		cpuid			; строки бренда
		mov	[rdi], eax	; сохранение в строку
		mov	[rdi + 4], ebx
		mov	[rdi + 8], ecx
		mov	[rdi + 12], edx

		mov	eax, 80000003h	; получить 2-ю часть
		cpuid			; строки бренда
		mov	[rdi + 16], eax	; сохранение в строку
		mov	[rdi + 20], ebx
		mov	[rdi + 24], ecx
		mov	[rdi + 28], edx

		mov	eax, 80000004h	; получить 3-ю часть
		cpuid			; строки бренда
		mov	[rdi + 32], eax	; сохранение в строку
		mov	[rdi + 36], ebx
		mov	[rdi + 40], ecx
		mov	[rdi + 44], edx
		lea rsi,s2 ;указатель на brand string
		jmp check_rdrand

no_brand:
	lea rsi, s3		; указатель на "Brand string not supported"

check_rdrand:
		; Проверка поддержки RDRAND
		mov	eax, 1
		cpuid
		bt	ecx, 30		; проверка бита 30 в ecx (RDRAND)
		jc	rdrand_supported

		; RDRAND не поддерживается
		mov	rbx, offset s4
		jmp	fin

rdrand_supported:
		; RDRAND поддерживается
		mov	rbx, offset s5

fin:
		; формирование строки с результатом
		mov rcx,offset MsgBoxText
		mov rdx,offset fmt
		mov r8,offset s1
		mov r9,rsi
		; Поместить строку RDRAND в стек (5-й аргумент для wsprintfA)
		push	rbx		; 5-й параметр в стек
		sub	rsp, 32
		call	wsprintfA
		add	rsp, 40		; очистка стека
		;вывод результата
		xor rcx,rcx
		mov rdx,offset MsgBoxText
		mov r8,offset MsgCaption
		mov r9,0 ;MB_OK
		call MessageBoxA
		xor rcx,rcx
		call ExitProcess
		;выход
		WinMain endp
end

