module Data.Person (Person) where

import Data.InkyString (InkyString)
import Data.SocialSecurityNumber (SocialSecurityNumber)
import Data.PhoneNumber (PhoneNumber)
import Data.MaritalStatus (MaritalStatus)

-- I went all-in on the smart-constructor idiom. SSN and Phone were
-- no-brainers.  Earlier drafts had `String` instead of `InkyString` -
-- it was a close call, but I think it's worth it to get all the
-- validations squared away before the object's even constructed. This
-- approach ensures that each Person's fields are validated exactly
-- once and we can't forget to do it.

type Person = { firstName            :: InkyString
              , lastName             :: InkyString
              , socialSecurityNumber :: SocialSecurityNumber
              , maritalStatus        :: MaritalStatus
              , phoneNumber          :: PhoneNumber
              }
