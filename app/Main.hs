module Main (main) where

import System.Console.ANSI
import System.IO
import Control.Monad

writeLine :: String -> IO ()
writeLine s = do
  clearLine
  setCursorColumn 0
  putStr s
  hFlush stdout

main :: IO ()
main = do
  hSetBuffering stdin NoBuffering
  hSetEcho stdin False
  loop
  putStrLn ""

loop :: IO ()
loop = do
  key <- getKey
  case key of
    "w" -> writeLine "w"
    "a" -> writeLine "a"
    "s" -> writeLine "s"
    "d" -> writeLine "d"
    _        -> return ()
  loop

getKey :: IO [Char]
getKey = reverse <$> getKey' ""
  where 
    getKey' chars = do
      char <- getChar
      more <- hReady stdin
      (if more then getKey' else return) (char:chars)
