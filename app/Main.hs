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
  loop (start m, [])
  putStrLn ""

  where
    m = Plus (Plus (Lit 0) (Lit 1)) (Plus (Lit 2) (Lit 3))

type LoopState = (TermZipper, [TermZipper])

loop :: LoopState -> IO ()
loop (s, h) = do
  writeLine (prettyZipper s)
  key <- getKey
  let sh' =
        case key of
          "w" -> (navUp s, h)
          "a" -> (navLeft s, h)
          "s" -> (navDown s, h)
          "d" -> (navRight s, h)
          [c] | c `elem` "1234567890" ->
            (overwrite (read [c]) s, s:h)
          "+" -> (insertPlus s, s:h)
          "u" -> case h of
                  [] -> (s, h)
                  s':h' -> (s', h')
  loop sh'


getKey :: IO [Char]
getKey = reverse <$> getKey' ""
  where 
    getKey' chars = do
      char <- getChar
      more <- hReady stdin
      (if more then getKey' else return) (char:chars)

data Term
  = Lit Int
  | Plus Term Term

prettyTerm :: Term -> String
prettyTerm (Lit i) = show i
prettyTerm (Plus m n) =
  "( " ++ prettyTerm m ++ " + " ++ prettyTerm n ++ " )"

data TermFrame
  = InPlusL Term
  | InPlusR Term

prettyFrame :: TermFrame -> String -> String
prettyFrame (InPlusL n) m =
  "( " ++ m ++ " + " ++ prettyTerm n ++ " )"
prettyFrame (InPlusR m) n =
  "( " ++ prettyTerm m ++ " + " ++ n ++ " )"


-- term at a context
data TermZipper
  = Term :@ [TermFrame]

prettyZipper :: TermZipper -> String
prettyZipper (m :@ k) = go k ("▷" ++ prettyTerm m ++ "◁")
  where
    go [] m = m
    go (f:fs) m = go fs (prettyFrame f m) 

start :: Term -> TermZipper
start m = m :@ []

navUp :: TermZipper -> TermZipper
navUp (m :@ (InPlusL n:k)) = Plus m n :@ k
navUp (n :@ (InPlusR m:k)) = Plus m n :@ k
navUp s = s

navLeft :: TermZipper -> TermZipper
navLeft (n :@ (InPlusR m:k)) = m :@ (InPlusL n:k)
navLeft s = s

navDown :: TermZipper -> TermZipper
navDown (Plus m n :@ k) = m :@ (InPlusL n : k)
navDown s = s

navRight :: TermZipper -> TermZipper
navRight (m :@ (InPlusL n:k)) = n :@ (InPlusR m:k)
navRight s = s

overwrite :: Int -> TermZipper -> TermZipper
overwrite i (_ :@ k) = Lit i :@ k

insertPlus :: TermZipper -> TermZipper
insertPlus (m :@ k) = Lit (-1) :@ (InPlusR m:k)

