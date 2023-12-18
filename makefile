bf1: compiler/bf1.asm
	nasm compiler/bf1.asm -f bin -o compiler/bf.exe
bf2: compiler/bf2.asm
	nasm compiler/bf2.asm -f bin -o compiler/bf.exe

bf_list: compiler/bf.exe
	@ndisasm -o100h compiler/bf.exe
len: compiler/bf.exe
	dir .\compiler\bf.exe

syscall:
	nasm demo/syscall.asm -f bin -o demo/syscall.com

listing:
	@nasm demo/test.asm -f bin -o demo/test.com
	@ndisasm -o100h demo/test.com
