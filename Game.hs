module Game where

countCellsAroundCoordinate :: [[Char]] -> Int -> Int -> Char -> Int
countCellsAroundCoordinate grid x y kind =
  let
    coordinates = [(a, b) |
      a <- [x - 1 .. x + 1],
      a >= 0,
      b <- [y - 1 .. y + 1],
      b >= 0,
      a < length grid,
      b < length (grid !! a),
      (a, b) /= (x, y)]
  in
  length $ filter (\(a, b) -> grid !! a !! b == kind) coordinates

-- TODO
getNextCellState :: [[Char]] -> Int -> Int -> Char
getNextCellState board x y =
  let
    aliveCount = countCellsAroundCoordinate board x y 'a'
    deadCount = countCellsAroundCoordinate board x y '.'
    zombieCount = countCellsAroundCoordinate board x y 'z'
    currentCell = board !! y !! x
  in
    if currentCell == '.' && aliveCount == 3
      then 'a'
    else if currentCell == 'a' && zombieCount >= 2
      then 'z'
    else if ((currentCell == 'a' && aliveCount < 2 && zombieCount < 2) || (currentCell == 'a' && aliveCount > 3 && zombieCount == 0)) || (currentCell == 'z' && aliveCount == 0) then '.' else currentCell