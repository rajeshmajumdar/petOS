[bits 32] 
[extern main] ; Here we are calling the extern "C" function main.
call main ; finally here we jump to our CPP code.
jmp $
