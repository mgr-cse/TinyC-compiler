#include "ass6_18CS30026_18CS30033_translator.h"

// sp can only be shifted by mul of PTR_SIZE
int getCeil(int offset)
{
    return PTR_SIZE*((offset+PTR_SIZE-1)/PTR_SIZE);
}

// get the name of register in gas assembly
std::string getReg(int reg, int size)
{
    switch (reg)
    {
        case 0:
            switch (size)
            {
                case 1: return "%al";
                case 4: return "%eax";
                case 8: return "%rax";
            }
        case 1:
            switch (size)
            {
                case 1: return "%dl";
                case 4: return "%edx";
                case 8: return "%rdx";
            }
        case 2:
            switch (size)
            {
                case 1: return "%dil";
                case 4: return "%edi";
                case 8: return "%rdi";
            }
    }
    return "ERROR";
}


// handles activation record:
// 1. If variable is local  returns offset in gas 
// 2. If variable is global returns ptr to instruction
// 3. If variable is parameter nothing special has to be done
//    as the symbol table was made in that way.
// regarding flattening of symbol table that was handled in IR code gen itself
std::string getAsmVar(SymTabElem* a)
{
    if(a->symTabPtr->parent)
    {
        int n=-a->offset-a->size;
        return std::to_string(n)+"(%rbp)";
    }
    return a->name+"(%rip)";
}


// retuns suffix of instruction depending of size of data
std::string suffix(int size)
{
    switch (size)
    {
        case 1: return "b";
        case 4: return "l";
        case 8: return "q";
    }
    return "error";
}

// jump labels assigned to quads
std::vector<int> label;

// assigns jump labels
void assignLabel()
{
    label= std::vector<int>(quads.size());
    int l=0;
    for(Quad quad: quads)
        if(quad.op==OPERATOR::JUMP or quad.op==OPERATOR::COND_JUMP)
            if(!label[quad.result->intConst])
                label[quad.result->intConst]= ++l;
}

// gas code (64 bit) generation
std::string toAsm(Quad quad)
{   
    std::string s;
    int n, m;
    if(quad.result)
        n= quad.result->size;
    switch(quad.op)
    {
        // prologue
        case OPERATOR::FUNC:
            s+= "\t.globl "+quad.result->name+"\n\t.type "+quad.result->name+", @function\n";
            s+=  quad.result->name+":\n";
            s+= "\tpush %rbp\n";
            s+= "\tmovq %rsp, %rbp\n";
            s+= "\tsubq $";
            s+= std::to_string(getCeil(quad.result->func->maxOffset));
            s+= ", %rsp\n";
            return s;
        
        // epilogue
        case OPERATOR::ENDFUNC:
            s+= "\tleave\n";
            s+= "\tret\n";
            return s;
        
        // retunr value
        case OPERATOR::RETURN:
            if(quad.result)
                s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.result)+", "+getReg(0, n)+"\n";
            s+= "\tleave\n";
            s+= "\tret\n";
            return s;
        
        // Arthmetic operators
        case OPERATOR::PLUS:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tadd"+suffix(n)+" "+getAsmVar(quad.arg2)+", "+getReg(1, n)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+ getAsmVar(quad.result)+"\n";
            return s;
        
        case OPERATOR::MINUS:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tsub"+suffix(n)+" "+getAsmVar(quad.arg2)+", "+getReg(1, n)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+ getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::MULT:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\timul"+suffix(n)+" "+getAsmVar(quad.arg2)+", "+getReg(1, n)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+ getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::DIV:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(0, n)+"\n";
            s+= "\tcltd\n";
            s+= "\tidiv"+suffix(n)+" "+getAsmVar(quad.arg2)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(0, n)+", "+ getAsmVar(quad.result)+"\n";
            return s;

        // Handling constants
        case OPERATOR::ASSIGN:
            // integer constant are simply moved
            if(quad.arg1->symType==SYM_TYPE::INT_CONST)
            {
                s+= "\tmov"+suffix(n)+" $"+std::to_string(quad.arg1->intConst);
                s+=", "+ getAsmVar(quad.result)+"\n";
                return s;
            }
            // char constants are converted to ascii value
            else if(quad.arg1->symType==SYM_TYPE::CHAR_CONST)
            {
                s+= "\tmov"+suffix(n)+" $"+std::to_string((int)quad.arg1->charConst);
                s+=", "+ getAsmVar(quad.result)+"\n";
                return s;
            }
            // strings are stored in . text segment
            else if(quad.arg1->symType==SYM_TYPE::STRING_CONST)
            {
                s+= "\tleaq .LC"+std::to_string(quad.arg1->id)+"(%rip), "+getReg(1, PTR_SIZE)+"\n";
                s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
                return s;
            }
            else
            {
                s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
                s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
                return s;
            }
        
        case OPERATOR::PARAMETER:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.result)+", "+getReg(1, n)+"\n";
            s+= "\tpush %rdx\n";
            return s;
        
        case OPERATOR::CALL:
            s+= "\tcall "+quad.arg1->name+"\n";
            if(quad.result->type.type!=TYPE::VOID or quad.result->type.pointers>0)
                s+= "\tmov"+suffix(n)+" "+getReg(0, n)+", "+getAsmVar(quad.result)+"\n";
            return s;
        
        case OPERATOR::LT:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tcmp"+suffix(n)+" "+getAsmVar(quad.arg2)+", "+getReg(1, n)+"\n";
            s+= "\tsetl "+ getReg(0, 1)+"\n";
            s+= "\tmovzbl "+getReg(0, 1)+", "+getReg(1, 4)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::LE:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tcmp"+suffix(n)+" "+getAsmVar(quad.arg2)+", "+getReg(1, n)+"\n";
            s+= "\tsetle "+ getReg(0, 1)+"\n";
            s+= "\tmovzbl "+getReg(0, 1)+", "+getReg(1, 4)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::GT:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tcmp"+suffix(n)+" "+getAsmVar(quad.arg2)+", "+getReg(1, n)+"\n";
            s+= "\tsetg "+ getReg(0, 1)+"\n";
            s+= "\tmovzbl "+getReg(0, 1)+", "+getReg(1, 4)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::GE:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tcmp"+suffix(n)+" "+getAsmVar(quad.arg2)+", "+getReg(1, n)+"\n";
            s+= "\tsetge "+ getReg(0, 1)+"\n";
            s+= "\tmovzbl "+getReg(0, 1)+", "+getReg(1, 4)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::EQEQ:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tcmp"+suffix(n)+" "+getAsmVar(quad.arg2)+", "+getReg(1, n)+"\n";
            s+= "\tsete "+ getReg(0, 1)+"\n";
            s+= "\tmovzbl "+getReg(0, 1)+", "+getReg(1, 4)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::NEQ:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tcmp"+suffix(n)+" "+getAsmVar(quad.arg2)+", "+getReg(1, n)+"\n";
            s+= "\tsetne "+ getReg(0, 1)+"\n";
            s+= "\tmovzbl "+getReg(0, 1)+", "+getReg(1, 4)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::MOD:
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(0, n)+"\n";
            s+= "\tcltd\n";
            s+= "\tidiv"+suffix(n)+" "+getAsmVar(quad.arg2)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+ getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::ADDRESS:
            s+= "\tleaq "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::JUMP:
            s+= "\tjmp .M"+std::to_string(label[quad.result->intConst])+"\n";
            return s;
        
        case OPERATOR::COND_JUMP:
            s+= "\tcmp"+suffix(quad.arg1->size)+" $0, "+getAsmVar(quad.arg1)+"\n";
            s+= "\tjne .M"+std::to_string(label[quad.result->intConst])+"\n";
            return s;
        
        // Assigns memory to pointers
        case OPERATOR::MEMORY:
            s+= "\tmovq %rbp, "+getReg(1, PTR_SIZE)+"\n";
            s+= "\tsub"+suffix(PTR_SIZE)+" $";
            s+= std::to_string(quad.result->offset+quad.result->size+getMemory(quad.result->type));
            s+= ", "+getReg(1, PTR_SIZE)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::DE_REF_L:
            n= quad.arg1->size;
            m= PTR_SIZE;
            s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tmov"+suffix(m)+" "+getAsmVar(quad.result)+", "+getReg(2, m)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", ("+getReg(2, m)+")\n";
            return s;
        
        case OPERATOR::DE_REF_R:
            n= quad.result->size;
            m= PTR_SIZE;
            s+= "\tmov"+suffix(m)+" "+getAsmVar(quad.arg1)+", "+getReg(1, m)+"\n";
            s+= "\tmov"+suffix(n)+" "+"("+getReg(1, m)+"), "+getReg(2, n)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(2, n)+", "+getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::EMPTY:
            return "\n";
        
        case OPERATOR::UMINUS:
            s+= "\tmov"+suffix(n)+" $0"+", "+getReg(1, n)+"\n";
            s+= "\tsub"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+ getAsmVar(quad.result)+"\n";
            return s;
        
        case OPERATOR::UPLUS:
            s+= "\tmov"+suffix(n)+" $0"+", "+getReg(1, n)+"\n";
            s+= "\tadd"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+ getAsmVar(quad.result)+"\n";
            return s;

        case OPERATOR::TYPE_CONV:
            n= quad.result->size;
            m= quad.arg1->size;
            if(n<=m)
            {
                s+= "\tmov"+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
                s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
                return s;
            }
            s+= "\tmovs"+suffix(m)+suffix(n)+" "+getAsmVar(quad.arg1)+", "+getReg(1, n)+"\n";
            s+= "\tmov"+suffix(n)+" "+getReg(1, n)+", "+getAsmVar(quad.result)+"\n";
            return s;
    }
    return "****No rule found****\n";
}

//main function and lex requirements
extern int yyparse(void);
extern FILE* yyin;
extern int yydebug;
int yylex();
extern char* yytext;


int main(int argc, char* argv[])
{
    char outFname[200] = "quads.out";
    char inFname[200]= "test1.c";
    char outAsm[200] = "asm.s";

    if(argc<4)
    {
        printf("Enter test filename:");
        scanf("%s", inFname);
        printf("Enter quad output file name:");
        scanf("%s", outFname);
        printf("Enter assembly output file name:");
        scanf("%s", outAsm);
    }
    else{
        strcpy(inFname, argv[1]);
        strcpy(outFname, argv[2]);
        strcpy(outAsm, argv[3]);
    }

    yyin=fopen(inFname, "r"); 
    // yydebug=1;
    yyparse();
    
    //gen output file (quads)
    FILE* output= fopen(outFname, "w");
    for(Quad q: quads)
        q.print(output);
    fclose(output);
    fclose(yyin);
    std::cout << "printing all symbol tables...\n";
    symPrint();
    std::cout << "\n";
    
    // assign labels to jump instructions
    assignLabel();
    FILE* out= fopen(outAsm, "w");
    fprintf(out, "\t.data\n\t.text\n");

    // assigns label to global variables
    for(SymTabElem* e: curSymTab->table)
        if(e->symType==SYM_TYPE::VARIABLE)
            fprintf(out, "\t.comm %s, %d, %d\n", e->name.c_str(), e->size, e->size);
    
    // assigns labels to string constants
    for(int i=0; i<string_constants.size(); i++)
    {
        fprintf(out, ".LC%d:\n", i);
        fprintf(out, "\t.string %s\n", string_constants[i].c_str());
        fprintf(out, "\t.text\n\n");
    }

    // generates assembly
    for(int i=0; i<quads.size(); i++)
    {
        Quad q=quads[i];
        if(label[i])
            fprintf(out, ".M%d:\n", label[i]);
        if(q.op!=OPERATOR::EMPTY)
        {
            fprintf(out, "#%d. ", i+1);
            q.print(out);
        }
        fprintf(out, "%s", toAsm(q).c_str());
    }

    // Inline assembly for functions:
    std::string s=

"##################### Assembly for header function ########################\n\
\n\
	.globl	__putchar\n\
	.type	__putchar, @function\n\
__putchar:\n\
	pushq	%rbp\n\
	movq	%rsp, %rbp\n\
	movl	%edi, %eax\n\
	movb	%al, -4(%rbp)\n\
	leaq	-4(%rbp), %rax\n\
	movq	%rax, %rsi\n\
	movq %rsi, %rsi\n\
	movq $1, %rdx\n\
	movl $1, %eax\n\
	movq $1, %rdi\n\
	syscall\n\
	nop\n\
	popq	%rbp\n\
	ret\n\
	.size	__putchar, .-__putchar\n\
	.globl	__getchar\n\
	.type	__getchar, @function\n\
__getchar:\n\
	pushq	%rbp\n\
	movq	%rsp, %rbp\n\
	subq	$16, %rsp\n\
	movq	%fs:40, %rax\n\
	movq	%rax, -8(%rbp)\n\
	xorl	%eax, %eax\n\
	movb	$0, -9(%rbp)\n\
	leaq	-9(%rbp), %rax\n\
	movq	%rax, %rsi\n\
	movq %rsi, %rsi\n\
	movq $1, %rdx\n\
	movl $0, %eax\n\
	movq $0, %rdi\n\
	syscall\n\
	movzbl	-9(%rbp), %eax\n\
	movq	-8(%rbp), %rdx\n\
	xorq	%fs:40, %rdx\n\
	je	.L4\n\
	call	__stack_chk_fail@PLT\n\
.L4:\n\
	leave\n\
	ret\n\
	.size	__getchar, .-__getchar\n\
	.globl	printStr\n\
	.type	printStr, @function\n\
printStr:\n\
	pushq	%rbp\n\
	movq	%rsp, %rbp\n\
	movq 	16(%rbp), %rdi\n\
	subq	$8, %rsp\n\
	movq	%rdi, -8(%rbp)\n\
	jmp	.L6\n\
.L7:\n\
	movq	-8(%rbp), %rax\n\
	leaq	1(%rax), %rdx\n\
	movq	%rdx, -8(%rbp)\n\
	movzbl	(%rax), %eax\n\
	movsbl	%al, %eax\n\
	movl	%eax, %edi\n\
	call	__putchar\n\
.L6:\n\
	movq	-8(%rbp), %rax\n\
	movzbl	(%rax), %eax\n\
	testb	%al, %al\n\
	jne	.L7\n\
	nop\n\
	nop\n\
	leave\n\
	ret\n\
	.size	printStr, .-printStr\n\
	.globl	_printInt\n\
	.type	_printInt, @function\n\
_printInt:\n\
	pushq	%rbp\n\
	movq	%rsp, %rbp\n\
	subq	$16, %rsp\n\
	movl	%edi, -4(%rbp)\n\
	cmpl	$0, -4(%rbp)\n\
	je	.L11\n\
	movl	-4(%rbp), %eax\n\
	movslq	%eax, %rdx\n\
	imulq	$1717986919, %rdx, %rdx\n\
	shrq	$32, %rdx\n\
	sarl	$2, %edx\n\
	sarl	$31, %eax\n\
	subl	%eax, %edx\n\
	movl	%edx, %eax\n\
	movl	%eax, %edi\n\
	call	_printInt\n\
	movl	-4(%rbp), %ecx\n\
	movslq	%ecx, %rax\n\
	imulq	$1717986919, %rax, %rax\n\
	shrq	$32, %rax\n\
	movl	%eax, %edx\n\
	sarl	$2, %edx\n\
	movl	%ecx, %eax\n\
	sarl	$31, %eax\n\
	subl	%eax, %edx\n\
	movl	%edx, %eax\n\
	sall	$2, %eax\n\
	addl	%edx, %eax\n\
	addl	%eax, %eax\n\
	subl	%eax, %ecx\n\
	movl	%ecx, %edx\n\
	movl	%edx, %eax\n\
	addl	$48, %eax\n\
	movsbl	%al, %eax\n\
	movl	%eax, %edi\n\
	call	__putchar\n\
	jmp	.L8\n\
.L11:\n\
	nop\n\
.L8:\n\
	leave\n\
	ret\n\
	.size	_printInt, .-_printInt\n\
	.globl	printInt\n\
	.type	printInt, @function\n\
printInt:\n\
	pushq	%rbp\n\
	movq	%rsp, %rbp\n\
	movl 	16(%rbp), %edi\n\
	subq	$16, %rsp\n\
	movl	%edi, -4(%rbp)\n\
	cmpl	$0, -4(%rbp)\n\
	jns	.L13\n\
	movl	$45, %edi\n\
	call	__putchar\n\
	movl	-4(%rbp), %eax\n\
	negl	%eax\n\
	movl	%eax, %edi\n\
	call	_printInt\n\
	jmp	.L16\n\
.L13:\n\
	cmpl	$0, -4(%rbp)\n\
	jne	.L15\n\
	movl	$48, %edi\n\
	call	__putchar\n\
	jmp	.L16\n\
.L15:\n\
	movl	-4(%rbp), %eax\n\
	movl	%eax, %edi\n\
	call	_printInt\n\
.L16:\n\
	nop\n\
	leave\n\
	ret\n\
	.size	printInt, .-printInt\n\
	.globl	readInt\n\
	.type	readInt, @function\n\
readInt:\n\
	pushq	%rbp\n\
	movq	%rsp, %rbp\n\
	subq	$32, %rsp\n\
	movq 	16(%rbp), %rdi\n\
	movq	%rdi, -24(%rbp)\n\
	movl	$1, -4(%rbp)\n\
	movq	-24(%rbp), %rax\n\
	movl	$0, (%rax)\n\
	movl	$0, %eax\n\
	call	__getchar\n\
	movb	%al, -5(%rbp)\n\
	jmp	.L18\n\
.L22:\n\
	cmpb	$45, -5(%rbp)\n\
	jne	.L19\n\
	movl	$-1, -4(%rbp)\n\
	jmp	.L20\n\
.L19:\n\
	movq	-24(%rbp), %rax\n\
	movl	(%rax), %edx\n\
	movl	%edx, %eax\n\
	sall	$2, %eax\n\
	addl	%edx, %eax\n\
	addl	%eax, %eax\n\
	movl	%eax, %edx\n\
	movsbl	-5(%rbp), %eax\n\
	addl	%edx, %eax\n\
	leal	-48(%rax), %edx\n\
	movq	-24(%rbp), %rax\n\
	movl	%edx, (%rax)\n\
.L20:\n\
	movl	$0, %eax\n\
	call	__getchar\n\
	movb	%al, -5(%rbp)\n\
.L18:\n\
	cmpb	$57, -5(%rbp)\n\
	jg	.L21\n\
	cmpb	$47, -5(%rbp)\n\
	jg	.L22\n\
.L21:\n\
	cmpb	$45, -5(%rbp)\n\
	je	.L22\n\
	movq	-24(%rbp), %rax\n\
	movl	(%rax), %eax\n\
	imull	-4(%rbp), %eax\n\
	movl	%eax, %edx\n\
	movq	-24(%rbp), %rax\n\
	movl	%edx, (%rax)\n\
	nop\n\
	leave\n\
	ret\n";
    fprintf(out, "%s", s.c_str());
    fclose(out);
}