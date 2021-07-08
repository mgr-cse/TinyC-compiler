flexFile = ass6_18CS30026_18CS30033_flex
bisonFile= ass6_18CS30026_18CS30033_yacc
headFile = ass6_18CS30026_18CS30033_translator
targetFile= ass6_18CS30026_18CS30033_target_translator

test: compiler.out
	./compiler.out ass6_18CS30026_18CS30033_test1.c ass6_18CS30026_18CS30033_quads1.out ass6_18CS30026_18CS30033_1.s
	gcc ass6_18CS30026_18CS30033_1.s -o test1.out
	./compiler.out ass6_18CS30026_18CS30033_test2.c ass6_18CS30026_18CS30033_quads2.out ass6_18CS30026_18CS30033_2.s
	gcc ass6_18CS30026_18CS30033_2.s -o test2.out
	./compiler.out ass6_18CS30026_18CS30033_test3.c ass6_18CS30026_18CS30033_quads3.out ass6_18CS30026_18CS30033_3.s
	gcc ass6_18CS30026_18CS30033_3.s -o test3.out
	./compiler.out ass6_18CS30026_18CS30033_test4.c ass6_18CS30026_18CS30033_quads4.out ass6_18CS30026_18CS30033_4.s
	gcc ass6_18CS30026_18CS30033_4.s -o test4.out
	./compiler.out ass6_18CS30026_18CS30033_test5.c ass6_18CS30026_18CS30033_quads5.out ass6_18CS30026_18CS30033_5.s
	gcc ass6_18CS30026_18CS30033_5.s -o test5.out
	#
	#
	# ############### IMPORTANT ################
	# if you want to run ith (1<=i<=5) test file
	#     run command ./test<i>.out 
	#     example: ./test1.out


compiler.out: y.tab.o lex.yy.o ${headFile}.o ${headFile}.h ${targetFile}.o
	g++ -g lex.yy.o y.tab.o $(headFile).o ${targetFile}.o -lfl -o compiler.out

${targetFile}.o: ${targetFile}.cxx ${headFile}.h
	g++ -c -g ${targetFile}.cxx 

y.tab.o: ${bisonFile}.y ${headFile}.h
	yacc -dtv ${bisonFile}.y
	g++ -c y.tab.c

lex.yy.o: ${flexFile}.l ${headFile}.h
	flex ${flexFile}.l
	g++ -c lex.yy.c

${headFile}.o: ${headFile}.cxx
	g++ -g -c ${headFile}.cxx

clean:
	rm lex.yy.c lex.yy.o y.tab.c y.tab.h y.output 
	rm y.tab.o ${headFile}.o ${targetFile}.o compiler.out
	rm test1.out test2.out test3.out test4.out test5.out
