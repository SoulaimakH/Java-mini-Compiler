%{
	

#include <stdio.h>	
#include "Semantique.c"

int yyerror(char const *msg);	
int yylex(void);

extern int yylineno;
int nbParam = 0 ;
int nbParamExp = 0 ;
char* funId = "newFun" ;
char* funType = "void" ;

%}

%union {
  int ival;
  char* sval;
}

%token MC_IF 
%token MC_ELSE 
%token MC_WHILE 
%token MC_CLASS 
%token MC_EXTENDS 
%token <sval> MC_RETURN 
%token MC_NEW 
%token MC_THIS 
%token MC_PRINT 
%token MC_LENGTH 
%token MC_PUBLIC 
%token MC_MAIN_CLASS 
%token INTEGER_LITERAL
%token <sval> id
%token <sval> Type
%token String_Tab
%token Operation
%token Parenthese_Ouvrante
%token Parenthese_Fermante
%token ACCOLADE_Ouvrante
%token ACCOLADE_Fermante
%token Crochet_Ouvrante
%token Crochet_Fermante
%token BOOLEAN_LITERAL
%token POINT_VIRGULE
%token Op_Aff
%token POINT

%type <sval> "void"

%error-verbose
%start Program

%%
Expression           : Expression Operation Expression 
                        | Expression Crochet_Ouvrante Expression Crochet_Fermante 
                        | Expression POINT MC_LENGTH
                        | Expression POINT id Parenthese_Ouvrante expression_list Parenthese_Fermante {/*checkNbParameters($3,nbParamExp-1,yylineno) ; nbParamExp--; nbParamExp = 0 ; */ yyerrok; }  
                        | INTEGER_LITERAL
                        | BOOLEAN_LITERAL
                        | id {nbParamExp++ ; checkInitialise($1,yylineno) ;Initialiser($1,yylineno) ; yyerrok;}  
                        | MC_THIS
                        | MC_NEW INTEGER_LITERAL Crochet_Ouvrante Expression Crochet_Fermante
                        | MC_NEW id Parenthese_Ouvrante Parenthese_Fermante
                        | '!' Expression
                        | Parenthese_Ouvrante Expression Parenthese_Fermante ;

expression_list : Expression 
                | expression_list ',' Expression ; 

Statement : ACCOLADE_Ouvrante Statement_list ACCOLADE_Fermante 
          | MC_IF Parenthese_Ouvrante Expression Parenthese_Fermante Statement MC_ELSE Statement 
          | MC_WHILE Parenthese_Ouvrante Expression Parenthese_Fermante Statement 
          | MC_PRINT Parenthese_Ouvrante Expression Parenthese_Fermante POINT_VIRGULE 
          | id Op_Aff Expression POINT_VIRGULE { checkUtilise($1,yylineno); Initialiser($1,yylineno) ; yyerrok;}
          | id Crochet_Ouvrante Expression Crochet_Fermante Op_Aff Expression POINT_VIRGULE {checkUtilise($1,yylineno); Initialiser($1,yylineno) ; yyerrok;}

Statement_list : | Statement_list Statement     

type_list : Type id { nbParam = 1 ; ajouterEntree(funId,TOK_FUNCTION,funType,0,0,nbParam,yylineno); checkIdentifier($2,TOK_PARAMETER,$1,0,0,0,yylineno); yyerrok; }
          | type_list ',' Type id {nbParam++ ; checkIdentifier($4,TOK_PARAMETER,$3,0,0,0,yylineno); modifNbParam(funId,nbParam) ; yyerrok; }

VarDeclaration : Type id POINT_VIRGULE { checkIdentifier($2, TOK_VARIABLE, $1, 0, 0, 0, yylineno); checkUtiliseWar($2,yylineno) ; yyerrok;}
               | id POINT_VIRGULE {yyerror (" Missing Type on line : "); YYABORT}
               | Type id  {yyerror (" Missing ; on line : "); YYABORT}
               | Type POINT_VIRGULE {yyerror (" Missing id on line : "); YYABORT}

VarDeclaration_list : | VarDeclaration_list VarDeclaration


MethodDeclaration : MC_PUBLIC Type id Parenthese_Ouvrante type_list Parenthese_Fermante ACCOLADE_Ouvrante VarDeclaration_list Statement_list MC_RETURN Expression POINT_VIRGULE ACCOLADE_Fermante { if (nbParam == 0) ajouterEntree($3,TOK_FUNCTION,$2,0,0,nbParam,yylineno); else modifIDType($3,$2); checkReturn($2,$10,yylineno) ; AfficherTab(); DestroyLocalDic(); nbParam = 0 ;yyerrok;}
                  | MC_PUBLIC "void" id Parenthese_Ouvrante type_list Parenthese_Fermante ACCOLADE_Ouvrante VarDeclaration_list Statement_list ACCOLADE_Fermante { if (nbParam == 0) ajouterEntree($3,TOK_FUNCTION,"void",0,0,nbParam,yylineno); else modifIDType($3,"void"); checkReturn($2," ",yylineno); AfficherTab() ; DestroyLocalDic(); nbParam = 0 ;yyerrok;}
MethodDeclaration_list : | MethodDeclaration_list MethodDeclaration




ClassDeclaration : MC_CLASS id class_extend ACCOLADE_Ouvrante VarDeclaration_list MethodDeclaration_list ACCOLADE_Fermante
               | MC_CLASS class_extend ACCOLADE_Ouvrante VarDeclaration_list MethodDeclaration_list ACCOLADE_Fermante {yyerror (" Missing class id on line : "); YYABORT}
               | id class_extend ACCOLADE_Ouvrante VarDeclaration_list MethodDeclaration_list ACCOLADE_Fermante {yyerror (" Missing 'class' on line : "); YYABORT}
               | MC_CLASS id class_extend ACCOLADE_Ouvrante VarDeclaration_list MethodDeclaration_list  {yyerror (" Missing '}' on line : "); YYABORT}
               | MC_CLASS id class_extend VarDeclaration_list MethodDeclaration_list ACCOLADE_Fermante {yyerror (" Missing '{' on line : "); YYABORT}
ClassDeclaration_list : | ClassDeclaration_list ClassDeclaration

class_extend : | MC_EXTENDS id
               | MC_EXTENDS {yyerror (" Missing id on line : "); YYABORT}
               |  id {yyerror (" Missing 'extends' on line : "); YYABORT}

MainClass : MC_CLASS id ACCOLADE_Ouvrante MC_MAIN_CLASS Parenthese_Ouvrante String_Tab id Parenthese_Fermante ACCOLADE_Ouvrante Statement ACCOLADE_Fermante ACCOLADE_Fermante { checkIdentifier($7, TOK_PARAMETER,"String[]", 0, 0, 0, yylineno); checkUtiliseWar($7,yylineno) ; yyerrok;}

Program	  :  MainClass  ClassDeclaration_list { AfficherTab();}


%% 

int yyerror(char const *msg) {
       
	
	fprintf(stderr, "%s %d\n", msg,yylineno);
	return 0;
	
	
}

extern FILE *yyin;

int main()
{
 yyparse();
 
 
}

  
                   
