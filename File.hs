module File where

readBoard :: String -> IO [String]
readBoard caseName = do
  let filePath = "exemplos/" ++ caseName ++ ".txt"
  
  contents <- readFile filePath
  return $ lines contents
