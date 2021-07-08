	.data
	.text
	.comm a, 4, 4
.LC0:
	.string "a in global scope is: "
	.text

.LC1:
	.string "\n"
	.text

.LC2:
	.string "a local nested one is: "
	.text

.LC3:
	.string "\n"
	.text

.LC4:
	.string "a local nested zero is: "
	.text

.LC5:
	.string "\n"
	.text

#1. FUNCTION print:
	.globl print
	.type print, @function
print:
	push %rbp
	movq %rsp, %rbp
	subq $32, %rsp
#2. 	t0= 5
	movl $5, -4(%rbp)
#3. 	a= t0
	movl -4(%rbp), %edx
	movl %edx, a(%rip)
#4. 	t1= "a in global scope is: "
	leaq .LC0(%rip), %rdx
	movq %rdx, -12(%rbp)
#5. 	parameter t1
	movq -12(%rbp), %rdx
	push %rdx
#6. 	t2= CALL printStr 1
	call printStr
	movl %eax, -16(%rbp)
#7. 	parameter a
	movl a(%rip), %edx
	push %rdx
#8. 	t3= CALL printInt 1
	call printInt
	movl %eax, -20(%rbp)
#9. 	t4= "\n"
	leaq .LC1(%rip), %rdx
	movq %rdx, -28(%rbp)
#10. 	parameter t4
	movq -28(%rbp), %rdx
	push %rdx
#11. 	t5= CALL printStr 1
	call printStr
	movl %eax, -32(%rbp)
#12. END FUNCTION
	leave
	ret

#14. FUNCTION main:
	.globl main
	.type main, @function
main:
	push %rbp
	movq %rsp, %rbp
	subq $48, %rsp
#15. 	t6= 7
	movl $7, -4(%rbp)
#16. 	a= t6
	movl -4(%rbp), %edx
	movl %edx, -8(%rbp)
#17. 	t7= 11
	movl $11, -12(%rbp)
#18. 	a= t7
	movl -12(%rbp), %edx
	movl %edx, -16(%rbp)
#19. 	t8= "a local nested one is: "
	leaq .LC2(%rip), %rdx
	movq %rdx, -24(%rbp)
#20. 	parameter t8
	movq -24(%rbp), %rdx
	push %rdx
#21. 	t9= CALL printStr 1
	call printStr
	movl %eax, -28(%rbp)
#22. 	parameter a
	movl -16(%rbp), %edx
	push %rdx
#23. 	t10= CALL printInt 1
	call printInt
	movl %eax, -32(%rbp)
#24. 	t11= "\n"
	leaq .LC3(%rip), %rdx
	movq %rdx, -40(%rbp)
#25. 	parameter t11
	movq -40(%rbp), %rdx
	push %rdx
#26. 	t12= CALL printStr 1
	call printStr
	movl %eax, -44(%rbp)
#27. 	t13= "a local nested zero is: "
	leaq .LC4(%rip), %rdx
	movq %rdx, -16(%rbp)
#28. 	parameter t13
	movq -16(%rbp), %rdx
	push %rdx
#29. 	t14= CALL printStr 1
	call printStr
	movl %eax, -20(%rbp)
#30. 	parameter a
	movl -8(%rbp), %edx
	push %rdx
#31. 	t15= CALL printInt 1
	call printInt
	movl %eax, -24(%rbp)
#32. 	t16= "\n"
	leaq .LC5(%rip), %rdx
	movq %rdx, -32(%rbp)
#33. 	parameter t16
	movq -32(%rbp), %rdx
	push %rdx
#34. 	t17= CALL printStr 1
	call printStr
	movl %eax, -36(%rbp)
#35. 	t18= CALL print 0
	call print
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
