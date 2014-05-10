clexer.exe : lex.yy.c
	gcc -g -o clexer.exe lex.yy.c -ll

lex.yy.c : clexer.l
	lex clexer.l

clean : 
	rm clexer.exe
	rm lex.yy.c
