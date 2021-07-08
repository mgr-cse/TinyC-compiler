	.data
	.text
.LC0:
	.string "Enter size of array: "
	.text

.LC1:
	.string "Enter a["
	.text

.LC2:
	.string "]: "
	.text

.LC3:
	.string "Sorted array is: "
	.text

.LC4:
	.string " "
	.text

.LC5:
	.string "\n"
	.text

#1. FUNCTION swap:
	.globl swap
	.type swap, @function
swap:
	push %rbp
	movq %rsp, %rbp
	subq $16, %rsp
#2. 	t0= *a
	movq 24(%rbp), %rdx
	movl (%rdx), %edi
	movl %edi, -8(%rbp)
#3. 	t= t0
	movl -8(%rbp), %edx
	movl %edx, -4(%rbp)
#4. 	t1= *b
	movq 16(%rbp), %rdx
	movl (%rdx), %edi
	movl %edi, -12(%rbp)
#5. 	*a= t1
	movl -12(%rbp), %edx
	movq 24(%rbp), %rdi
	movl %edx, (%rdi)
#6. 	*b= t
	movl -4(%rbp), %edx
	movq 16(%rbp), %rdi
	movl %edx, (%rdi)
#7. END FUNCTION
	leave
	ret

#9. FUNCTION bubble_sort:
	.globl bubble_sort
	.type bubble_sort, @function
bubble_sort:
	push %rbp
	movq %rsp, %rbp
	subq $176, %rsp
#10. 	t2= 0
	movl $0, -4(%rbp)
#11. 	t3= n==t2
	movl 16(%rbp), %edx
	cmpl -4(%rbp), %edx
	sete %al
	movzbl %al, %edx
	movl %edx, -8(%rbp)
#12. 	if t3 Jump 14
	cmpl $0, -8(%rbp)
	jne .M1
#13. 	Jump 15
	jmp .M2
.M1:
#14. 	return
	leave
	ret
.M2:
#15. 	t4= 1
	movl $1, -12(%rbp)
#16. 	t5= 4
	movl $4, -16(%rbp)
#17. 	t5= t4*t5
	movl -12(%rbp), %edx
	imull -16(%rbp), %edx
	movl %edx, -16(%rbp)
#18. 	t6= (ptr)t5
	movslq -16(%rbp), %rdx
	movq %rdx, -24(%rbp)
#19. 	t7= a+t6
	movq 24(%rbp), %rdx
	addq -24(%rbp), %rdx
	movq %rdx, -32(%rbp)
#20. 	t8= 1
	movl $1, -36(%rbp)
#21. 	t9= n-t8
	movl 16(%rbp), %edx
	subl -36(%rbp), %edx
	movl %edx, -40(%rbp)
#22. 	parameter t7
	movq -32(%rbp), %rdx
	push %rdx
#23. 	parameter t9
	movl -40(%rbp), %edx
	push %rdx
#24. 	t10= CALL bubble_sort 2
	call bubble_sort
#25. 	t11= 1
	movl $1, -48(%rbp)
#26. 	i= t11
	movl -48(%rbp), %edx
	movl %edx, -44(%rbp)
.M5:
#27. 	t12= i<n
	movl -44(%rbp), %edx
	cmpl 16(%rbp), %edx
	setl %al
	movzbl %al, %edx
	movl %edx, -52(%rbp)
#28. 	if t12 Jump 35
	cmpl $0, -52(%rbp)
	jne .M3
#29. 	Jump 67
	jmp .M4
.M8:
#30. 	t13= i
	movl -44(%rbp), %edx
	movl %edx, -56(%rbp)
#31. 	t14= 1
	movl $1, -60(%rbp)
#32. 	t15= t14+i
	movl -60(%rbp), %edx
	addl -44(%rbp), %edx
	movl %edx, -64(%rbp)
#33. 	i= t15
	movl -64(%rbp), %edx
	movl %edx, -44(%rbp)
#34. 	Jump 27
	jmp .M5
.M3:
#35. 	t16= 1
	movl $1, -68(%rbp)
#36. 	t17= i-t16
	movl -44(%rbp), %edx
	subl -68(%rbp), %edx
	movl %edx, -72(%rbp)
#37. 	t19= 4
	movl $4, -84(%rbp)
#38. 	t19= t17*t19
	movl -72(%rbp), %edx
	imull -84(%rbp), %edx
	movl %edx, -84(%rbp)
#39. 	t18= (ptr)t19
	movslq -84(%rbp), %rdx
	movq %rdx, -80(%rbp)
#40. 	t18= t18+a
	movq -80(%rbp), %rdx
	addq 24(%rbp), %rdx
	movq %rdx, -80(%rbp)
#41. 	t21= 4
	movl $4, -96(%rbp)
#42. 	t21= i*t21
	movl -44(%rbp), %edx
	imull -96(%rbp), %edx
	movl %edx, -96(%rbp)
#43. 	t20= (ptr)t21
	movslq -96(%rbp), %rdx
	movq %rdx, -92(%rbp)
#44. 	t20= t20+a
	movq -92(%rbp), %rdx
	addq 24(%rbp), %rdx
	movq %rdx, -92(%rbp)
#45. 	t22= *t18
	movq -80(%rbp), %rdx
	movl (%rdx), %edi
	movl %edi, -100(%rbp)
#46. 	t23= *t20
	movq -92(%rbp), %rdx
	movl (%rdx), %edi
	movl %edi, -104(%rbp)
#47. 	t24= t22>t23
	movl -100(%rbp), %edx
	cmpl -104(%rbp), %edx
	setg %al
	movzbl %al, %edx
	movl %edx, -108(%rbp)
#48. 	if t24 Jump 50
	cmpl $0, -108(%rbp)
	jne .M6
#49. 	Jump 66
	jmp .M7
.M6:
#50. 	t25= 4
	movl $4, -112(%rbp)
#51. 	t25= i*t25
	movl -44(%rbp), %edx
	imull -112(%rbp), %edx
	movl %edx, -112(%rbp)
#52. 	t26= (ptr)t25
	movslq -112(%rbp), %rdx
	movq %rdx, -120(%rbp)
#53. 	t27= a+t26
	movq 24(%rbp), %rdx
	addq -120(%rbp), %rdx
	movq %rdx, -128(%rbp)
#54. 	t28= 1
	movl $1, -132(%rbp)
#55. 	t29= 4
	movl $4, -136(%rbp)
#56. 	t29= t28*t29
	movl -132(%rbp), %edx
	imull -136(%rbp), %edx
	movl %edx, -136(%rbp)
#57. 	t30= (ptr)t29
	movslq -136(%rbp), %rdx
	movq %rdx, -144(%rbp)
#58. 	t31= t27-t30
	movq -128(%rbp), %rdx
	subq -144(%rbp), %rdx
	movq %rdx, -152(%rbp)
#59. 	t32= 4
	movl $4, -156(%rbp)
#60. 	t32= i*t32
	movl -44(%rbp), %edx
	imull -156(%rbp), %edx
	movl %edx, -156(%rbp)
#61. 	t33= (ptr)t32
	movslq -156(%rbp), %rdx
	movq %rdx, -164(%rbp)
#62. 	t34= a+t33
	movq 24(%rbp), %rdx
	addq -164(%rbp), %rdx
	movq %rdx, -172(%rbp)
#63. 	parameter t31
	movq -152(%rbp), %rdx
	push %rdx
#64. 	parameter t34
	movq -172(%rbp), %rdx
	push %rdx
#65. 	t35= CALL swap 2
	call swap
.M7:
#66. 	Jump 30
	jmp .M8
.M4:
#67. END FUNCTION
	leave
	ret

#69. FUNCTION main:
	.globl main
	.type main, @function
main:
	push %rbp
	movq %rsp, %rbp
	subq $4128, %rsp
#70. 	t36= "Enter size of array: "
	leaq .LC0(%rip), %rdx
	movq %rdx, -16(%rbp)
#71. 	parameter t36
	movq -16(%rbp), %rdx
	push %rdx
#72. 	t37= CALL printStr 1
	call printStr
	movl %eax, -20(%rbp)
#73. 	t38= &n
	leaq -4(%rbp), %rdx
	movq %rdx, -28(%rbp)
#74. 	parameter t38
	movq -28(%rbp), %rdx
	push %rdx
#75. 	t39= CALL readInt 1
	call readInt
	movl %eax, -32(%rbp)
#76. 	a= memory 4000
	movq %rbp, %rdx
	subq $4040, %rdx
	movq %rdx, -40(%rbp)
#77. 	t40= 0
	movl $0, -4044(%rbp)
#78. 	i= t40
	movl -4044(%rbp), %edx
	movl %edx, -8(%rbp)
.M11:
#79. 	t41= i<n
	movl -8(%rbp), %edx
	cmpl -4(%rbp), %edx
	setl %al
	movzbl %al, %edx
	movl %edx, -4048(%rbp)
#80. 	if t41 Jump 87
	cmpl $0, -4048(%rbp)
	jne .M9
#81. 	Jump 102
	jmp .M10
.M12:
#82. 	t42= i
	movl -8(%rbp), %edx
	movl %edx, -4052(%rbp)
#83. 	t43= 1
	movl $1, -4056(%rbp)
#84. 	t44= t43+i
	movl -4056(%rbp), %edx
	addl -8(%rbp), %edx
	movl %edx, -4060(%rbp)
#85. 	i= t44
	movl -4060(%rbp), %edx
	movl %edx, -8(%rbp)
#86. 	Jump 79
	jmp .M11
.M9:
#87. 	t45= "Enter a["
	leaq .LC1(%rip), %rdx
	movq %rdx, -4068(%rbp)
#88. 	parameter t45
	movq -4068(%rbp), %rdx
	push %rdx
#89. 	t46= CALL printStr 1
	call printStr
	movl %eax, -4072(%rbp)
#90. 	parameter i
	movl -8(%rbp), %edx
	push %rdx
#91. 	t47= CALL printInt 1
	call printInt
	movl %eax, -4076(%rbp)
#92. 	t48= "]: "
	leaq .LC2(%rip), %rdx
	movq %rdx, -4084(%rbp)
#93. 	parameter t48
	movq -4084(%rbp), %rdx
	push %rdx
#94. 	t49= CALL printStr 1
	call printStr
	movl %eax, -4088(%rbp)
#95. 	t50= 4
	movl $4, -4092(%rbp)
#96. 	t50= i*t50
	movl -8(%rbp), %edx
	imull -4092(%rbp), %edx
	movl %edx, -4092(%rbp)
#97. 	t51= (ptr)t50
	movslq -4092(%rbp), %rdx
	movq %rdx, -4100(%rbp)
#98. 	t52= a+t51
	movq -40(%rbp), %rdx
	addq -4100(%rbp), %rdx
	movq %rdx, -4108(%rbp)
#99. 	parameter t52
	movq -4108(%rbp), %rdx
	push %rdx
#100. 	t53= CALL readInt 1
	call readInt
	movl %eax, -4112(%rbp)
#101. 	Jump 82
	jmp .M12
.M10:
#102. 	parameter a
	movq -40(%rbp), %rdx
	push %rdx
#103. 	parameter n
	movl -4(%rbp), %edx
	push %rdx
#104. 	t54= CALL bubble_sort 2
	call bubble_sort
#105. 	t55= "Sorted array is: "
	leaq .LC3(%rip), %rdx
	movq %rdx, -4068(%rbp)
#106. 	parameter t55
	movq -4068(%rbp), %rdx
	push %rdx
#107. 	t56= CALL printStr 1
	call printStr
	movl %eax, -4072(%rbp)
#108. 	t57= 0
	movl $0, -4076(%rbp)
#109. 	i= t57
	movl -4076(%rbp), %edx
	movl %edx, -8(%rbp)
.M15:
#110. 	t58= i<n
	movl -8(%rbp), %edx
	cmpl -4(%rbp), %edx
	setl %al
	movzbl %al, %edx
	movl %edx, -4080(%rbp)
#111. 	if t58 Jump 118
	cmpl $0, -4080(%rbp)
	jne .M13
#112. 	Jump 129
	jmp .M14
.M16:
#113. 	t59= i
	movl -8(%rbp), %edx
	movl %edx, -4084(%rbp)
#114. 	t60= 1
	movl $1, -4088(%rbp)
#115. 	t61= t60+i
	movl -4088(%rbp), %edx
	addl -8(%rbp), %edx
	movl %edx, -4092(%rbp)
#116. 	i= t61
	movl -4092(%rbp), %edx
	movl %edx, -8(%rbp)
#117. 	Jump 110
	jmp .M15
.M13:
#118. 	t63= 4
	movl $4, -4104(%rbp)
#119. 	t63= i*t63
	movl -8(%rbp), %edx
	imull -4104(%rbp), %edx
	movl %edx, -4104(%rbp)
#120. 	t62= (ptr)t63
	movslq -4104(%rbp), %rdx
	movq %rdx, -4100(%rbp)
#121. 	t62= t62+a
	movq -4100(%rbp), %rdx
	addq -40(%rbp), %rdx
	movq %rdx, -4100(%rbp)
#122. 	t64= *t62
	movq -4100(%rbp), %rdx
	movl (%rdx), %edi
	movl %edi, -4108(%rbp)
#123. 	parameter t64
	movl -4108(%rbp), %edx
	push %rdx
#124. 	t65= CALL printInt 1
	call printInt
	movl %eax, -4112(%rbp)
#125. 	t66= " "
	leaq .LC4(%rip), %rdx
	movq %rdx, -4120(%rbp)
#126. 	parameter t66
	movq -4120(%rbp), %rdx
	push %rdx
#127. 	t67= CALL printStr 1
	call printStr
	movl %eax, -4124(%rbp)
#128. 	Jump 113
	jmp .M16
.M14:
#129. 	t68= "\n"
	leaq .LC5(%rip), %rdx
	movq %rdx, -4100(%rbp)
#130. 	parameter t68
	movq -4100(%rbp), %rdx
	push %rdx
#131. 	t69= CALL printStr 1
	call printStr
	movl %eax, -4104(%rbp)
#132. END FUNCTION
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
