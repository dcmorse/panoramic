# person

Output: two representations of a person

1. Business logic, with clearly defined required valid fields.
1. Editable, with sloppy optional fields, allowing '-' characters in Social Security Numbers, and so on. 
   Upon validation these are massaged into their canonical representations


For this exercise we're assuming a very rigid list of fields for a Person:
* First Name
* Last Name
* Social Security Number
* Marital Status
* US Phone Number
Making the list of fields extensible is not a priority. 