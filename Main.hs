module Main where

import System.Directory.Internal.Prelude (getArgs)

import Board

main = do
  args <- getArgs
  let caseName = head args
  let iterationsCount = read(args !! 1) :: Int

  board <- Board.readBoard caseName

  let nextBoard = Board.getNextBoardState board

  print nextBoard