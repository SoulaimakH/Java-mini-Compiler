%{	
 /* We usually need these... */	
 #include <stdio.h>	
 #include <stdlib.h>	
 		
 #include "Syntaxique.tab.h"	                                                                         	
 /* Local stuff we need here... */	
#include <math.h>	 			
%}

%{
          int nb_par = 0 , line = 0 ;
%}

%{
/* Expression {Expression}{Operation}{Expression} | {Expression}"["{Expression}"]" | {Expression}"."{MC_LENGTH} | {Expression}"."{id}{ouvrante}({Expression}(","{Expression})*)?{fermante} | {INTEGER_LITERAL} | {BOOLEAN_LITERAL} | {id} | {MC_THIS} | {MC_NEW} "int" "["{Expression}"]" | {MC_NEW} {id}{ouvrante}{fermante} | "!"{Expression} | {ouvrante}{Expression}{fermante}
Statement "{" ( Statement )* "}" |{MC_IF} {ouvrante}{Expression}{fermante}{Statement} {MC_ELSE} {Statement} |{MC_WHILE} {ouvrante}{Expression}{fermante}{Statement} | {MC_PRINT} {ouvrante}{Expression}{fermante}{POINT_VIRGULE} | {id} "=" {Expression}{POINT_VIRGULE} | {id} "[" Expression "]" "="{Expression}{POINT_VIRGULE}
VarDeclaration	{Type}{id}{POINT_VIRGULE}
MethodDeclaration {MC_PUBLIC} {Type} {id}{ouvrante}({Type}{id}( ","{Type}{id})* )?{fermante}"{" ( {VarDeclaration} )* ( {Statement} )* "return" {Expression}{POINT_VIRGULE} "}"
ClassDeclaration {MC_CLASS} {id} ( {MC_EXTENDS} {id} )? "{" ( {VarDeclaration} )* ( {MethodDeclaration} )* "}"
MainClass	{MC_CLASS} {id} "{" {MC_MAIN_CLASS}{ouvrante}"String" "[" "]" {id} {fermante} "{" {Statement} "}" "}"
Program {MainClass} ( {ClassDeclaration} )* <EOF>
*/
%}

%option yylineno 
%x COMMENT

delim     [ \t]
bl        {delim}+
WHITE_SPACE [ \s]+
COMMENT_LINE  "//"(.)*

chiffre   [0-9]
lettre    [a-zA-Z]
id        (({lettre}|"_"|"$")({lettre}|{chiffre}|"_"|"$")*)
INTEGER_LITERAL (-?[1-9]{chiffre}*)
BOOLEAN_LITERAL (true|false)
caractere_speciaux ("-"|"#")
iderrone  {chiffre}({lettre}|{chiffre})*
iderrone1 (({lettre}|{chiffre})*{caractere_speciaux}({lettre}|{chiffre})*)

Parenthese_Ouvrante  (\()
Parenthese_Fermante  (\))
Crochet_Ouvrante  ("[")
Crochet_Fermante  ("]")
ACCOLADE_Ouvrante ("{")
ACCOLADE_Fermante ("}")
POINT_VIRGULE ";"

MC_IF "if"
MC_ELSE "else"
MC_WHILE "while"
MC_CLASS "class"
MC_EXTENDS "extends"
MC_RETURN "return"
MC_NEW "new"
MC_THIS "this"
MC_PRINT "System.out.println"
MC_LENGTH "length"
MC_PUBLIC "public"
MC_MAIN_CLASS "public static void main"

Operation ("&&"|"<"|"+"|"-"|"*") 
Type ("String"|"int""[""]"|"boolean"|"int"|id)
String_Tab "String""[""]"
Op_Aff "="

%%

{bl}                                                                                 /* pas d'actions */
"/*"          { BEGIN(COMMENT); nb_par++; line = yylineno ; }
<COMMENT>.    { /* Ignore anything within a comment */ }
<COMMENT>"*/" { BEGIN(INITIAL); nb_par--;}
{COMMENT_LINE}         								                         {printf("COMMENT LINE");}
{MC_IF}                                                                              {return MC_IF ;}
{MC_ELSE}                                                                            {return MC_ELSE ;}
{MC_WHILE}                                                                           {return MC_WHILE ;}
{MC_CLASS}                                                                           {return MC_CLASS ;}
{MC_EXTENDS}                                                                         {return MC_EXTENDS ;}
{MC_RETURN}                                                                          {yylval.sval = strdup(yytext); return MC_RETURN ;}
{MC_NEW}                                                                             {return MC_NEW ;}
{MC_THIS}                                                                            {return MC_THIS ;}
{MC_PRINT}                                                                           {return MC_PRINT ;}
{MC_LENGTH}                                                                          {return MC_LENGTH ;}
{MC_PUBLIC}                                                                          {return MC_PUBLIC ;}
{MC_MAIN_CLASS}                                                                      {return MC_MAIN_CLASS ;}
{INTEGER_LITERAL}                                                                    {return INTEGER_LITERAL;}
{Type}                                                                               {yylval.sval = strdup(yytext); return Type;}
{id}                                                                                 {yylval.sval = strdup(yytext); return id;}
{String_Tab}                                                                         {return String_Tab;}
{Operation}                                                                          {return Operation;}
{Parenthese_Ouvrante}                                                                {return Parenthese_Ouvrante;}
{Parenthese_Fermante}                                                                {return Parenthese_Fermante;}
{Crochet_Ouvrante}                                                                   {return Crochet_Ouvrante;}
{Crochet_Fermante}                                                                   {return Crochet_Fermante;}
{ACCOLADE_Ouvrante}                                                                  {return ACCOLADE_Ouvrante;}
{ACCOLADE_Fermante}                                                                  {return ACCOLADE_Fermante;}
{BOOLEAN_LITERAL}                                                                    {return BOOLEAN_LITERAL;}
{POINT_VIRGULE}                                                                      {return POINT_VIRGULE;}
{Op_Aff}	                                                                           {return Op_Aff;}
"."                                                                                  {return POINT;}

{iderrone}                                                                           {fprintf(stderr,"illegal identifier \'%s\' on line :%d\n",yytext,yylineno);}
{iderrone1}                                                                           {fprintf(stderr,"illegal identifier \'%s\' on line :%d\n",yytext,yylineno);}

%%

/*int main(int argc, char *argv[])
{
     yyin = fopen(argv[1], "r");
     yylex();
      if(nb_par==1)
     {fprintf(stderr, "unexpected end of comment on line %d \n", line);}
     fclose(yyin);
}*/

int yywrap()
{
	return(1);
}
