bf1: compiler/bf1.asm
	nasm compiler/bf1.asm -f bin -o compiler/bf.com

bf_list: compiler/bf.com
	@ndisasm -o100h compiler/bf.com
len: compiler/bf.com
	dir .\compiler\bf.com

syscall:
	nasm demo/syscall.asm -f bin -o demo/syscall.com

listing:
	@nasm demo/test.asm -f bin -o demo/test.com
	@ndisasm -o100h demo/test.com
