#include <iostream>
#include "tokens.hpp"
#include "output.hpp"

extern int yylex();
extern char* yytext;
extern int yylineno;

int main() {
    int token;
    while ((token = yylex())) { /* all done in scanner.lex */}
    return 0;
}