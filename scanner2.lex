%{
#include "tokens.hpp"
#include "output.hpp"

std::string string_buffer;

%}
%option yylineno
%option noyywrap
%x STRING_STATE

digit [0-9]
hex_digit (x([2-7][0-9a-fA-F])
white_space [ \t\n\r]
COMMENT \/\/.*
NUM 0|[1-9]{digit}*
NUM_B {NUM}b

%%

"void" { output::printToken(yylineno, VOID, yytext); return VOID; }
"int" { output::printToken(yylineno, INT, yytext); return INT; }
"byte" { output::printToken(yylineno, BYTE, yytext); return BYTE; }
"bool" { output::printToken(yylineno, BOOL, yytext); return BOOL; }
"and" { output::printToken(yylineno, AND, yytext); return AND; }
"or" { output::printToken(yylineno, OR, yytext); return OR; }
"not" { output::printToken(yylineno, NOT, yytext); return NOT; }
"true" { output::printToken(yylineno, TRUE, yytext); return TRUE; }
"false" { output::printToken(yylineno, FALSE, yytext); return FALSE; }
"return" { output::printToken(yylineno, RETURN, yytext); return RETURN; }
"if" { output::printToken(yylineno, IF, yytext); return IF; }
"else" { output::printToken(yylineno, ELSE, yytext); return ELSE; }
"while" { output::printToken(yylineno, WHILE, yytext); return WHILE; }
"break" { output::printToken(yylineno, BREAK, yytext); return BREAK; }
"continue" { output::printToken(yylineno, CONTINUE, yytext); return CONTINUE; }

";" { output::printToken(yylineno, SC, yytext); return SC; }
"," { output::printToken(yylineno, COMMA, yytext); return COMMA; }
"(" { output::printToken(yylineno, LPAREN, yytext); return LPAREN; }
")" { output::printToken(yylineno, RPAREN, yytext); return RPAREN; }
"{" { output::printToken(yylineno, LBRACE, yytext); return LBRACE; }
"}" { output::printToken(yylineno, RBRACE, yytext); return RBRACE; }
"[" { output::printToken(yylineno, LBRACK, yytext); return LBRACK; }
"]" { output::printToken(yylineno, RBRACK, yytext); return RBRACK; }

"=" { output::printToken(yylineno, ASSIGN, yytext); return ASSIGN; }
"=="|"!=" |"<"|">"|"<="|">=" { output::printToken(yylineno, RELOP, yytext); return RELOP; }
"+"|"-" |"*"|"/" { output::printToken(yylineno, BINOP, yytext); return BINOP; }

{COMMENT} { output::printToken(yylineno, COMMENT, ""); return COMMENT; }

{letter}+({letter}|{digit})* { output::printToken(yylineno, ID, yytext); return ID; }

{NUM} { output::printToken(yylineno, NUM, yytext); return NUM; }

{NUM_B} { output::printToken(yylineno, NUM_B, yytext); return NUM_B; }

{white_space} { /* Ignore whitespace */ }

\" {
    string_buffer.clear();
    BEGIN(STRING_STATE);
}

<STRING_STATE>\" {
    output::printToken(yylineno, STRING, string_buffer.c_str());
    BEGIN(INITIAL);
    return STRING;
}

<STRING_STATE>\\n {
    string_buffer += '\n';
}

<STRING_STATE>\\r {
    string_buffer += '\r';
}

<STRING_STATE>\\t {
    string_buffer += '\t';
}

<STRING_STATE>\\0 {
    string_buffer += '\0';
}

<STRING_STATE>\\\\ {
    string_buffer += '\\';
}

<STRING_STATE>\\\" {
    string_buffer += '\"';
}

<STRING_STATE>\\x{hex_digit}{2} {
    // Convert hex escape sequence to character
    char hex_str[3] = {yytext[2], yytext[3], '\0'};
    char *endptr;
    long val = strtol(hex_str, &endptr, 16);
    
    // Check if the character is in valid range
    if (val < 0x20 || val > 0x7E) {
        output::errorUndefinedEscape(&yytext[1]);
        exit(0);
    }
    
    string_buffer += static_cast<char>(val);
}

<STRING_STATE>\\x[0-1][0-9a-fA-F] {
    output::errorUndefinedEscape(&yytext[1]);
    exit(0);
}

<STRING_STATE>\\x[2-7][^0-9a-fA-F] {
    output::errorUndefinedEscape(&yytext[1]);
    exit(0);
}

<STRING_STATE>\\x. {
    output::errorUndefinedEscape(&yytext[1]);
    exit(0);
}

<STRING_STATE>\\x {
    output::errorUndefinedEscape(&yytext[1]);
    exit(0);
}

<STRING_STATE>\\. {
    output::errorUndefinedEscape(&yytext[1]);
    exit(0);
}

<STRING_STATE>\n {
    output::errorUnclosedString();
    exit(0);
}

<STRING_STATE><<EOF>> {
    output::errorUnclosedString();
    exit(0);
}

<STRING_STATE>[^\\\"\n]+ {
    string_buffer += yytext;
}

. { output::errorUnknownChar(yytext[0]); exit(0); }

%%














