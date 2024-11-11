module Person where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import SocialSecurityNumber
import PhoneNumber

type Person = { 
  firstName            :: String
, lastName             :: String
, socialSecurityNumber :: SocialSecurityNumber
, maritalStatus        :: MaritalStatus
, phoneNumber          :: PhoneNumber
}

