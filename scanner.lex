&{
    #include <stdio.h>
    #include "tokens.h"
    #include <string>
    using std::string;
}

/* define  a global string buffer */
static string buffer;

#option yylineno
#option yywrap

%%

// string condition
%x STR
digit ([0-9])
letter ([a-zA-Z])
id {letter} ({letter}|{digit})*
white_space ([ \t\n\r])

// define postive numbers for B
positive_num [1-9][0-9]*
// define hex, and exclude 0-1 and out of range in errors
hex_digits [2-7][0-9A-Fa-f]

// define escape characters
string_escape \\[nrt\"\\]
hex_escape \\x{hex_digits}

// define error characters
// hex errors: 
// 1)not 0-9 and A-F..
// 2)starts with 0-1 means out of range
// 3) starts with 2-7 but doesnt end with 0-9A-Fa-f
// TODO: check first page restrictions on range of hex
bad_hex \\\x([^0-9A-Fa-f]|[0-1][0-9A-Fa-f]|[2-7][^0-9A-Fa-f])

// escape errors:
// 1) unknown escape character
bad_esc \\[^nrt\"\\x]

%%

"void"                          { output::printToken(yylineno, VOID, yytext); }
"int"                           { output::printToken(yylineno, INT, yytext); }
"byte"                          { output::printToken(yylineno, BYTE, yytext); }
"bool"                          { output::printToken(yylineno, BOOL, yytext); }
"and"                           { output::printToken(yylineno, AND, yytext); }
"or"                            { output::printToken(yylineno, OR, yytext); }
"not"                           { output::printToken(yylineno, NOT, yytext); }
"true"                          { output::printToken(yylineno, TRUE, yytext); }
"return"                        { output::printToken(yylineno, RETURN, yytext); }
"if"                            { output::printToken(yylineno, IF, yytext); }
"else"                          { output::printToken(yylineno, ELSE, yytext); }
"while"                         { output::printToken(yylineno, WHILE, yytext); }
"break"                         { output::printToken(yylineno, BREAK, yytext); }
"continue"                      { output::printToken(yylineno, CONTINUE, yytext); }
";'"                            { output::printToken(yylineno, SC, yytext); }
","                             { output::printToken(yylineno, COMMA, yytext); }
"("                             { output::printToken(yylineno, LPAREN, yytext); }
")"                             { output::printToken(yylineno, RPAREN, yytext); }
"{"                             { output::printToken(yylineno, LBRACE, yytext); }
"}"                             { output::printToken(yylineno, RBRACE, yytext); }
"["                             { output::printToken(yylineno, LBRACK, yytext); }
"]"                             { output::printToken(yylineno, RBRACK, yytext); }
"="                             { output::printToken(yylineno, ASSIGN, yytext); }
"=="                            { output::printToken(yylineno, RELOP, yytext); }
"!="                            { output::printToken(yylineno, RELOP, yytext); }
"<"                             { output::printToken(yylineno, RELOP, yytext); }
"<="                            { output::printToken(yylineno, RELOP, yytext); }
">"                             { output::printToken(yylineno, RELOP, yytext); }
">="                            { output::printToken(yylineno, RELOP, yytext); }
"+"                             { output::printToken(yylineno, BINOP, yytext); }
"-"                             { output::printToken(yylineno, BINOP, yytext); }
"*"                             { output::printToken(yylineno, BINOP, yytext); }
"/"                             { output::printToken(yylineno, BINOP, yytext); }
"%"                             { output::printToken(yylineno, BINOP, yytext); }

"//".*                          { output::printToken(yylineno, COMMENT, yytext); }

{id}                            { output::printToken(yylineno, ID, yytext); }


"0"|({positive_num}+)           { output::printToken(yylineno, NUM, yytext); }
"0b"|({positive_num}+b)         { output::printToken(yylineno, NUM_B, yytext); }

\"                              { buffer.clear(); BEGIN(STR); }

<STR> {string_escape}           { string_escape_handler(buffer, yytext); }

<STR> {hex_escape}              { hex_escape_handler(buffer, yytext); }

<STR> {bad_hex}|{bad_esc}       { output::errorUndefinedEscape(yytext+1); }

<STR> \"                        { output::printToken(yylineno, STRING, buffer.c_str()); BEGIN(INITIAL); }

<STR> \n|\r|<<EOF>>             { output::errorUnclosedString(); }

/* not sure yet what to do with the rest of the string */
[^\\\"\n\r]+                    {buffer.push_back(yytext[0]);}

%%
// string_escape_handler, handles string escapes
string string_escape_handler(string& buffer, const string& txt) {
    switch (txt[1]) {
        case 'n': buffer.push_back('\n'); break;
        case 't': buffer.push_back('\t'); break;
        case 'r': buffer.push_back('\r'); break;
        case '"': buffer.push_back('\"'); break;
        case '\\': buffer.push_back('\\'); break;
        }
    }

    return buffer;
}

// hex_escape_handler, handles hex escapes
string hex_escape_handler(string& buffer, const string& txt) {
    string hex_digits = txt.substr(2);
    char hex_char[3];
    hex_char[0] = '0';
    hex_char[1] = 'x';
    hex_char[2] = hex_digits[0];
    buffer.push_back(strtol(hex_char, nullptr, 16));

    return buffer;
}

int yywrap() {
    return 1;
}