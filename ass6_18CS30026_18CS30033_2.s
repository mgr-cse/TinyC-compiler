	.data
	.text
.LC0:
	.string "Enter n (0<=n<=30): "
	.text

.LC1:
	.string "nth Fibbonaci number is: "
	.text

.LC2:
	.string "\n"
	.text

#1. FUNCTION fib:
	.globl fib
	.type fib, @function
fib:
	push %rbp
	movq %rsp, %rbp
	subq $40, %rsp
#2. 	t0= 2
	movl $2, -4(%rbp)
#3. 	t1= n<t0
	movl 16(%rbp), %edx
	cmpl -4(%rbp), %edx
	setl %al
	movzbl %al, %edx
	movl %edx, -8(%rbp)
#4. 	if t1 Jump 6
	cmpl $0, -8(%rbp)
	jne .M1
#5. 	Jump 7
	jmp .M2
.M1:
#6. 	return n
	movl 16(%rbp), %eax
	leave
	ret
.M2:
#7. 	t2= 1
	movl $1, -12(%rbp)
#8. 	t3= n-t2
	movl 16(%rbp), %edx
	subl -12(%rbp), %edx
	movl %edx, -16(%rbp)
#9. 	parameter t3
	movl -16(%rbp), %edx
	push %rdx
#10. 	t4= CALL fib 1
	call fib
	movl %eax, -20(%rbp)
#11. 	t5= 2
	movl $2, -24(%rbp)
#12. 	t6= n-t5
	movl 16(%rbp), %edx
	subl -24(%rbp), %edx
	movl %edx, -28(%rbp)
#13. 	parameter t6
	movl -28(%rbp), %edx
	push %rdx
#14. 	t7= CALL fib 1
	call fib
	movl %eax, -32(%rbp)
#15. 	t8= t4+t7
	movl -20(%rbp), %edx
	addl -32(%rbp), %edx
	movl %edx, -36(%rbp)
#16. 	return t8
	movl -36(%rbp), %eax
	leave
	ret
#17. END FUNCTION
	leave
	ret

#19. FUNCTION main:
	.globl main
	.type main, @function
main:
	push %rbp
	movq %rsp, %rbp
	subq $64, %rsp
#20. 	t9= "Enter n (0<=n<=30): "
	leaq .LC0(%rip), %rdx
	movq %rdx, -12(%rbp)
#21. 	parameter t9
	movq -12(%rbp), %rdx
	push %rdx
#22. 	t10= CALL printStr 1
	call printStr
	movl %eax, -16(%rbp)
#23. 	t11= &n
	leaq -4(%rbp), %rdx
	movq %rdx, -24(%rbp)
#24. 	parameter t11
	movq -24(%rbp), %rdx
	push %rdx
#25. 	t12= CALL readInt 1
	call readInt
	movl %eax, -28(%rbp)
#26. 	t13= "nth Fibbonaci number is: "
	leaq .LC1(%rip), %rdx
	movq %rdx, -36(%rbp)
#27. 	parameter t13
	movq -36(%rbp), %rdx
	push %rdx
#28. 	t14= CALL printStr 1
	call printStr
	movl %eax, -40(%rbp)
#29. 	parameter n
	movl -4(%rbp), %edx
	push %rdx
#30. 	t15= CALL fib 1
	call fib
	movl %eax, -44(%rbp)
#31. 	parameter t15
	movl -44(%rbp), %edx
	push %rdx
#32. 	t16= CALL printInt 1
	call printInt
	movl %eax, -48(%rbp)
#33. 	t17= "\n"
	leaq .LC2(%rip), %rdx
	movq %rdx, -56(%rbp)
#34. 	parameter t17
	movq -56(%rbp), %rdx
	push %rdx
#35. 	t18= CALL printStr 1
	call printStr
	movl %eax, -60(%rbp)
#36. END FUNCTION
	leave
	ret

##################### Assembly for header function ########################

	.globl	__putchar
	.type	__putchar, @function
__putchar:
	pushq	%rbp
	movq	%rsp, %rbp
	movl	%edi, %eax
	movb	%al, -4(%rbp)
	leaq	-4(%rbp), %rax
	movq	%rax, %rsi
	movq %rsi, %rsi
	movq $1, %rdx
	movl $1, %eax
	movq $1, %rdi
	syscall
	nop
	popq	%rbp
	ret
	.size	__putchar, .-__putchar
	.globl	__getchar
	.type	__getchar, @function
__getchar:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	movb	$0, -9(%rbp)
	leaq	-9(%rbp), %rax
	movq	%rax, %rsi
	movq %rsi, %rsi
	movq $1, %rdx
	movl $0, %eax
	movq $0, %rdi
	syscall
	movzbl	-9(%rbp), %eax
	movq	-8(%rbp), %rdx
	xorq	%fs:40, %rdx
	je	.L4
	call	__stack_chk_fail@PLT
.L4:
	leave
	ret
	.size	__getchar, .-__getchar
	.globl	printStr
	.type	printStr, @function
printStr:
	pushq	%rbp
	movq	%rsp, %rbp
	movq 	16(%rbp), %rdi
	subq	$8, %rsp
	movq	%rdi, -8(%rbp)
	jmp	.L6
.L7:
	movq	-8(%rbp), %rax
	leaq	1(%rax), %rdx
	movq	%rdx, -8(%rbp)
	movzbl	(%rax), %eax
	movsbl	%al, %eax
	movl	%eax, %edi
	call	__putchar
.L6:
	movq	-8(%rbp), %rax
	movzbl	(%rax), %eax
	testb	%al, %al
	jne	.L7
	nop
	nop
	leave
	ret
	.size	printStr, .-printStr
	.globl	_printInt
	.type	_printInt, @function
_printInt:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	cmpl	$0, -4(%rbp)
	je	.L11
	movl	-4(%rbp), %eax
	movslq	%eax, %rdx
	imulq	$1717986919, %rdx, %rdx
	shrq	$32, %rdx
	sarl	$2, %edx
	sarl	$31, %eax
	subl	%eax, %edx
	movl	%edx, %eax
	movl	%eax, %edi
	call	_printInt
	movl	-4(%rbp), %ecx
	movslq	%ecx, %rax
	imulq	$1717986919, %rax, %rax
	shrq	$32, %rax
	movl	%eax, %edx
	sarl	$2, %edx
	movl	%ecx, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	subl	%eax, %ecx
	movl	%ecx, %edx
	movl	%edx, %eax
	addl	$48, %eax
	movsbl	%al, %eax
	movl	%eax, %edi
	call	__putchar
	jmp	.L8
.L11:
	nop
.L8:
	leave
	ret
	.size	_printInt, .-_printInt
	.globl	printInt
	.type	printInt, @function
printInt:
	pushq	%rbp
	movq	%rsp, %rbp
	movl 	16(%rbp), %edi
	subq	$16, %rsp
	movl	%edi, -4(%rbp)
	cmpl	$0, -4(%rbp)
	jns	.L13
	movl	$45, %edi
	call	__putchar
	movl	-4(%rbp), %eax
	negl	%eax
	movl	%eax, %edi
	call	_printInt
	jmp	.L16
.L13:
	cmpl	$0, -4(%rbp)
	jne	.L15
	movl	$48, %edi
	call	__putchar
	jmp	.L16
.L15:
	movl	-4(%rbp), %eax
	movl	%eax, %edi
	call	_printInt
.L16:
	nop
	leave
	ret
	.size	printInt, .-printInt
	.globl	readInt
	.type	readInt, @function
readInt:
	pushq	%rbp
	movq	%rsp, %rbp
	subq	$32, %rsp
	movq 	16(%rbp), %rdi
	movq	%rdi, -24(%rbp)
	movl	$1, -4(%rbp)
	movq	-24(%rbp), %rax
	movl	$0, (%rax)
	movl	$0, %eax
	call	__getchar
	movb	%al, -5(%rbp)
	jmp	.L18
.L22:
	cmpb	$45, -5(%rbp)
	jne	.L19
	movl	$-1, -4(%rbp)
	jmp	.L20
.L19:
	movq	-24(%rbp), %rax
	movl	(%rax), %edx
	movl	%edx, %eax
	sall	$2, %eax
	addl	%edx, %eax
	addl	%eax, %eax
	movl	%eax, %edx
	movsbl	-5(%rbp), %eax
	addl	%edx, %eax
	leal	-48(%rax), %edx
	movq	-24(%rbp), %rax
	movl	%edx, (%rax)
.L20:
	movl	$0, %eax
	call	__getchar
	movb	%al, -5(%rbp)
.L18:
	cmpb	$57, -5(%rbp)
	jg	.L21
	cmpb	$47, -5(%rbp)
	jg	.L22
.L21:
	cmpb	$45, -5(%rbp)
	je	.L22
	movq	-24(%rbp), %rax
	movl	(%rax), %eax
	imull	-4(%rbp), %eax
	movl	%eax, %edx
	movq	-24(%rbp), %rax
	movl	%edx, (%rax)
	nop
	leave
	ret
