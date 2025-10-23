set name=main

:: Создание объектного файла
..\ml64 /Cp /c %name%.asm
pause

:: Создание исполняемого файла
..\link /SUBSYSTEM:CONSOLE /ENTRY:WinMain %name%.obj
pause

:: Удаление объектного файла
del /q %name%.obj

%name%.exe
pause