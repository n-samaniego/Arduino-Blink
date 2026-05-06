	.file	"bare-blink.c"
__SP_H__ = 0x3e
__SP_L__ = 0x3d
__SREG__ = 0x3f
__tmp_reg__ = 0
__zero_reg__ = 1
	.text
	.section	.text.startup,"ax",@progbits
.global	main
	.type	main, @function
main:
/* prologue: function */
/* frame size = 0 */
/* stack size = 0 */
.L__stack_usage = 0
	ldi r24,lo8(32)
	out 0x4,r24
	out 0x5,__zero_reg__
	ldi r24,lo8(1)
	out 0x7,r24
	out 0x8,__zero_reg__
	ldi r25,lo8(32)
.L2:
	out 0x5,r25
	out 0x8,r24
	ldi r18,lo8(1599999)
	ldi r19,hi8(1599999)
	ldi r20,hlo8(1599999)
1:	subi r18,1
	sbci r19,0
	sbci r20,0
	brne 1b
	rjmp .
	nop
	out 0x5,__zero_reg__
	out 0x8,__zero_reg__
	ldi r18,lo8(1599999)
	ldi r19,hi8(1599999)
	ldi r20,hlo8(1599999)
1:	subi r18,1
	sbci r19,0
	sbci r20,0
	brne 1b
	rjmp .
	nop
	rjmp .L2
	.size	main, .-main
	.ident	"GCC: (GNU) 15.1.0"
