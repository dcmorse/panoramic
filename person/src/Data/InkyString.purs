module Data.InkyString (InkyString, mkInkyString, stringOf) where
-- A string with 1 or more printing characters, and no whitespace at the beginning or end, suitable for a name field

import Prelude
import Data.Maybe (Maybe(..))
import Data.Char (toCharCode)
import Data.String (length)

newtype InkyString = InkyString String

mkInkyString :: String -> Maybe InkyString
mkInkyString s =
  -- In a real product I'd do the regex work to enforce the validation above
  Just $ InkyString s

stringOf :: InkyString -> String
stringOf (InkyString s) = s
