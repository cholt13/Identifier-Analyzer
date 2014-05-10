cxref.exe : lex.yy.c
	gcc -g -o cxref.exe lex.yy.c -ll

lex.yy.c : cxref.l
	lex cxref.l

clean : 
	rm cxref.exe
	rm lex.yy.c
