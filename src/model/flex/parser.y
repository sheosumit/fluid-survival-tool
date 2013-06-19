%include {   
#include <iostream>  
#include "Formula.h"
#include "IntervalSet.h"
#include <unistd.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdlib.h>
#include "lexglobal.h"
#define BUFS 1024

  void token_destructor(model::Formula* fml)
    {
      std::cout << "In token_destructor" << std::endl;
    }

}

%token_type {model::Formula*}
%default_type {model::Formula*}
%token_destructor { token_destructor($$); }

%type expr {model::Formula*}
%type DOUBLE {double}
%type INTEGER {int}
%type VARIABLE {char*}

%left NEG.
%left AND.
%left OR.
%left UNTIL.
   
%parse_accept {
  printf("parsing complete!\n\n\n");
}

   
%syntax_error {  
  std::cout << "Syntax error!" << std::endl;  
}   
   
/*  This is to terminate with a new line */
main ::= PR LEQ DOUBLE(A) LPAREN expr(B) RPAREN. { 
	A = new ProbFormula(B,0,A);
	std::cout << "Probability Formula detected." << std::endl;
}


expr(A) ::= expr(B) AND  expr(C).   { 
	A = new AndFormula(B,C);
	std::cout << "And Formula detected." << std::endl;
}  

expr(A) ::= NEG expr(B).   { 
	A = new NegFormula(B,0);
	std::cout << "Negation Formula detected." << std::endl;
}

expr(A) ::= expr(B) UNTIL LCOLON DOUBLE(T1) COMMA DOUBLE(T2) RCOLON expr(C).  {
	A = new UntilFormula(B,C,Interval(T1,T2));
	std::cout << "Until Formula detected." << std::endl;
}

expr(A) ::= atomdisexpr(B). {A=B;}
atomdisexpr(A) ::= VARIABLE(B) EQUALS DOUBLE(C). { A = new AtomDisFormula(0,0,B,C); }
expr(A) ::= atomcontexpr(B). {A=B;}
atomcontexpr(A) ::= VARIABLE(B) LEQ DOUBLE(C). { A = new AtomContFormula(0,0,B,C); }


