module File where

readBoard :: String -> IO [String]
readBoard filePath = do
  contents <- readFile filePath
  return $ lines contents
