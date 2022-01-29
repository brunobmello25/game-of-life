module Main where

import System.Directory.Internal.Prelude (getArgs)

import Board
import Game

main :: IO ()
main = do
  args <- getArgs
  let caseName = head args
  let iterationsCount = read(args !! 1) :: Int

  initialBoard <- Board.readBoard caseName

  let result = Game.gameLoop initialBoard iterationsCount 0

  let resultBoard = fst result
  let resultIterationsCount = snd result

  putStrLn $ "Número de iterações executadas: " ++ show resultIterationsCount
  putStrLn ""
  putStrLn "Tabuleiro resultante:"
  putStrLn ""
  print resultBoard
