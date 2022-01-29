build:
	if [ -f "program" ]; then rm program; fi
	ghc --make ./src/Main.hs -i src/Board.hs -i src/Game.hs -o program
	rm ./src/*.hi
	rm ./src/*.o
