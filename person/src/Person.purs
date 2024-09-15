module Person where

import Prelude
import Data.Maybe (Maybe(..))
import Data.Either (Either(..))

type Person = { 
  firstName            :: String
, lastName             :: String
, socialSecurityNumber :: String -- exactly 9 ascii digits
, maritalStatus        :: MaritalStatus
, phoneNumber          :: String -- exactly 10 ascii digits
}


-- PersonEdit is being imagined here for a classic web forms editor,
-- with a human dilligently typing in data to it and POST requests
-- firing when it's time to commit the changes. I'm also imagining
-- client side validation with feedback, for example "First Name is
-- Required".

type PersonEdit = {
  firstName            :: String
, lastName             :: String
, socialSecurityNumber :: String -- any string of characters
, maritalStatus        :: Maybe MaritalStatus
, phoneNumber          :: String -- any string of characters
}

data MaritalStatus = Single | Married
derive instance eqMaritalStatus :: Eq MaritalStatus
instance showMaritalStatus :: Show MaritalStatus where
  show Single = "Single"
  show Married = "Married"
-- Notes: considered "married :: Boolean", but that's not what the spec said. Also if we're dealing with government forms
-- then different applications might call for more extensibility https://www.lawdepot.com/resources/family-articles/marital-status/.


-- Its popular in Haskell tutorials I've read to not have the social security number be of type String, instead be of some
-- newtype that's impossible to `show`. But that's not a comprehensive personally identifying information policy (PII) -
-- I mean, Last Name is pretty clearly PII too. I'd rather be simple until I know more about the target application. 


-- The case of Charles Mongomery Burns illustrates why we don't use numbers for socialSecurityNumber or phoneNumber:
-- leading 0s are possible. Also we don't want to do math on them by mistake. 
-- monty :: Person
-- monty = { firstName: "Charles", lastName: "Burns" , socialSecurityNumber: "000000002", maritalStatus: Single, phoneNumber: "3141111111" }


{- BASIC validation function
personEditToPerson :: PersonEdit -> Maybe Person

For all string fields this would trim whitespace then reject if there's nothing left.
For socialSecurityNumber this would allow dashes if they fit the template xxx-xx-xxxx, but filter them out of the stored information.

For phoneNumber first I'd strip whitespace, then look at xxx-xxx-xxxx. I'm reading the conventions on wikipedia, at it looks like there can be spaces and parens in there too, all of which I'd strip, probably with a regex substitution. We might also try to accomodate for people prefixing "1-" or "+1" to their numbers, but at a certain point it's time to stop and give better UI queues cues rather than getting a very hard-to-read regex. 
-}


{-
ADVANCED validation function
If I'm working on web forms, I'd pretty soon replace the basic validator with some way to give feedback on why validation is failing.
It's type signature would probably start out like this:

personEditToPerson :: PersonEdit -> Either PersonInvalid Person

-- reasons why the form was invalid
type PersonInvalid = {
  firstName            :: Maybe String
, lastName             :: Maybe String
, socialSecurityNumber :: Maybe String
, maritalStatus        :: Maybe String
, phoneNumber          :: Maybe String
}
-}

{-
Module organization

I'd put Person in a widely shared module, used by business logic and UI alike - ideally sharing code with the server side too, and maybe even being Object Relational Maped into a database row.

I'd put PersonEdit as a datatype in a UI module, with very little
scope - I'd only use it for the PersonEditor component itself, and to
implement `personEditToPerson`. The reason `personEditToPerson`
deserves access is it's inherently got to know what kind of errors a
user would make. Imagine how different validation would be for a
microphone-based input technique.

Changing Person schemas would be a pain, and my main worry. For this
reason I'd favor a client-server monorepo, with shared code. Sending
json over the wire is something I haven't gotten to in PureScript yet
- though it seems like the problem it was intended to solve. Ideally
I'd attach another validator as the Person comes over the wire. This
wouldn't be the same validation function as `personEditToPerson`
because there's no `personEdit` to validate. THough I guess it's
trival to write that validator using `personEditToPerson
. personToPersonEdit`. I guess I'm leaving a little wiggle-room to
promote personEditToPerson out of the UI package for this purpose, so
that multiple code sides can verify the placement of '-' in SSNs and
so forth.

-}

-- TODO: consider `data` and so-called "smart constructors". 