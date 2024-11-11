module Demo where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Person (Person)
import Data.SocialSecurityNumber as SSN
import Data.PhoneNumber as Phone
import Data.InkyString (mkInkyString, stringOf)
import Data.MaritalStatus (MaritalStatus(..))


-- I'm imagining a project that does some web CRUD of a Person.
-- Obviously I'm not submitting a whole UI for that, but instead
-- showing file locations for the types needed to build it.  For the
-- most part the 'business-logic' types are living in the Data folder,
-- one per type - that seemed the most idiomatic to me based on my
-- short PureScript experience. But for the types that live closer to
-- the component, I'm just dumping them here in the root and waving my
-- hands that they should live "close to the CRUD Person editor
-- components".
--
-- It seems likely that `Person`s will be sent over the wire, and
-- those need to be validated too. In my (React) experience I usually
-- do the network parsing in a component, so hiding the types and
-- functions nearby made sense - they're never needed elsewhere.  In
-- other architectures where there are more callers, promoting to the
-- Data directory seems fine to me.

type UnvalidatedPerson = { firstName            :: String
                         , lastName             :: String
                         , socialSecurityNumber :: String
                         , maritalStatus        :: Maybe MaritalStatus
                         , phoneNumber          :: String
                         }

mkPerson :: UnvalidatedPerson -> Maybe Person
mkPerson up = do
  firstName <- mkInkyString up.firstName
  lastName <- mkInkyString up.lastName
  socialSecurityNumber <- SSN.mkSocialSecurityNumber up.socialSecurityNumber
  maritalStatus <- up.maritalStatus
  phoneNumber <- Phone.mkPhoneNumber up.phoneNumber
  pure { firstName, lastName, socialSecurityNumber, maritalStatus, phoneNumber }


mkUnvalidatedPerson :: Person -> UnvalidatedPerson
mkUnvalidatedPerson p = { firstName, lastName, socialSecurityNumber, maritalStatus, phoneNumber}
  where
  firstName = stringOf p.firstName
  lastName = stringOf p.lastName
  socialSecurityNumber = SSN.digitsOf p.socialSecurityNumber
  maritalStatus = Just p.maritalStatus
  phoneNumber = Phone.digitsOf p.phoneNumber

-- Most. Boring. Demo. Ever.
jane :: Maybe Person
jane = mkPerson {
    firstName: "Jane"
  , lastName: "Doe"
  , socialSecurityNumber: "123456789"
  , phoneNumber: "3145851234"
  , maritalStatus: Just Single
  }
