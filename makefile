syscall:
	nasm syscall.asm -f bin -o syscall.com

listing:
	@nasm test.asm -f bin -o test.com
	@ndisasm -o100h test.com
