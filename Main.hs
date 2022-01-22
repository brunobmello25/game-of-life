module Main where

import System.Directory.Internal.Prelude (getArgs)

import File
import Game

main = do
  args <- getArgs
  let caseName = head args
  let iterationsCount = read(args !! 1) :: Int

  board <- File.readBoard caseName

  let nextCellState = Game.getNextCellState board 1 1

  print nextCellState

