build:
	if [ -f "program" ]; then rm program; fi
	ghc -o program Main.hs
	rm ./*.hi
	rm ./*.o

clean:
	rm ./*.hi
	rm ./*.o
	if [ -f "program" ]; then rm program; fi
