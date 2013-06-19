%{   
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <iostream>  
#include "Formula.h"
#include "IntervalSet.h"

using namespace model;

	int yylex(void);
	void yyerror(char *s);
        int yyparse();
        Formula* parser_results();

#define NVARS 100
char *vars[NVARS]; double vals[NVARS]; int nvars=0;

class Formula *PARSER_FML;
%}

%union { double dval; int ivar; class Formula *fml; }

%token <dval> DOUBLE
%token <ivar> VARIABLE
%type <fml> expr
%type <fml> atomdisexpr
%type <fml> atomcontexpr
%type <fml> trueexpr

%token	S_PR
%token 	S_LEQ S_LESSER S_GREATER S_GEQ
%token	LPAREN RPAREN
%token	S_NEG S_AND S_UNTIL
%token	LCOLON RCOLON
%token 	COMMA
%token	S_FLUID S_DISCRETE
%token	S_EQUALS
%token  S_TRUE

%left S_NEG
%left S_AND
%left S_OR
%left S_UNTIL
%left S_FLUID
%left S_DISCRETE
%left S_TRUE
%left S_PR
%nonassoc LPAREN RPAREN LCOLON RCOLON
%nonassoc DOUBLE COMMA
%nonassoc S_LEQ S_LESSER S_GREATER S_GEQ S_EQUALS
%nonassoc VARIABLE
%%
%start main;

main : S_PR S_LEQ DOUBLE LPAREN expr RPAREN {
	PARSER_FML = new ProbFormula($5,0,$3,LEQ);
	
	std::cout << "Probability <= Formula detected." << std::endl;
}
     | S_PR S_LESSER DOUBLE LPAREN expr RPAREN {
	PARSER_FML = new ProbFormula($5,0,$3,LESSER);
	std::cout << "Probability < Formula detected." << std::endl;
}
     | S_PR S_GREATER DOUBLE LPAREN expr RPAREN {
	PARSER_FML = new ProbFormula($5,0,$3,GREATER);
	std::cout << "Probability > Formula detected." << std::endl;
}
     | S_PR S_GEQ DOUBLE LPAREN expr RPAREN {
	PARSER_FML = new ProbFormula($5,0,$3,GEQ);
	std::cout << "Probability >= Formula detected." << std::endl;
};

expr : expr S_AND expr {
	$$ = new AndFormula($1,$3);
	
	std::cout << "And Formula detected." << std::endl;
}
     | S_NEG expr {
        $$ = new NegFormula($2,0);
	
	std::cout << "Negation Formula detected." << std::endl;
}
     | expr S_UNTIL LCOLON DOUBLE COMMA DOUBLE RCOLON expr  {
	Interval bound = Interval($4,$6);
	$$ = new UntilFormula($1,$8,bound);
	
	std::cout << "Until Formula detected." << std::endl;
}

     | atomdisexpr { $$=$1; }
     | atomcontexpr { $$=$1; }
     | trueexpr { $$=$1; }
     | LPAREN expr RPAREN {$$=$2; };

atomdisexpr : S_DISCRETE VARIABLE S_EQUALS DOUBLE { 
        $$ = new AtomDisFormula(0,0,vars[$2],$4);

        std::cout << "Atom Discrete Formula detected." << vars[$2] << std::endl;
};
atomcontexpr : S_FLUID VARIABLE S_LEQ DOUBLE { 
        $$ = new AtomContFormula(0,0,vars[$2],$4);
	
        std::cout << "Atom Continuous Formula detected." << vars[$2] << std::endl;
};
trueexpr : S_TRUE {
        $$ = new TrueFormula(0,0);

        std::cout << "True Formula detected." << std::endl;
};

%%

int varindex(char *var)
{
int i;
for (i=0; i<nvars; i++)
if (strcmp(var,vars[i])==0) return i;
vars[nvars] = strdup(var);
return nvars++;
}

/* Called by yyparse on error. */
void yyerror (char const *s)
{
fprintf (stderr, "Parser error: %s\n", s);
}

Formula* parser_results() {
    return PARSER_FML;
}
/*
int main(void)
{
yyparse();
return 0;
}
*/

