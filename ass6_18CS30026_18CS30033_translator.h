#pragma once
#include<cstring>
#include<iostream>
#include<vector>
#include<string>
#include<algorithm>

// size of data types
#define PTR_SIZE        8
#define CHAR_SIZE       1
#define INT_SIZE        4  
#define FLOAT_SIZE      8

// Data types
enum class TYPE
{
    VOID,
    INT,
    CHAR,
    FLOAT,
};

// types of symbol table elements
enum class SYM_TYPE
{
    VARIABLE,
    FUNCTION,
    INT_CONST,
    CHAR_CONST,
    FLOAT_CONST,
    STRING_CONST,

    // In case no type has been assigned to identifier yet:
    EMPTY_ID  
};

// Compound Data types like arrays and pointers
struct Type
{
    TYPE type;
    int pointers=0;
    std::vector<int> dimension;
};

// Data type of function
struct FunctionType
{
    std::string name;
    Type retType;
    std::vector<Type> parameters;
};

// Symbol table element (an entry of symbol table)
struct SymTabElem
{
    SYM_TYPE symType;   

    // Variable or EMPTY_ID
    std::string name;
    Type type;
    int size=0, offset=0, isGlobal=0;

    // Function
    struct SymTab* func;

    // Integer constant
    int intConst;

    // Character constant
    char charConst;

    // Float constant
    float floatConst;

    // String constant
    int id;

    // Pointer to symbol table element is presant in
    struct SymTab* symTabPtr=NULL;
};

/*******************  Symbol Table data structure with supporting functions **************/

// Symbol Table
//stores offsets, parent, for each entry (variable or function)
struct SymTab
{
    FunctionType func;
    std::vector<SymTabElem*> table;
    SymTab* parent= NULL;
    SymTab* funcSym;
    int offset=0;
    int maxOffset=0;
    int cnt=0;
    //prints symtab on console
    void print();
};
//functionality
SymTabElem* symlook(std::string id, SymTab* symTab);
SymTabElem* lookup(std::string id);

// this is equivalet to update
SymTabElem* setType(SymTabElem* elem, Type type);
SymTabElem* genTemp(Type type);
SymTabElem* setTypeParam(SymTabElem* elem, Type type);

/*********************** Symbol Table Data Structure end *******************************/

// Attributes for expression
struct Exp
{
    SymTabElem* loc;
    int isDeref, isBool;
    std::vector<int> trueList, falseList;
};

// Attributes for function argument
struct Arg
{
    std::vector<SymTabElem*> args;
};


// enum class to store operators like a*b , a-b, *a, -a, etc
enum class OPERATOR
{
    PLUS,
    MINUS,
    MULT,
    DIV,
    ASSIGN,
    UMINUS,
    UPLUS,
    PRINT,
    ADDRESS,
    DE_REF_R,
    DE_REF_L,
    JUMP,
    COND_JUMP,
    LT,
    GT,
    CALL,
    FUNC,
    ENDFUNC,
    PARAMETER,
    RETURN,
    TYPE_CONV,
    EMPTY,
    BIT_NOT,
    MOD,
    L_SHIFT,
    R_SHIFT,
    LE,
    GE,
    EQEQ,
    NEQ,
    BIT_AND,
    BIT_XOR,
    BIT_OR,
    MEMORY
};

/********************** Quad Array Datastructure *********************/

//Quad::print func print Quad array to output file
//emit pushes a quad to quad array

// structure to store quad
struct Quad
{
    OPERATOR op;
    SymTabElem *result, *arg1, *arg2;
    Quad(SymTabElem* result, SymTabElem* arg1, OPERATOR op, SymTabElem* arg2);
    void print(FILE* output);
};
void emit(SymTabElem* result, SymTabElem* arg1, OPERATOR op, SymTabElem* arg2);


/********************** Quad Array End ****************************/

int getSize(Type type);
int getMemory(Type type);
Type derefType(Type type);
Type refType(Type t);
SymTabElem* genIntConst(int val);
SymTabElem* genFloatConst(float val);
SymTabElem* genCharConst(char val);
SymTabElem* genStringConst(char* str);
void backPatch(std::vector<int> list, int label);
std::vector<int> merge(std::vector<int> a, std::vector<int> b);
std::vector<int> makeList(int id);
Type getIntType();
SymTabElem* getValExp(Exp a);
int isPtr(Type type);
void swap(SymTabElem** a, SymTabElem** b);
Type typeCheck(Type t1, Type t2);
SymTabElem* convType(SymTabElem* a, Type type);
std::string typeToStr(Type t);
void symPrint();


void redDeclExp(SymTabElem* id, Exp* e);
void redDeclArr(SymTabElem* id);
Exp* intToBool(Exp* a);
Exp* redExpAssign(Exp* a, Exp* b);
Exp* redExpOr(Exp* a, Exp* b, int m);
Exp* redExpAnd(Exp* a, Exp* b, int m);
Exp* redBinOp(Exp* a, OPERATOR op, Exp* b);
Exp* redUnaOp(OPERATOR op, Exp* a);
Exp* redPostInc(Exp* a);
Exp* redPreInc(Exp* a);
Exp* redPostDec(Exp* a);
Exp* redPreDec(Exp* a);
Exp* redExpNot(Exp *a);
Exp* redExpAddr(Exp* a);
Exp* redExpDeref(Exp* a);
Exp* redArrRef(Exp* a, Exp* n);
Exp* redExpConst(SymTabElem* n);
Exp* redExpTok(SymTabElem* token);
Exp* redExpCast(Exp* a);
int redN();
void redIf(Exp* b, int m);
void redIfElse(Exp* b, int m1, int n, int m2);
void redWhile(int m1, Exp* b, int m2, int n);
void redFor(int m1, Exp* b, int m2, int n1, int m3, int n2);
void redParameters(SymTabElem* id);
void setFuncScope();
void redFuncHead(SymTabElem* id);
void redFuncBody();
Arg* redArgs(Arg* args, Exp* exp);
Arg* redArgEmpty();
Exp* redFuncCall(SymTabElem* e, Arg* args);
void redReturn(Exp* r);
void redReturnVoid();
void redScope();
void endScope();
void initProg();

extern SymTab* curSymTab;
extern Type lastType;
extern std::vector<Quad> quads;
extern std::vector<SymTab*> symTabels;
extern std::vector<std::string> string_constants;
