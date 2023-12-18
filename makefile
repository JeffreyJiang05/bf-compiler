bf1: compiler/bf1.asm
	nasm compiler/bf1.asm -f bin -o compiler/bf

bf_list: compiler/bf
	@ndisasm -o100h compiler/bf
len: compiler/bf
	dir .\compiler\bf

syscall:
	nasm demo/syscall.asm -f bin -o demo/syscall.com

listing:
	@nasm demo/test.asm -f bin -o demo/test.com
	@ndisasm -o100h demo/test.com
