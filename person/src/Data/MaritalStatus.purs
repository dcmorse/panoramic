module Data.MaritalStatus (MaritalStatus(..)) where

import Prelude

data MaritalStatus = Single | Married
derive instance eqMaritalStatus :: Eq MaritalStatus
instance showMaritalStatus :: Show MaritalStatus where
  show Single = "Single"
  show Married = "Married"

-- Notes: I considered using "married :: Boolean" but decided against it for a couple of reasons
-- 1. It's not what the spec said. 
-- 2. `x == Single` lands differently than `x != Married`, even if they're the same according to this data type.
--    In this matter I actually trust the expressiveness of human coders over raw logic, if perchance the
--    type were to ever need extending.

