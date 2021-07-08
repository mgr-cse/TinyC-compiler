	.data
	.text
	.comm a, 4, 4
	.comm b, 4, 4
.LC0:
	.string "Enter number a: "
	.text

.LC1:
	.string "Enter number b: "
	.text

.LC2:
	.string "Sum of a and b is: "
	.text

.LC3:
	.string "\n"
	.text

.LC4:
	.string "Diff of a and b is: "
	.text

.LC5:
	.string "\n"
	.text

.LC6:
	.string "Mult of a and b is: "
	.text

.LC7:
	.string "\n"
	.text

#1. FUNCTION main:
	.globl main
	.type main, @function
main:
	push %rbp
	movq %rsp, %rbp
	subq $144, %rsp
#2. 	t0= "Enter number a: "
	leaq .LC0(%rip), %rdx
	movq %rdx, -8(%rbp)
#3. 	parameter t0
	movq -8(%rbp), %rdx
	push %rdx
#4. 	t1= CALL printStr 1
	call printStr
	movl %eax, -12(%rbp)
#5. 	t2= &a
	leaq a(%rip), %rdx
	movq %rdx, -20(%rbp)
#6. 	parameter t2
	movq -20(%rbp), %rdx
	push %rdx
#7. 	t3= CALL readInt 1
	call readInt
	movl %eax, -24(%rbp)
#8. 	t4= "Enter number b: "
	leaq .LC1(%rip), %rdx
	movq %rdx, -32(%rbp)
#9. 	parameter t4
	movq -32(%rbp), %rdx
	push %rdx
#10. 	t5= CALL printStr 1
	call printStr
	movl %eax, -36(%rbp)
#11. 	t6= &b
	leaq b(%rip), %rdx
	movq %rdx, -44(%rbp)
#12. 	parameter t6
	movq -44(%rbp), %rdx
	push %rdx
#13. 	t7= CALL readInt 1
	call readInt
	movl %eax, -48(%rbp)
#14. 	t8= "Sum of a and b is: "
	leaq .LC2(%rip), %rdx
	movq %rdx, -56(%rbp)
#15. 	parameter t8
	movq -56(%rbp), %rdx
	push %rdx
#16. 	t9= CALL printStr 1
	call printStr
	movl %eax, -60(%rbp)
#17. 	t10= a+b
	movl a(%rip), %edx
	addl b(%rip), %edx
	movl %edx, -64(%rbp)
#18. 	parameter t10
	movl -64(%rbp), %edx
	push %rdx
#19. 	t11= CALL printInt 1
	call printInt
	movl %eax, -68(%rbp)
#20. 	t12= "\n"
	leaq .LC3(%rip), %rdx
	movq %rdx, -76(%rbp)
#21. 	parameter t12
	movq -76(%rbp), %rdx
	push %rdx
#22. 	t13= CALL printStr 1
	call printStr
	movl %eax, -80(%rbp)
#23. 	t14= "Diff of a and b is: "
	leaq .LC4(%rip), %rdx
	movq %rdx, -88(%rbp)
#24. 	parameter t14
	movq -88(%rbp), %rdx
	push %rdx
#25. 	t15= CALL printStr 1
	call printStr
	movl %eax, -92(%rbp)
#26. 	t16= a-b
	movl a(%rip), %edx
	subl b(%rip), %edx
	movl %edx, -96(%rbp)
#27. 	parameter t16
	movl -96(%rbp), %edx
	push %rdx
#28. 	t17= CALL printInt 1
	call printInt
	movl %eax, -100(%rbp)
#29. 	t18= "\n"
	leaq .LC5(%rip), %rdx
	movq %rdx, -108(%rbp)
#30. 	parameter t18
	movq -108(%rbp), %rdx
	push %rdx
#31. 	t19= CALL printStr 1
	call printStr
	movl %eax, -112(%rbp)
#32. 	t20= "Mult of a and b is: "
	leaq .LC6(%rip), %rdx
	movq %rdx, -120(%rbp)
#33. 	parameter t20
	movq -120(%rbp), %rdx
	push %rdx
#34. 	t21= CALL printStr 1
	call printStr
	movl %eax, -124(%rbp)
#35. 	t22= a*b
	movl a(%rip), %edx
	imull b(%rip), %edx
	movl %edx, -128(%rbp)
#36. 	parameter t22
	movl -128(%rbp), %edx
	push %rdx
#37. 	t23= CALL printInt 1
	call printInt
	movl %eax, -132(%rbp)
#38. 	t24= "\n"
	leaq .LC7(%rip), %rdx
	movq %rdx, -140(%rbp)
#39. 	parameter t24
	movq -140(%rbp), %rdx
	push %rdx
#40. 	t25= CALL printStr 1
	call printStr
	movl %eax, -144(%rbp)
#41. END FUNCTION
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
