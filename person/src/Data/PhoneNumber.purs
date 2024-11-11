
module Data.PhoneNumber (PhoneNumber, mkPhoneNumber, digitsOf) where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Char (toCharCode)
import Data.String (length)
import Data.String.CodeUnits (toCharArray)
import Data.Foldable (all)

newtype PhoneNumber = PhoneNumber String

mkPhoneNumber :: String -> Maybe PhoneNumber
mkSocialSecurityNumber s =
  -- In a real product I guess I'd work around all the phone number formats in common usage
  if length s == 10 && all isDigit (toCharArray s)
  then Just $ PhoneNumber s
  else Nothing
  where 
  isDigit c = let code = toCharCode c
              in code >= zero && code <= nine
  zero = toCharCode '0'
  nine = toCharCode '9'

digitsOf :: PhoneNumber -> String
digitsOf (PhoneNumber s) = s


