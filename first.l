
/*Lex Specification of a TINY Scanner*/

%{
/* Literal block */
#include <stdio.h>
#include "scanner.h" /* Scanner header file */


int line = 1; /* Current line number */
int pos = 0; /* Start position of token */
int epos = 1; /* End position of token */
int totalErrors;
void lex_err(char * s1, char * s2);

%}

letter [A-Za-z_]; /* letter can be underscore */
digit [0-9];
blank_str [ \t\n];
identifier {letter}({letter}|{digit})* ;
int_literal {digit}+ ;
str_literal [\"(\\.|[^"])*\"]; // Old implementations: [\"([^\"\n])*\"];([\"((\\.)|([^"])*\"]);





/* Regular definitions to match invalid tokens */
open_string \"([^\"\n])*$ ;

%% /* Second Section: Rules & Actions */
\n {line++; epos = 1;};
[ \t\n] {epos += yyleng;}
[Ii][Ff] {pos = epos; epos += 2; return IF_TK;}
[Tt][Hh][Ee][Nn] {pos = epos; epos += 4; return THEN_TK;}
[Ee][Ll][Ss][Ee] {pos = epos; epos += 4; return ELSE_TK;}
[Ee][Nn][Dd] {pos = epos; epos += 3; return END_TK;}
[Ww][Hh][Ii][Ll][Ee] {pos = epos; epos += 5; return WHILE_TK;}
[Dd][Oo] {pos = epos; epos += 2; return DO_TK;}
[Rr][Ee][Aa][Dd] {pos = epos; epos += 4; return READ_TK;}
[Ww][Rr][Ii][Tt][Ee] {pos = epos; epos += 5; return WRITE_TK;}
([A-Za-z_])(([A-Za-z_])|([0-9]))*  {pos = epos; epos += yyleng; return ID;} //Any identifier {[A-Za-z_]}({[A-Za-z_]}|{[0-9]})*
 \"(\\.|[^"])*\" {pos = epos; epos += yyleng; return STRLIT;}
([0-9])+ {pos = epos; epos += yyleng; return INTLIT;}

"+" { pos = epos; epos += 1; return ADDOP;}
"-" { pos = epos; epos += 1; return ADDOP;}
"*" { pos = epos; epos += 1; return MULOP;}
"/" { pos = epos; epos += 1; return MULOP;}
"=" { pos = epos; epos += 1; return RELOP;}
"<>" { pos = epos; epos += 2; return RELOP;}
"<" { pos = epos; epos += 1; return RELOP;}
"<=" { pos = epos; epos += 2; return RELOP;}
">" { pos = epos; epos += 1; return RELOP;}
">=" { pos = epos; epos += 2; return RELOP;}
":=" { pos = epos; epos += 2; return ASGNOP;}
"," {pos = epos; epos += 1; return  COMM;}
";" {pos = epos; epos += 1; return SEMI_COLUMN;}
"(" {pos = epos; epos += 1; return BRACKET_TK;}
")" {pos = epos; epos += 1; return BRACKET_TK;}


"{" { 

	int c; 
	int start_line = line; /* comment start line */
	int pos = epos; /* comment start position */
	epos++; /* for "{" */
	c = input();
	while (c != EOF) 
	{
		epos++; // each character leads to an addition  in the position
		if(c =='}') break ; //end of the comment
		if (c =='\n') {line++; epos=1;}; // multiple lines are allowed in this tyoe of comment
		c = input(); //update the character
	}
	if (c == EOF) {
		/* reached EOF */
		int eof_line = line; //the last line
		line = start_line; // to report in the error, when this comment has started
		lex_err("Open Comment", "");
		line = eof_line; // updating its value again
		}
    } 
\"([^\"\n])*$ { pos = epos; epos += yyleng; lex_err("Open String", yytext);
		return STRLIT;}
.	      { pos = epos; epos += 1; lex_err("Unknown Character", yytext);}

%%

// Third Section

void lex_err(char * s1, char * s2)
	{
	fprintf(stderr, "l%d, c%d: %s %s\n", line, pos, s1, s2);
	totalErrors++;
	}

// yywrap is required by lex
// return 1 means no wrap to another source file
int yywrap() { return 1; }

int main()
{
int ntoken, vtoken;

ntoken = yylex();
while (ntoken) {
printf("%d\n", ntoken);
ntoken = yylex();

}

return 0;
}