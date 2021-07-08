	.data
	.text
.LC0:
	.string "Enter number n >0: "
	.text

.LC1:
	.string "Sum of first n number is: "
	.text

.LC2:
	.string "\n"
	.text

#1. FUNCTION main:
	.globl main
	.type main, @function
main:
	push %rbp
	movq %rsp, %rbp
	subq $96, %rsp
#2. 	t0= "Enter number n >0: "
	leaq .LC0(%rip), %rdx
	movq %rdx, -16(%rbp)
#3. 	parameter t0
	movq -16(%rbp), %rdx
	push %rdx
#4. 	t1= CALL printStr 1
	call printStr
	movl %eax, -20(%rbp)
#5. 	t2= &n
	leaq -4(%rbp), %rdx
	movq %rdx, -28(%rbp)
#6. 	parameter t2
	movq -28(%rbp), %rdx
	push %rdx
#7. 	t3= CALL readInt 1
	call readInt
	movl %eax, -32(%rbp)
#8. 	t4= 0
	movl $0, -36(%rbp)
#9. 	sum= t4
	movl -36(%rbp), %edx
	movl %edx, -40(%rbp)
#10. 	t5= 0
	movl $0, -44(%rbp)
#11. 	i= t5
	movl -44(%rbp), %edx
	movl %edx, -8(%rbp)
.M3:
#12. 	t6= i<=n
	movl -8(%rbp), %edx
	cmpl -4(%rbp), %edx
	setle %al
	movzbl %al, %edx
	movl %edx, -48(%rbp)
#13. 	if t6 Jump 20
	cmpl $0, -48(%rbp)
	jne .M1
#14. 	Jump 23
	jmp .M2
.M4:
#15. 	t7= i
	movl -8(%rbp), %edx
	movl %edx, -52(%rbp)
#16. 	t8= 1
	movl $1, -56(%rbp)
#17. 	t9= t8+i
	movl -56(%rbp), %edx
	addl -8(%rbp), %edx
	movl %edx, -60(%rbp)
#18. 	i= t9
	movl -60(%rbp), %edx
	movl %edx, -8(%rbp)
#19. 	Jump 12
	jmp .M3
.M1:
#20. 	t10= sum+i
	movl -40(%rbp), %edx
	addl -8(%rbp), %edx
	movl %edx, -64(%rbp)
#21. 	sum= t10
	movl -64(%rbp), %edx
	movl %edx, -40(%rbp)
#22. 	Jump 15
	jmp .M4
.M2:
#23. 	t11= "Sum of first n number is: "
	leaq .LC1(%rip), %rdx
	movq %rdx, -72(%rbp)
#24. 	parameter t11
	movq -72(%rbp), %rdx
	push %rdx
#25. 	t12= CALL printStr 1
	call printStr
	movl %eax, -76(%rbp)
#26. 	parameter sum
	movl -40(%rbp), %edx
	push %rdx
#27. 	t13= CALL printInt 1
	call printInt
	movl %eax, -80(%rbp)
#28. 	t14= "\n"
	leaq .LC2(%rip), %rdx
	movq %rdx, -88(%rbp)
#29. 	parameter t14
	movq -88(%rbp), %rdx
	push %rdx
#30. 	t15= CALL printStr 1
	call printStr
	movl %eax, -92(%rbp)
#31. END FUNCTION
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
