#include <iostream>
#include "tokens.hpp"
#include "output.hpp"

extern int yylex();
extern char* yytext;
extern int yylineno;

int main() {
    int token;

    // read tokens until the end of file is reached
    while ((token = yylex())) {
        // The token printing is now handled directly in scanner2.lex
        // So we don't need to do anything here with the tokens
    }
    return 0;
}