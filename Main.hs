module Main where

import System.Directory.Internal.Prelude (getArgs)

import File
import Game

main = do
  args <- getArgs
  let caseName = head args
  let iterationsCount = read(args !! 1) :: Int

  board <- File.readBoard caseName

  let nextBoard = Game.getNextBoardState board

  print nextBoard