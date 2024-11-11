# person

**Deliverable**: two representations of a person and conversion functions
between them

1. A validated `Person` for business logic reading. 
1. A `UnvalidatedPerson` sloppy optional fields, allowing '-'
   characters in Social Security Numbers, and so on.  Upon validation
   these are massaged into a Person


For this exercise we're assuming a very rigid list of fields for a Person:
* First Name
* Last Name
* Social Security Number
* Marital Status
* US Phone Number

Making the list of fields extensible is not a priority.

## Reading Order

Read the files in this order.

1. [Demo.purs](src/Demo.purs) defines `UnvalidatedPerson` and conversion function signatures
1. [Data/Person.purs](src/Data/Person.purs) defines `Person`
1. [Data/SocialSecurityNumber.purs](src/Data/SocialSecurityNumber.purs) and the suspiciously similar [Data/PhoneNumber.purs](src/Data/PhoneNumber.purs)
1. [Data/InkyString.purs](src/Data/InkyString.purs) for non-blank strings
1. [Data/MaritalStatus.purs](src/Data/MaritalStatus.purs)

## Compiling

```
npx spago build
```
Note: it doesn't actually do anything, but the hundreds of compiler errors I churned through during development helped a lot. 

