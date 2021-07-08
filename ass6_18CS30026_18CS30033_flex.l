%{
#include <math.h>
#include "ass6_18CS30026_18CS30033_translator.h"
#include "y.tab.h"
extern int yyleng;

%}

/* Checking for IDENTIFIER */
Digit       [0-9]
Alpha       [_]|[a-z]|[A-Z]
IDENTIFIER  {Alpha}({Alpha}|{Digit})*

/* Checking for CONSTANT */
IntConst    {Digit}*
Sign        [+]|[-]
Exp         (e|E)({Sign}?){Digit}+
FracConst   {Digit}+[.]{Digit}+
FloatConst  ({FracConst}{Exp}?)|({Digit}+{Exp})
Escape      [\\][\'\"\?\\abfnrtv]
CChar       {Escape}|[^\'\\\n]
CharConst   [\']{CChar}+[\']
CONSTANT    {CharConst}|{IntConst}|{FloatConst}


/* Ignoring WHITESPACE */
SingleLine  [/][/].*("\n")
ComChar     [^*]|([*][^/])
MulLine     [/][*]{ComChar}*([*]?)[*][/]
WHITESPACE  [\ \n\t\0]|{MulLine}|{SingleLine}

/* Checking for STRING */
SChar       {Escape}|[^\"\\\n]
STRING      ["]{SChar}*["]

PUNCTUATOR          "["|"]"|"("|")"|"{"|"}"|"."|"->"|"++"|"--"|"&"|"*"|"+"|"-"|"~"|"!"|"/"|"%"|"<<"|">>"|"<"|">"|"<="|">="|"=="|"!="|"^"|"|"|"&&"|"||"|"?"|":"|";"|"..."|","|"#"|"="|"*="|"/="|"%="|"+="|"-="|"<<="|">>="|"&="|"^="|"|="

%%       
{WHITESPACE}        /* Ignore */;
"=="                return TOKEN_EQEQ;
"!="                return TOKEN_NEQ;
">>"                return TOKEN_RIGHT_SHIFT;
"<<"                return TOKEN_LEFT_SHIFT;
"<="                return TOKEN_LE;
">="                return TOKEN_GE;
"--"                return TOKEN_DEC;
"++"                return TOKEN_INC;
"int"               return TOKEN_INT;
"char"              return TOKEN_CHAR;
"void"              return TOKEN_VOID;
"float"             return TOKEN_FLOAT;
"if"                return TOKEN_IF;
"else"              return TOKEN_ELSE;
"for"               return TOKEN_FOR;
"while"             return TOKEN_WHILE;
"return"            return TOKEN_RETURN;
{IDENTIFIER}        {
                        yylval.pointer=lookup(yytext);
                        return TOKEN_ID;
                    }
{IntConst}          {
                        yylval.pointer=genIntConst(atoi(yytext));
                        return TOKEN_CONST;   
                    }
{STRING}            {
                        yylval.pointer= genStringConst(yytext);
                        return TOKEN_SCONST;
                    }
{FloatConst}        {
                        float c;
                        sscanf(yytext, "%f", &c);
                        yylval.pointer= genFloatConst(c);
                        return TOKEN_FCONST;
                    }
{CharConst}         {
                        char c;
                        if(yyleng==3)
                            c= yytext[1];
                        else if(yytext[2]=='n')
                            c= '\n';
                        else if(yytext[2]=='t')
                            c= '\t';
                        else if(yytext[2]=='0') 
                            c= '\0';
                        else if(yytext[2]=='\\')
                            c= '\\';
                        else if(yytext[2]=='\'')
                            c= '\''; 
                        else if(yytext[2]=='"')
                            c= '\"'; 
                        yylval.pointer= genCharConst(c);
                        return TOKEN_CCONST;
                    }
"&&"                return TOKEN_AND;
"||"                return TOKEN_OR;
 /* Remaining Punctuators */
{PUNCTUATOR}        return yytext[0];
.                   ;
%%

int yywrap()
{
    return 1;
}