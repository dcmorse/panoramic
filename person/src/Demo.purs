module Demo where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Either (Either(..))
import Data.Person
import Data.SocialSecurityNumber
import Data.PhoneNumber
import Data.InkyString
import Data.MaritalStatus

jane :: Person
jane = { firstName: mkInkyString "Jane"
       , lastName: mkInkyString "Doe"
       , socialSecurityNumber: mkSocialSecurityNumber "123456789"
       , phoneNumber: mkPhoneNumber: "3145851234"
       , maritalStatus: Single
       }

-- EditablePerson is being imagined here for a classic web forms editor,
-- with a human dilligently typing in data to it and POST requests
-- firing when it's time to commit the changes. I'm also imagining
-- client side validation with feedback, for example "First Name is
-- Required".

type EditablePerson = { firstName            :: String
                      , lastName             :: String
                      , socialSecurityNumber :: String
                      , maritalStatus        :: Maybe MaritalStatus
                      , phoneNumber          :: String
                      }

mkPerson :: EditablePerson -> Maybe Person
mkPerson ep = do
  firstName <- mkInkyString ep.firstName
  lastName <- mkInkyString ep.lastName
  socialSecurityNumber <- mkSocialSecurityNumber ep.socialSecurityNumber
  maritalStatus <- ep.maritalStatus
  phoneNumber <- ep.phoneNumber
  return { firstName, lastName, socialSecurityNumber, maritalStatus, phoneNumber }



{- BASIC validation function
mkPerson :: EditablePerson -> Maybe Person

* For socialSecurityNumber and phoneNumber this would delegate to
  mkPhoneNumber and mkSocialSecurityNumber. Somewhere in that path
  whitespace would be trimmed, either in the 'smart constructors' or
  before. I'd lean towards the smart constructors. 

* For the other string fields this would perhaps trim whitespace then
  reject if there's nothing left. If I'm doing _any_ kind of validation
  then shouldn't I go hog wild with the 'smart constructor' pattern
  adopted in the ssn and phone number and adopt a NonBlankString newtype?
  I don't have enough experience in this idiom to know the answer, so I
  kept things as simple as I could for the name fields. 

* For maritalStatus this would make sure it's not `Nothing`.

I considered a `Either (Array FailReasons) Person` type, but discarded
the idea. I don't want to go to the trouble of having each web
input element parse its status from some big list of errors. Each
input field knows perfectly well whether it's part will succeed or
fail based on a quick inline check.

-}


{-
Module organization

I'd put Person in a widely shared module, used by business logic and
UI alike - ideally sharing code with the server side too, and maybe
even being Object Relational Maped into a database row.

I'd put EditablePerson as a datatype in a UI module, close to the
component itself, with very little scope - I'd only use it for the
component itself, and to implement `mkPerson`. The reason `mkPerson`
deserves access is it's inherently got to know what kind of errors a
user would make. Imagine how different validation would be for a
microphone-based input technique.

Changing Person schemas would be a pain, and my main worry. For this
reason I'd favor a client-server monorepo, with shared code. Sending
json over the wire is something I haven't gotten to in PureScript yet
- though it seems like the problem it was intended to solve. Ideally
I'd attach another validator as the Person comes over the wire (edit:
since writing this I have gotten to it). This wouldn't be the same
validation function as `personEditToPerson` because there's no
`personEdit` to validate. Though I guess it's trival to write that
validator using `personEditToPerson <<< personToPersonEdit`. I guess I'm
leaving a little wiggle-room to promote personEditToPerson out of the
UI package for this purpose, so that multiple code sides can verify
the placement of '-' in SSNs and so forth.

-}

