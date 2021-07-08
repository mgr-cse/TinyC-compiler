#include "ass6_18CS30026_18CS30033_translator.h"

SymTab* curSymTab;
Type lastType;
// Array of quads
std::vector<Quad> quads;
std::vector<SymTab*> symTabels;
std::vector<std::string> string_constants;

// get size of give type in bytes
int getSize(Type type)
{
    if(type.pointers or type.dimension.size())
        return PTR_SIZE;

    switch(type.type)
    {
        case TYPE::CHAR:  return CHAR_SIZE;
        case TYPE::INT:   return INT_SIZE;
        case TYPE::FLOAT: return FLOAT_SIZE;
        default:  return 0;
    }
}

// Returns pointed data memory
int getMemory(Type type)
{
    int cnt=1;
    for(int d: type.dimension)
        cnt*= d;

    if(type.pointers)
        return cnt* PTR_SIZE;
    switch(type.type)
    {
        case TYPE::CHAR:  return cnt* CHAR_SIZE;
        case TYPE::INT:   return cnt* INT_SIZE;
        case TYPE::FLOAT: return cnt* FLOAT_SIZE;
        default:  return 0;
    }
}

// Recursively looks up id in symbol table
SymTabElem* symlook(std::string id, SymTab* symTab)
{
    for(SymTabElem* e: symTab->table)
        if(e->name==id)
            return e;
    if(symTab->parent==NULL)
        return NULL;
    return symlook(id, symTab->parent);
}

// Look up for id in symbol table insert if absent
SymTabElem* lookup(std::string id)
{
    SymTabElem* elem= symlook(id, curSymTab);
    if(elem) return elem;
    
    SymTabElem *e= new SymTabElem();
    e->name= id;
    e->symType = SYM_TYPE::EMPTY_ID;
    e->symTabPtr= curSymTab;
    curSymTab->table.push_back(e);
    return e;
}

// changes data type for empty to type
SymTabElem* setType(SymTabElem* elem, Type type)
{
    if(elem->symTabPtr!= curSymTab)
    {
        SymTabElem *e= new SymTabElem();
        e->name= elem->name;
        e->symTabPtr= curSymTab;
        curSymTab->table.push_back(e);
        elem= e;
    }
    elem->symType= SYM_TYPE::VARIABLE;
    elem->type= type;
    elem->size= getSize(type);
    elem->offset= curSymTab->offset;
    curSymTab->offset+= elem->size;
    if(curSymTab->funcSym->maxOffset < curSymTab->offset)
        curSymTab->funcSym->maxOffset= curSymTab->offset;
    elem->isGlobal= elem->symTabPtr->parent!=NULL;
    return elem;
}

// since in parameter stack offset must be mul of PTR_SIZE
SymTabElem* setTypeParam(SymTabElem* elem, Type type)
{
    if(elem->symTabPtr!= curSymTab)
    {
        SymTabElem *e= new SymTabElem();
        e->name= elem->name;
        e->symTabPtr= curSymTab;
        curSymTab->table.push_back(e);
        elem= e;
    }
    elem->symType= SYM_TYPE::VARIABLE;
    elem->type= type;
    elem->size= getSize(type);
    elem->offset= curSymTab->offset;
    curSymTab->offset+= PTR_SIZE; // Note the diff
    if(curSymTab->funcSym->maxOffset < curSymTab->offset)
        curSymTab->funcSym->maxOffset= curSymTab->offset;
    elem->isGlobal= elem->symTabPtr->parent!=NULL;
    return elem;
}

// generates new temporary
SymTabElem* genTemp(Type type)
{
    static int tempCnt=0;
    char s[100];
    sprintf(s, "t%d", tempCnt++);
    SymTabElem* t= lookup(s);
    setType(t, type);
    return t;
}

// type obtained on dereferncing this memory
Type derefType(Type type)
{
    if(type.dimension.size())
    {
        type.dimension.erase(type.dimension.begin());
        return type;
    }
    type.pointers--;
    return type;
}

// inserts integer in symbol table
SymTabElem* genIntConst(int val)
{
    SymTabElem* e= new SymTabElem();
    e->type= getIntType();
    e->symType= SYM_TYPE::INT_CONST;
    e->intConst= val;
    curSymTab->table.push_back(e);
    e->symTabPtr= curSymTab;
    return e;
}

// inserts float constant in symbol table
SymTabElem* genFloatConst(float val)
{
    SymTabElem* e= new SymTabElem();
    e->type= getIntType();
    e->type.type= TYPE::FLOAT;
    e->symType= SYM_TYPE::FLOAT_CONST;
    e->floatConst= val;
    curSymTab->table.push_back(e);
    e->symTabPtr= curSymTab;
    return e;
}

// inserts character constant in symbol table
SymTabElem* genCharConst(char val)
{
    SymTabElem* e= new SymTabElem();
    e->symType= SYM_TYPE::CHAR_CONST;
    e->type= getIntType();
    e->type.type= TYPE::CHAR;
    e->charConst= val;
    curSymTab->table.push_back(e);
    e->symTabPtr= curSymTab;
    return e;
}

// inserts string constant in symbol table
SymTabElem* genStringConst(char* str)
{
    SymTabElem* e= new SymTabElem();
    e->symType= SYM_TYPE::STRING_CONST;
    e->type.type= TYPE::CHAR;
    e->type.pointers= 1;
    e->id= string_constants.size();
    string_constants.push_back(str);
    curSymTab->table.push_back(e);
    e->symTabPtr= curSymTab;
    return e;
}

/* A global function to create a new list containing only i, an index
into the array of quad’s, and to return a pointer to the newly
created list */
std::vector<int> makeList(int id)
{
    return {id};
}

/* A global function to concatenate two lists pointed to by p1 and
p2 and to return a pointer to the concatenated list*/
std::vector<int> merge(std::vector<int> a, std::vector<int> b)
{
    std::vector<int> c;
    for(int a1: a) c.push_back(a1);
    for(int b1: b) c.push_back(b1);
    return c;
}


/* A global function to insert i as the target label for each of the
quad’s on the list pointed to by p. */
void backPatch(std::vector<int> list, int label)
{
    for(int id: list)
        quads[id].result= genIntConst(label);
}

// returns returns final of type of result
Type typeCheck(Type t1, Type t2)
{
    if(isPtr(t1)) return t1;
    if(isPtr(t2)) return t2;

    if(t1.type== TYPE::FLOAT)
        return t1;
    if(t2.type== TYPE::FLOAT)
        return t2;
    
    if(t1.type== TYPE::INT)
        return t1;
    if(t2.type== TYPE::INT)
        return t2;
    
    return t1;
}


// typecasts a to type and returns new variable holding new type
SymTabElem* convType(SymTabElem* a, Type type)
{
    if(isPtr(a->type) && isPtr(type))
        return a;
    if(isPtr(type))
    {
        SymTabElem* t= genTemp(getIntType());
        SymTabElem* mem= genIntConst(getMemory(derefType(type)));
        emit(t, mem, OPERATOR::ASSIGN, NULL);
        emit(t, a, OPERATOR::MULT, t);
        
        SymTabElem* t1= genTemp(type);
        emit(t1, t, OPERATOR::TYPE_CONV, NULL);
        return t1;
    }
    if(!isPtr(a->type) && a->type.type== type.type)
        return a;
    SymTabElem* t= genTemp(type);
    emit(t, a, OPERATOR::TYPE_CONV, NULL);
    return t;
}

// evaluates value of expression and returns variable holding value
SymTabElem* getValExp(Exp a)
{
    if(a.isDeref)
    {
        SymTabElem* e= genTemp(derefType(a.loc->type));
        if(!e->type.dimension.size())
            emit(e, a.loc, OPERATOR::DE_REF_R, NULL);
        else
            emit(e, a.loc, OPERATOR::ASSIGN, NULL);
        return e;
    }
    if(a.isBool)
    {
        SymTabElem* e= genTemp(getIntType());
        backPatch(a.falseList, quads.size());
        backPatch(a.trueList, quads.size()+2);
        emit(e, genIntConst(0), OPERATOR::ASSIGN, NULL);
        emit(genIntConst(quads.size()+2), NULL, OPERATOR::JUMP, NULL);
        emit(e, genIntConst(1), OPERATOR::ASSIGN, NULL);
        return e;
    }
    else return a.loc;
}

// checks if a given type is a pointer
int isPtr(Type type)
{
    return type.dimension.size() || type.pointers;
}

// swaps a and b
void swap(SymTabElem** a, SymTabElem** b)
{
    SymTabElem *t= *a;
    *a= *b;
    *b= t;
}

// gets string value of t
std::string typeToStr(Type t)
{
    std::string s;
    if(t.dimension.size())
        return "ptr";
    else if(t.pointers)
        return "ptr";
    if(t.type== TYPE::INT)
        return "int";
    if(t.type== TYPE::CHAR)
        return "char";
    if(t.type== TYPE::FLOAT)
        return "float";
    return "void";
}

// assigns a name to symbol table
std::string getName(SymTab* tab)
{
    if(tab==NULL)
        return "NULL";
    if(tab->parent==NULL)
    {
        return "global";
    }
    return tab->func.name+ " " + std::to_string(tab->cnt);
}

// gets string value of function type
std::string printFunct(FunctionType type)
{
    std::string s;
    s+= type.name;
    s+= ":  ";
    if(type.parameters.size())
    {
        s+= typeToStr(type.parameters[0]);
        for(int i=1; i<type.parameters.size(); i++)
        {
            s+=" x ";
            s+= typeToStr(type.parameters[i]);
        }
    }
    else
        s+= "void ";
    s+= "-> ";
    s+= typeToStr(type.retType);
    return s;
}

// compare function to sort
int compare(SymTabElem* a, SymTabElem* b)
{
    return a->offset<b->offset;
}

// function to print a symbol table
void SymTab::print()
{
    std::sort(table.begin(), table.end(), compare);
    std::cout<<getName(this)<<",   parent: "<<getName(this->parent)<<'\n';
    std::cout<<'\t'<<"Name"<<'\t'<<"type,"<<'\t'<<"size,"<<'\t'<<"offset in order are:\n";
    for(SymTabElem* s: table)
    {
        if
        ( 
            s->symType== SYM_TYPE::CHAR_CONST  ||
            s->symType== SYM_TYPE::INT_CONST   ||
            s->symType== SYM_TYPE::FLOAT_CONST ||
            s->symType== SYM_TYPE::STRING_CONST
        )
            continue;
        
        if(s->symType== SYM_TYPE::FUNCTION)
            std::cout<<'\t'<<printFunct(s->func->func)<<'\n';
        else
            std::cout<<'\t'<<s->name<<'\t'<<typeToStr(s->type)<<'\t'<<s->size<<'\t'<<s->offset<<'\n';
    }
}

// function to print ALL symbol tables
void symPrint()
{
    for(SymTab* tab: symTabels)
        tab->print();
}

// returns int type
Type getIntType()
{
    Type type;
    type.pointers=0;
    type.type=TYPE::INT;
    return type;
}

Type refType(Type t)
{
    t.dimension.push_back(0);
    for(int i=1; i<t.dimension.size(); i++)
        t.dimension[i]= t.dimension[i-1];
    t.dimension[0]= 1;
    return t;
}

/************************* Quad Related Functions ***************************/

Quad::Quad(SymTabElem* result, SymTabElem* arg1, OPERATOR op, SymTabElem* arg2)
{
    this->result= result;
    this->arg1  = arg1;
    this->arg2  = arg2;
    this->op    = op;
}

void emit(SymTabElem* result, SymTabElem* arg1, OPERATOR op, SymTabElem* arg2)
{
    quads.push_back(Quad(result, arg1, op, arg2));
}

// function to print a quad
void Quad::print(FILE* output)
{
    const char *a, *b, *c;
    if(result)
        a=result->name.c_str();
    if(arg1)
        b= arg1->name.c_str();
    if(arg2)
        c= arg2->name.c_str();
    switch (op)
    {
        case OPERATOR::PLUS:
            fprintf(output, "\t%s= %s+%s\n", a, b, c);
        break;
        case OPERATOR::MINUS:
            fprintf(output, "\t%s= %s-%s\n", a, b, c);
        break;
        case OPERATOR::MULT:
            fprintf(output, "\t%s= %s*%s\n", a, b, c);
        break;
        case OPERATOR::DIV:
            fprintf(output, "\t%s= %s/%s\n", a, b, c);
        break;
        case OPERATOR::ASSIGN:
            if(arg1->symType==SYM_TYPE::INT_CONST)
                fprintf(output, "\t%s= %d\n", a, arg1->intConst);
            else if(arg1->symType==SYM_TYPE::FLOAT_CONST)
                fprintf(output, "\t%s= %f\n", a, arg1->floatConst);
            else if(arg1->symType==SYM_TYPE::CHAR_CONST)
            {
                char d= arg1->charConst;
                if(d!='\n' && d!='\t' && d!='\0' && d!='\\' && d!='\'' && d!='\"')
                    fprintf(output, "\t%s= '%c'\n", a, d);
                else if(d=='\n')
                    fprintf(output, "\t%s= '\\n'\n", a);
                else if(d=='\t')
                    fprintf(output, "\t%s= '\\t'\n", a);
                else if(d=='\0')
                    fprintf(output, "\t%s= '\\0'\n", a);
                else if(d=='\\')
                    fprintf(output, "\t%s= '\\\'\n", a);
                else if(d=='\'')
                    fprintf(output, "\t%s= '\\''\n", a);
                else if(d=='\"')
                    fprintf(output, "\t%s= '\\\"'\n", a);
            }
            else if(arg1->symType==SYM_TYPE::STRING_CONST)
                fprintf(output, "\t%s= %s\n", a, string_constants[arg1->id].c_str());
            else 
                fprintf(output, "\t%s= %s\n", a, b);
        break;
        case OPERATOR::UMINUS:
            fprintf(output, "\t%s= -%s\n", a, b);
        break;
        case OPERATOR::UPLUS:
            fprintf(output, "\t%s= +%s\n", a, b);
        break;
        case OPERATOR::ADDRESS:
            fprintf(output, "\t%s= &%s\n", a, b);
        break;
        case OPERATOR::DE_REF_R:
            fprintf(output, "\t%s= *%s\n", a, b);
        break;
        case OPERATOR::DE_REF_L:
            fprintf(output, "\t*%s= %s\n", a, b);
        break;
        case OPERATOR::PRINT:
            fprintf(output, "\tPrint %s\n", a);
        break;
        case OPERATOR::JUMP:
            fprintf(output, "\tJump %d\n", 1+result->intConst);
        break;
        case OPERATOR::COND_JUMP:
            fprintf(output, "\tif %s Jump %d\n", b, 1+result->intConst);
        break;
        case OPERATOR::LT:
            fprintf(output, "\t%s= %s<%s\n", a, b, c);
        break;
        case OPERATOR::GT:
            fprintf(output, "\t%s= %s>%s\n", a, b, c);
        break;
        case OPERATOR::CALL:
            fprintf(output, "\t%s= CALL %s %d\n", a, b, (int)arg1->func->func.parameters.size());
        break;
        case OPERATOR::FUNC:
            fprintf(output, "FUNCTION %s:\n", a);
        break;
        case OPERATOR::ENDFUNC:
            fprintf(output, "END FUNCTION\n");
        break;
        case OPERATOR::PARAMETER:
            fprintf(output, "\tparameter %s\n", a);
        break;
        case OPERATOR::RETURN:
            if(result)
                fprintf(output, "\treturn %s\n", a);
            else fprintf(output, "\treturn\n");
        break;
        case OPERATOR::TYPE_CONV:
            fprintf(output, "\t%s= (%s)%s\n", a, typeToStr(result->type).c_str(), b);
        break;
        case OPERATOR::EMPTY:
            fprintf(output, "\n");
        break;
        case OPERATOR::BIT_NOT:
            fprintf(output, "\t%s= ~%s\n", a, b);
        break;
        case OPERATOR::MOD:
            fprintf(output, "\t%s= %s%%%s\n", a, b, c);
        break;
        case OPERATOR::L_SHIFT:
            fprintf(output, "\t%s= %s<<%s\n", a, b, c);
        break;
        case OPERATOR::R_SHIFT:
            fprintf(output, "\t%s= %s>>%s\n", a, b, c);
        break;
        case OPERATOR::GE:
            fprintf(output, "\t%s= %s>=%s\n", a, b, c);
        break;
        case OPERATOR::LE:
            fprintf(output, "\t%s= %s<=%s\n", a, b, c);
        break;
        case OPERATOR::EQEQ:
            fprintf(output, "\t%s= %s==%s\n", a, b, c);
        break;
        case OPERATOR::NEQ:
            fprintf(output, "\t%s= %s!=%s\n", a, b, c);
        break;
        case OPERATOR::BIT_AND:
            fprintf(output, "\t%s= %s&%s\n", a, b, c);
        break;
        case OPERATOR::BIT_XOR:
            fprintf(output, "\t%s= %s^%s\n", a, b, c);
        break;
        case OPERATOR::BIT_OR:
            fprintf(output, "\t%s= %s|%s\n", a, b, c);
        break;
        case OPERATOR::MEMORY:
            fprintf(output, "\t%s= memory %d\n", a, arg1->intConst);
        break;
    }
}


/********************* Grammar related Functions for reducing bison rules ****************************/

// initializes variable id to e
void redDeclExp(SymTabElem* id, Exp* e)
{
    id= setType(id, lastType);
    emit(id, convType(getValExp(*e), id->type), OPERATOR::ASSIGN, NULL);
}

// inserts array in symbol table
void redDeclArr(SymTabElem* id)
{
    id= setType(id, lastType);
    if(lastType.dimension.size())
    {
        curSymTab->offset+= getMemory(lastType);
        emit(id, genIntConst(getMemory(lastType)), OPERATOR::MEMORY, NULL); 
    }
}

// two type of assignments a= b or *a= b 
Exp* redExpAssign(Exp *a, Exp *b)
{
    if(a->isDeref)
        emit(a->loc, convType(getValExp(*b), derefType(a->loc->type)), OPERATOR::DE_REF_L, NULL);
    else
        emit(a->loc, convType(getValExp(*b), a->loc->type), OPERATOR::ASSIGN, NULL);
    return a;
}

// converts int to bool
Exp* intToBool(Exp* a)
{
    if(a->isBool)
        return a;
    SymTabElem* s= getValExp(*a);
    Exp* res= new Exp();
    res->isBool=1;
    res->trueList= makeList(quads.size());
    res->falseList=makeList(quads.size()+1);
    emit(genIntConst(quads.size()+2), s, OPERATOR::COND_JUMP, NULL);
    emit(genIntConst(quads.size()+1), NULL, OPERATOR::JUMP, NULL);
    return res;
}

// logical or backpathing
Exp* redExpOr(Exp* a, Exp* b, int m)
{
    Exp* res= new Exp();
    res->isBool=1;
    res->isDeref=0;
    backPatch(a->falseList, m);
    res->trueList= merge(a->trueList, b->trueList);
    res->falseList= b->falseList;
    return res;
}

// logical and backpatching
Exp* redExpAnd(Exp* a, Exp* b, int m)
{
    Exp* res=new Exp();
    res->isDeref=0;
    res->isBool=1;
    backPatch(a->trueList, m);
    res->falseList= merge(a->falseList, b->falseList);
    res->trueList= b->trueList;
    return res;
}

// returns new temp: a op b
Exp* redBinOp(Exp* a, OPERATOR op, Exp* b)
{
    SymTabElem* a1= getValExp(*a);
    SymTabElem* b1= getValExp(*b);
    Type type= typeCheck(a1->type, b1->type);
    a1= convType(a1, type);
    b1= convType(b1, type);
    Exp* res= new Exp();
    res->isDeref=0;
    res->isBool=0;
    res->loc= genTemp(type);
    emit(res->loc, a1, op, b1);
    return res;
}

// return new temp op a
Exp* redUnaOp(OPERATOR op, Exp* a)
{
    Exp *res= new Exp();
    SymTabElem* a1= getValExp(*a);
    res->isDeref=0;
    res->isBool=0;
    res->loc= genTemp(a1->type);
    emit(res->loc, a1, op, NULL);
    return res;
}

// a++
Exp* redPostInc(Exp* a)
{
    Exp* res= new Exp();
    if(a->isDeref)
        res->loc= genTemp(derefType(a->loc->type));
    else 
        res->loc= genTemp(a->loc->type);
    redExpAssign(res, a);
    Exp* one= redExpConst(genIntConst(1));
    Exp* sum= redBinOp(one, OPERATOR::PLUS, a);
    redExpAssign(a, sum);
    return res;
}

// ++a
Exp* redPreInc(Exp* a)
{
    return redExpAssign(a, redBinOp(redExpConst(genIntConst(1)),OPERATOR::PLUS,a));
}

// a--
Exp* redPostDec(Exp* a)
{
    Exp* res= new Exp();
    if(a->isDeref)
        res->loc= genTemp(derefType(a->loc->type));
    else 
        res->loc= genTemp(a->loc->type);
    redExpAssign(res, a);
    Exp* one= redExpConst(genIntConst(1));
    Exp* sum= redBinOp(a, OPERATOR::MINUS, one);
    redExpAssign(a, sum);
    return res;
}

// --a
Exp* redPreDec(Exp* a)
{
    return redExpAssign(a, redBinOp(a, OPERATOR::MINUS, redExpConst(genIntConst(1))));
}

// !a swaps true and false list
Exp* redExpNot(Exp *a)
{
    Exp* result= new Exp();
    *result= *a;
    result->falseList= a->trueList;
    result->trueList= a->falseList;
    return result;
}

// returns new temp: &a
Exp* redExpAddr(Exp* a)
{
    Exp* res= new Exp();
    if(a->isDeref)
    {
        res= a;
        res->isDeref=0;
        return res;
    }
    res->isDeref=0;
    res->isBool=0;
    res->loc= genTemp(refType(a->loc->type));
    emit(res->loc, a->loc, OPERATOR::ADDRESS, NULL);
    return res;
}

// returns new temp *a 
Exp* redExpDeref(Exp* a)
{
    Exp* res= new Exp();
    SymTabElem* a1= getValExp(*a);
    res->isDeref=1;
    res->isBool=0;
    res->loc=a1;
    return res;
}

// returns new temp a[n]
Exp* redArrRef(Exp* a, Exp* n)
{
    Exp* res= new Exp();
    res->isDeref=1;
    res->isBool=0;  
    SymTabElem* a1= getValExp(*a);
    SymTabElem* t = genTemp(a1->type);
    SymTabElem* delta= genTemp(getIntType());
    SymTabElem* memory= genIntConst(getMemory(derefType(a1->type)));
    emit(delta, memory, OPERATOR::ASSIGN, NULL);
    emit(delta, getValExp(*n), OPERATOR::MULT, delta);
    emit(t, delta, OPERATOR::TYPE_CONV, NULL);
    emit(t, t,  OPERATOR::PLUS, a1);
    res->loc= t;
    return res;
}

// casts a to last seen type
Exp* redExpCast(Exp* a)
{
    lastType.dimension.clear();
    Exp* res= new Exp();
    res->isBool=0;
    res->isDeref=0;
    res->loc= convType(getValExp(*a), lastType);
    return res;
}

// assigns variable to a constant
Exp* redExpConst(SymTabElem* n)
{
    Exp* res= new Exp();
    res->isBool=0;
    res->isDeref=0;
    res->loc= genTemp(n->type);
    emit(res->loc, n, OPERATOR::ASSIGN, NULL);
    return res;
}

// assigns varibale to a id
Exp* redExpTok(SymTabElem* token)
{
    Exp* res= new Exp();
    res->loc= token;
    res->isBool=0;
    res->isDeref=0;
    return res;
}

// falls through guard rule
int redN()
{
    emit(NULL, NULL, OPERATOR::JUMP, NULL);
    return quads.size()-1;
}

// if statements backpatches boolean b
void redIf(Exp* b, int m)
{
    backPatch(b->falseList, quads.size());
    backPatch(b->trueList, m);
}

// if statements backpatches boolean b
void redIfElse(Exp* b, int m1, int n, int m2)
{
    backPatch(b->trueList, m1);
    backPatch(b->falseList, m2);
    backPatch({n}, quads.size());
}

// while statements backpatches boolean b
void redWhile(int m1, Exp* b, int m2, int n)
{
    backPatch(b->trueList, m2);
    backPatch({n}, m1);
    backPatch(b->falseList, quads.size());
}

// for statements backpatches boolean b
void redFor(int m1, Exp* b, int m2, int n1, int m3, int n2)
{
    backPatch(b->trueList, m3);
    backPatch({n1}, m1);
    backPatch({n2}, m2);
    backPatch(b->falseList, quads.size());
}

// stores paramets for id
void redParameters(SymTabElem* id)
{
    curSymTab->func.parameters.push_back(lastType);
    setTypeParam(id, lastType);
}

// changes scope for function
void setFuncScope()
{
    SymTab* symTab= new SymTab();
    symTab->offset=0;
    symTab->maxOffset=0;
    symTab->funcSym= symTab;
    symTab->parent= curSymTab;
    symTab->cnt= symTabels.size();
    symTabels.push_back(symTab);
    curSymTab= symTab;
    lastType.dimension.clear();
    curSymTab->func.retType= lastType;
}

// updates symbol table for function
void redFuncHead(SymTabElem* id)
{
    if(id->symType!=SYM_TYPE::EMPTY_ID)
    {
        symTabels.pop_back();
        curSymTab=id->func;
        emit(id, NULL, OPERATOR::FUNC, NULL);
        return;
    }
    id->symType= SYM_TYPE::FUNCTION;
    id->func= curSymTab;
    id->offset= curSymTab->parent->offset;
    curSymTab->func.name= id->name;
    for(SymTabElem* a: curSymTab->table)
        a->offset-= curSymTab->offset+PTR_SIZE+a->size;
    curSymTab->offset= 0;
    curSymTab->maxOffset= 0;
    emit(id, NULL, OPERATOR::FUNC, NULL);
}

// exit function
void redFuncBody()
{
    emit(NULL, NULL, OPERATOR::ENDFUNC, NULL);
    emit(NULL, NULL, OPERATOR::EMPTY, NULL);
    curSymTab=curSymTab->parent;
}

// list of arguments for function
Arg* redArgs(Arg* args, Exp* exp)
{
    args->args.push_back(getValExp(*exp));
    return args;
}

// end arguments
Arg* redArgEmpty()
{
    return new Arg();
}

// handles function call
Exp* redFuncCall(SymTabElem* e, Arg* args)
{
    for(int i=0; i<args->args.size(); i++)
        args->args[i]= convType(args->args[i], e->func->func.parameters[i]);
    for(SymTabElem* arg: args->args)
        emit(arg, NULL, OPERATOR::PARAMETER, NULL);
    SymTabElem* res= genTemp(e->func->func.retType);
    emit(res, e, OPERATOR::CALL, NULL);
    Exp* ans= new Exp();
    ans->isBool=0;
    ans->isDeref=0;
    ans->loc= res;
    return ans;
}

// handles return statement
void redReturn(Exp* r)
{
    emit(convType(getValExp(*r), curSymTab->func.retType), NULL, OPERATOR::RETURN, NULL);
}

// returns void
void redReturnVoid()
{
    emit(NULL, NULL, OPERATOR::RETURN, NULL);
}

// changes scope
void redScope()
{
    SymTab* scope= new SymTab();
    scope->func= curSymTab->func;
    scope->funcSym= curSymTab->funcSym;
    scope->offset= curSymTab->offset;
    scope->parent= curSymTab;
    scope->cnt= symTabels.size();
    symTabels.push_back(scope);
    curSymTab= scope;
}

// leave scope
void endScope()
{
    curSymTab= curSymTab->parent;
}

// initializes program
void initProg()
{
    curSymTab= new SymTab();
    curSymTab->cnt= symTabels.size();
    symTabels.push_back(curSymTab);
    curSymTab->funcSym= curSymTab;
    curSymTab->maxOffset=0;
    curSymTab->parent=NULL;
}