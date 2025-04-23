%{
#include "tokens.hpp"
#include "output.hpp"

output output;

%}
%option yylineno
%x STRING_STATE

digit [0-9]
hex_digit (x([2-7][0-9a-fA-F])
white_space [ \t\n\r]
letter [a-zA-Z]
COMMENT         \/\/.*
NUM             0|[^0]*{digit}+
NUM_B           (0|{NUM})b

%%

"void" { return VOID; }
"int" { return INT; }
"byte" { return BYTE; }
"bool" { return BOOL; }
"and" { return AND; }
"or" { return OR; }
"not" { return NOT; }
"true" { return TRUE; }
"false" { return FALSE; }
"return" { return RETURN; }
"if" { return IF; }
"else" { return ELSE; }
"while" { return WHILE; }
"break" { return BREAK; }
"continue" { return CONTINUE; }

";" { return SC; }
"," { return COMMA; }
"(" { return LPAREN; }
")" { return RPAREN; }
"{" { return LBRACE; }
"}" { return RBRACE; }
"[" { return LBRACK; }
"]" { return RBRACK; }

"=" { return ASSIGN; }
"=="|"!=" |"<"|">"|"<="|">=" { return RELOP; }
"+"|"-" |"*"|"/" { return BINOP; }

{COMMENT} { return COMMENT; }

{letter}+({letter}|{digit})* { return ID; }

{NUM} { return NUM; }

{NUM_B} { return NUM_B; }


\" {
    string_buffer = "";
    BEGIN(STRING_STATE);
}

<STRING_STATE>
{
    {hex_digit} {
        string_buffer += yytext;
    }
    \\x[0-1][0-9a-fA-F] { return HEX_OUT_OF_RANGE; }
    \\x[2-7][^0-9a-fA-F] { return HEX_OUT_OF_RANGE; }
    \\x[8-9]. {return HEX_OUT_OF_RANGE;}
    \\x[a-fA-F]. {return HEX_OUT_OF_RANGE;}
    \\x((.{0,1}) | [^0-9a-fA-F]{2}) {return HEX_OUT_OF_RANGE;}
    \\^[x0trn\"\\] {return ESCAPE_ERROR;}
    \n {return UNCLOSED_STRING;}
    \r {return UNCLOSED_STRING;}
        
}














