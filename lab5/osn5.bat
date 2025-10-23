tasm32 /ml /l /c osn5.asm
pause 
tlink32 /Tpe /aa /x /c osn5.obj,,,import32.lib
pause
td32 osn5.exe