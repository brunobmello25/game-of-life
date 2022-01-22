module Main where

import File
import System.Directory.Internal.Prelude (getArgs)

main = do
  args <- getArgs
  let filePath = head args
  let iterationsCount = read(args !! 1) :: Int

  board <- File.readBoard filePath

  print board
