module Board where

readBoard :: String -> IO [String]
readBoard caseName = do
  let filePath = "exemplos/" ++ caseName ++ ".txt"
  
  contents <- readFile filePath
  return $ lines contents

countCellsAroundCoordinate :: [String] -> Int -> Int -> Char -> Int
countCellsAroundCoordinate board x y kind =
  let
    coordinates = [(a, b) |
      a <- [x - 1 .. x + 1],
      a >= 0,
      b <- [y - 1 .. y + 1],
      b >= 0,
      a < length board,
      b < length (board !! a),
      (a, b) /= (x, y)]
  in
  length $ filter (\(a, b) -> board !! a !! b == kind) coordinates

getNextCellState :: [String] -> Int -> Int -> Char
getNextCellState board x y =
  let
    aliveCount = countCellsAroundCoordinate board x y 'a'
    deadCount = countCellsAroundCoordinate board x y '.'
    zombieCount = countCellsAroundCoordinate board x y 'z'
    currentCell = board !! x !! y
  in
    if currentCell == '.' && aliveCount == 3
      then 'a'
    else if currentCell == 'a' && zombieCount >= 2
      then 'z'
    else if (currentCell == 'a' && aliveCount < 2 && zombieCount < 2 || currentCell == 'a' && aliveCount > 3 && zombieCount == 0) || currentCell == 'z' && aliveCount == 0 then '.' else currentCell

getNextRowState :: [String] -> Int -> String
getNextRowState board row =
  let
    rowCells = board !! row
    rowCellsNextState = map (getNextCellState board row) [0 .. length rowCells - 1]
  in
    rowCellsNextState

getNextBoardState :: [String] -> [String]
getNextBoardState board =
  let
    boardNextState = map (getNextRowState board) [0 .. length board - 1]
  in
    boardNextState

printBoard :: [String] -> IO ()
printBoard board =
  let
    boardString = unlines board
  in
    putStrLn boardString
