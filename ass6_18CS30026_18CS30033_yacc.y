%{
    #include "ass6_18CS30026_18CS30033_translator.h"
    extern int yylex();
    void yyerror(const char *s);
%}

%union
{
    struct SymTabElem* pointer;
    struct Exp *exp;
    struct Arg* arg;
    int intval;
}

/*tokens for flex scanning*/
%token TOKEN_INC            /*token ++*/
%token TOKEN_DEC            /*token --*/
%token TOKEN_AND            /*token &&*/
%token TOKEN_OR             /*token ||*/
%token TOKEN_INT            /*token int*/
%token TOKEN_CHAR           /*token char*/
%token TOKEN_FLOAT          /*token float*/
%token TOKEN_VOID           /*token void*/
%token TOKEN_PRINT          /*token print (debug)*/
%token TOKEN_IF             /*token if*/
%token TOKEN_ELSE           /*token else*/
%token TOKEN_WHILE          /*token while*/
%token TOKEN_FOR            /*token for*/
%token TOKEN_RETURN         /*token return*/
%token TOKEN_GE             /*token >=*/
%token TOKEN_LE             /*token <=*/
%token TOKEN_LEFT_SHIFT     /*token <<*/
%token TOKEN_RIGHT_SHIFT    /*token >>*/
%token TOKEN_EQEQ           /*token ==*/
%token TOKEN_NEQ            /*token !=*/

/* Constants and identifiers stored in symbol table */
%token<pointer> TOKEN_ID        /*identifier*/
%token<pointer> TOKEN_CONST     /*integer const*/
%token<pointer> TOKEN_FCONST    /*float const*/
%token<pointer> TOKEN_CCONST    /*char const*/
%token<pointer> TOKEN_SCONST    /*string const*/

/* M and N are added for backpathing purposes in the grammar */
/* M and N contain quad index they point to */
%type<intval> M
%type<intval> N

/* All expresions have same type 
  that is to store a expression struct */

/*all types are self explanatory by their names*/
%type<exp> expression
%type<exp> logical_OR_expression
%type<exp> logical_AND_expression
%type<exp> B
%type<exp> bool_logical_OR_expression
%type<exp> bool_logical_AND_expression
%type<exp> bool_inclusive_OR_expression
%type<exp> equality_expression
%type<exp> AND_expression
%type<exp> exclusive_OR_expression
%type<exp> inclusive_OR_expression
%type<exp> shift_expression
%type<exp> relational_expression
%type<exp> additive_expression
%type<exp> multiplicative_expression
%type<exp> bool_unary_expression
%type<exp> cast_expression
%type<exp> unary_expression
%type<exp> postfix_expression
%type<exp> primary_expression

/* arguments is vector of variables to pass in function */
%type<arg> argument_expression_list
%type<arg> argument_expression_list_opt

/*for handelling dengling else conflict*/
%nonassoc THEN
%nonassoc TOKEN_ELSE

%start translation_unit

/* We have re written the grammar for lowest to highest precedence */

/* Note: Reduction for each rule is handled in cxx file via functions
here only functions are called for cleanliness purposes
each reducion function is explaind in cxx file
*/

/*bison Structure
    expression phase followed by
    declaration phase (includes external declarations) followed by
    fuction def phase followed by
    statement declaration phase

    each rules calls functions defined in cxx file, see cxx file for
    explanation of functions

    commenting in between rules causes errors, :-(
*/

%%

expression: logical_OR_expression '=' expression
    {
        $$= redExpAssign($1, $3);
    }
    | logical_OR_expression
    ;

bool_logical_OR_expression: logical_OR_expression
    {
        $$= intToBool($1);
    }
    ;

bool_logical_AND_expression: logical_AND_expression
    {
        $$= intToBool($1);
    }
    ;

bool_inclusive_OR_expression: inclusive_OR_expression
    {
        $$= intToBool($1);
    }
    ;

logical_OR_expression: bool_logical_OR_expression TOKEN_OR M bool_logical_AND_expression
    {
        $$= redExpOr($1, $4, $3);
    }
    | logical_AND_expression
    ;

logical_AND_expression: bool_logical_AND_expression TOKEN_AND M bool_inclusive_OR_expression
    {
        $$= redExpAnd($1, $4, $3);
    }
    | inclusive_OR_expression
    ;

inclusive_OR_expression: exclusive_OR_expression
    | inclusive_OR_expression '|' exclusive_OR_expression
    {
        $$= redBinOp($1, OPERATOR::BIT_OR, $3);
    }
    ;

exclusive_OR_expression: AND_expression
    | exclusive_OR_expression '^' AND_expression
    {
        $$= redBinOp($1, OPERATOR::BIT_XOR, $3);
    }
    ;

AND_expression: equality_expression
    | AND_expression '&' equality_expression
    {
        $$= redBinOp($1, OPERATOR::BIT_AND, $3);
    }
    ;

equality_expression: relational_expression
    | equality_expression TOKEN_EQEQ relational_expression
    {
        $$= redBinOp($1, OPERATOR::EQEQ, $3);
    }
    | equality_expression TOKEN_NEQ relational_expression
    {
        $$= redBinOp($1, OPERATOR::NEQ, $3);
    }
    ;

relational_expression: relational_expression '<' shift_expression
    {
        $$= redBinOp($1, OPERATOR::LT, $3);
    }
    | relational_expression '>' shift_expression
    {
        $$= redBinOp($1, OPERATOR::GT, $3);
    }
    | relational_expression TOKEN_LE shift_expression
    {
        $$= redBinOp($1, OPERATOR::LE, $3);
    }
    | relational_expression TOKEN_GE shift_expression
    {
        $$= redBinOp($1, OPERATOR::GE, $3);
    }
    | shift_expression
    ;

shift_expression: additive_expression
    | shift_expression TOKEN_LEFT_SHIFT additive_expression
    {
        $$= redBinOp($1, OPERATOR::L_SHIFT ,$3);
    }
    | shift_expression TOKEN_RIGHT_SHIFT additive_expression
    {
        $$= redBinOp($1, OPERATOR::R_SHIFT ,$3);
    }
    ;

additive_expression: additive_expression '+' multiplicative_expression
    {
        $$=redBinOp($1, OPERATOR::PLUS, $3);
    }
    | additive_expression '-' multiplicative_expression
    {
        $$= redBinOp($1, OPERATOR::MINUS, $3);
    }
    | multiplicative_expression
    ;

multiplicative_expression: multiplicative_expression '*' cast_expression
    {
        $$= redBinOp($1, OPERATOR::MULT, $3);
    }
    | multiplicative_expression '/' cast_expression
    {
        $$= redBinOp($1, OPERATOR::DIV, $3);
    }
    | multiplicative_expression '%' cast_expression
    {
        $$= redBinOp($1, OPERATOR::MOD, $3);
    }
    | cast_expression
    ;


cast_expression: '(' type_specifier pointer_opt ')' cast_expression
    {
        $$= redExpCast($5);
    }
    | unary_expression
    ;

unary_expression: '-' unary_expression
    {
        $$= redUnaOp(OPERATOR::UMINUS, $2);
    }
    | '+' unary_expression
    {
        $$= redUnaOp(OPERATOR::UPLUS, $2);
    }
    | '&' unary_expression
    {
        $$= redExpAddr($2);
    }
    | '*' unary_expression
    {
        $$= redExpDeref($2);
    }
    | '~' unary_expression
    {
        $$=redUnaOp(OPERATOR::BIT_NOT, $2);
    }
    | '!' bool_unary_expression
    {
        $$= redExpNot($2);
    }
    | TOKEN_INC unary_expression
    {
        $$= redPreInc($2);
    }
    | TOKEN_DEC unary_expression
    {
        $$= redPreDec($2);
    }
    | postfix_expression
    ;

bool_unary_expression: unary_expression
    {
        $$= intToBool($1);
    }
    ;

postfix_expression: postfix_expression '[' expression ']'
    {
       $$= redArrRef($1, $3);
    }
    | TOKEN_ID '(' argument_expression_list_opt ')'
    {
        $$= redFuncCall($1, $3);
    }
    | postfix_expression TOKEN_INC
    {
        $$= redPostInc($1);
    }
    | postfix_expression TOKEN_DEC
    {
        $$= redPostDec($1);
    }
    | primary_expression
    ;

primary_expression: TOKEN_ID
    {
        $$= redExpTok($1);
    }
    | TOKEN_CONST
    {
        $$= redExpConst($1);
    }
    | TOKEN_CCONST
    {
        $$= redExpConst($1);
    }
    | TOKEN_FCONST
    {
        $$= redExpConst($1);
    }
    | '(' expression ')'
    {
        $$= $2;
    }
    | TOKEN_SCONST
    {
        $$= redExpConst($1);
    }
    ;
argument_expression_list_opt: argument_expression_list
    |
    {
        $$= redArgEmpty();
    }
    ;

argument_expression_list: argument_expression_list ',' expression
    {
        $$= redArgs($1, $3);
    }
    | expression
    {
        $$= redArgEmpty();
        $$= redArgs($$, $1);
    }
    ;

translation_unit: translation_unit G_Decl
    |
    {
        initProg();
    }
    ;

G_Decl: G_VarDec
    | FuncDecl
    ;

G_VarDec: type_specifier G_Varlist ';'
    ;

G_Varlist: G_Varlist ',' pointer_opt TOKEN_ID Array
    {
        redDeclArr($4);
    }
    | pointer_opt TOKEN_ID Array
    {
        redDeclArr($2);
    }
    ;

FuncDecl: FuncHead FuncBody
    ;

FuncHead: type_specifier pointer_opt TOKEN_ID '(' FuncScope Parameters_opt ')'
    {
        redFuncHead($3);
    }
    ;

FuncScope:
    {
        setFuncScope();
    }
    ;

FuncBody: '{' block_statement '}'
    {
        redFuncBody();
    }
    |
    ';'
    {
        quads.pop_back();
        curSymTab= curSymTab->parent;
    }
    ;

Parameters_opt: Parameters
    |
    ;

Parameters: Parameters ',' type_specifier pointer_opt TOKEN_ID Array
    {
        redParameters($5);
    }
    | type_specifier pointer_opt TOKEN_ID Array
    {
        redParameters($3);
    }
    ;

block_statement: block_statement statement
    |
    ;

N:
    {
        $$= redN();
    }

statement: VarDecl
    | expression ';'
    | '{' Scope block_statement '}'
    {
        endScope();
    }
    | TOKEN_IF '(' B ')' M statement N %prec THEN
    {
        quads.pop_back();
        redIf($3, $5);
    }
    | TOKEN_IF '(' B ')' M statement N TOKEN_ELSE M statement
    {
        redIfElse($3, $5, $7, $9);
    }
    | TOKEN_WHILE M '(' B ')' M statement N
    {
        redWhile($2, $4, $6, $8);
    }
    | TOKEN_FOR '(' expression ';' M B ';' M expression N ')' M statement N
    {
        redFor($5, $6, $8, $10, $12, $14);
    }
    | TOKEN_RETURN expression ';'
    {
        redReturn($2);
    }
    | TOKEN_RETURN ';'
    {
        redReturnVoid();
    }
    | ';'
    ;

Scope:
    {
        redScope();
    }
    ;

VarDecl: type_specifier VarList ';'
    ;

type_specifier: TOKEN_INT
    {
        lastType.type= TYPE::INT;
    }
    | TOKEN_CHAR
    {
        lastType.type= TYPE::CHAR;
    }
    | TOKEN_VOID
    {
        lastType.type= TYPE::VOID;
    }
    | TOKEN_FLOAT
    {
        lastType.type= TYPE::FLOAT;
    }
    ;

VarList: VarList ',' pointer_opt TOKEN_ID Array '=' logical_OR_expression
    {
        redDeclExp($4, $7);
    }
    | VarList ',' pointer_opt TOKEN_ID Array
    {
        redDeclArr($4);
    }
    | pointer_opt TOKEN_ID Array '=' logical_OR_expression
    {
        redDeclExp($2, $5);
    }
    | pointer_opt TOKEN_ID Array
    {
        redDeclArr($2);
    }
    ;

pointer_opt: pointer_opt '*'
    {
        lastType.pointers++;
    }
    |
    {
        lastType.pointers=0;
    }
    ;

Array: Array '[' TOKEN_CONST ']'
    {
        lastType.dimension.push_back($3->intConst);
    }
    |
    {
        lastType.dimension.clear();
    }
    ;

M:
    {
        $$= quads.size();
    }
    ;

B: expression
    {
        $$= intToBool($1);
    }
    ;


%%

void yyerror(const char *s)
{
    printf("%s\n",s);
}
