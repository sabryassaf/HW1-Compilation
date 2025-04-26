%{
    #include <stdio.h>
    #include "tokens.hpp"
    #include "output.hpp"  
    #include <string>
    using std::string;
    
    /* define global string buffer */
    static string buffer;
    static bool finished_string = false;
    
    /* Forward declarations for functions used in the rules */
    void string_escape_handler(string& buffer, const string& txt);
    void hex_escape_handler(string& buffer, const string& txt);
%}

%option yylineno
%option yywrap

/* string condition */
%x STR

/* define digit, letter, id, white_space */
digit   [0-9]
letter  [a-zA-Z]
id  {letter}({letter}|{digit})*
white_space ([\t\n\r ])

/* define postive numbers for BINOP and HEX */
positive_num    [1-9][0-9]*

/* define hex, and exclude 0-1 and out of range in errors */
hex_digits  [2-7][0-9A-Fa-f]

/* define escape characters */
string_escape   \\[nrt0\"\\]
hex_escape  \\x{hex_digits}

/* define error characters 
 hex errors: 
 1)not 0-9 and A-F.. 
 2)starts with 0-1 means out of range
 3) starts with 2-7 but doesnt end with 0-9A-Fa-f
 TODO: check first page restrictions on range of hex */
bad_hex \\x([^0-9A-Fa-f]|[0-1][0-9A-Fa-f]|[2-7][^0-9A-Fa-f])

/* escape errors:
 1) unknown escape character */
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
"false"                         { output::printToken(yylineno, FALSE, yytext); }
"return"                        { output::printToken(yylineno, RETURN, yytext); }
"if"                            { output::printToken(yylineno, IF, yytext); }
"else"                          { output::printToken(yylineno, ELSE, yytext); }
"while"                         { output::printToken(yylineno, WHILE, yytext); }
"break"                         { output::printToken(yylineno, BREAK, yytext); }
"continue"                      { output::printToken(yylineno, CONTINUE, yytext); }
";"                             { output::printToken(yylineno, SC, yytext); }
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


"0"|{positive_num}               { output::printToken(yylineno, NUM, yytext); }
"0b"|{positive_num}b            { output::printToken(yylineno, NUM_B, yytext); }

\"                              { buffer.clear();finished_string = false; BEGIN(STR); }

<STR>{string_escape}           { if (!finished_string) {
                                    string_escape_handler(buffer, yytext); }}

<STR>{hex_escape}              { if (!finished_string) {
                                    hex_escape_handler(buffer, yytext); }}

<STR>{bad_hex}|{bad_esc}       { output::errorUndefinedEscape(yytext+1); }

<STR>\"                        { output::printToken(yylineno, STRING, buffer.c_str());
                                finished_string = true;
                                BEGIN(INITIAL); }

<STR>\n|\r                     { output::errorUnclosedString(); }
<STR>[^\\"\n\r]+               { if (!finished_string) buffer.append(yytext); }
<STR><<EOF>>                   { output::errorUnclosedString(); }

({white_space})+                {/* do nothing */}
.                               { output::errorUnknownChar(yytext[0]); }
%%

/* string_escape_handler, handles string escapes */
void string_escape_handler(string& buffer, const string& txt) {
    switch (txt[1]) {
        case 'n': buffer.push_back('\n'); break;
        case 't': buffer.push_back('\t'); break;
        case 'r': buffer.push_back('\r'); break;
        case '"': buffer.push_back('\"'); break;
        case '\\': buffer.push_back('\\'); break;
        case '0': 
            buffer.push_back('\0');
            finished_string = true;
            break;
        }
}

/* hex_escape_handler, handles hex escapes */
void hex_escape_handler(string& buffer, const string& txt) {
    int value = strtol(txt.substr(2, 2).c_str(), nullptr, 16);
    buffer.push_back(static_cast<char>(value));
}

int yywrap() {
    return 1;
}