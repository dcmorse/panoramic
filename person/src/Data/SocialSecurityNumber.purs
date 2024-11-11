
module Data.SocialSecurityNumber (SocialSecurityNumber, mkSocialSecurityNumber, digitsOf) where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Char (toCharCode)
import Data.String (length)
import Data.String.CodeUnits (toCharArray)
import Data.Foldable (all)

newtype SocialSecurityNumber = SocialSecurityNumber String

-- The case of Charles Mongomery Burns illustrates why we don't use numbers for socialSecurityNumber 
-- leading 0s are possible. 
-- monty :: Person
-- monty = { firstName: "Charles", lastName: "Burns" , socialSecurityNumber: mkSocialSecurityNumber "000000002", ...}

mkSocialSecurityNumber :: String -> Maybe SocialSecurityNumber
mkSocialSecurityNumber s =
  -- In a real product I guess I'd work around 'xxx-xx-xxxx'-style dashes and marginal whitespace
  if length s == 9 && all isDigit (toCharArray s)
  then Just $ SocialSecurityNumber s
  else Nothing
  where 
  isDigit c = let code = toCharCode c
              in code >= zero && code <= nine
  zero = toCharCode '0'
  nine = toCharCode '9'

digitsOf :: SocialSecurityNumber -> String
digitsOf (SocialSecurityNumber s) = s


