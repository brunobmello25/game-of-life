module Game where

import Board

gameLoop :: [String] -> Int -> Int -> ([String], Int)
gameLoop board 0 _ = (board, 0)
gameLoop board iterationsCount currentIteration
  | currentIteration >= iterationsCount = (board, currentIteration)
  | board == nextBoard = (board, currentIteration)
  | otherwise = gameLoop nextBoard iterationsCount (currentIteration + 1)
  where
    nextBoard = Board.getNextBoardState board
