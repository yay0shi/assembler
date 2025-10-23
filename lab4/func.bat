tasm32 /ml /l func.asm
pause
tlink32 /Tpd /c func.obj,,,,func.def
pause
implib func.lib func.dll
pause