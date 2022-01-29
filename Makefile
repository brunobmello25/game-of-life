build:
	ghc -o program Main.hs
	rm ./*.hi
	rm ./*.o
