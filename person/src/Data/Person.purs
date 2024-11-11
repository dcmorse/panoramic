module Person (Person) where

import Data.InkyString
import Data.SocialSecurityNumber
import Data.PhoneNumber
import Data.MaritalStatus

type Person = { firstName            :: InkyString
     	      , lastName             :: InkyString
              , socialSecurityNumber :: SocialSecurityNumber
              , maritalStatus        :: MaritalStatus
              , phoneNumber          :: PhoneNumber
              }

