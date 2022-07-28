#!/bin/bash

# Generate a valid Social Security Number

function generate() {
  SSN=""
  valid=0

  for i in {1..9}; do
    DIGIT=$[RANDOM%9+1]
    SSN=$SSN$DIGIT
  done
}

function validate() {
  valid=1

  # Validate the length is 9 characters
  if [ ${#SSN} -ne 9 ]
  then
    valid=0
    echo "Invalid: SSN length is not 9 characters"
  fi

  # No group can be all zeros
  if [ ${SSN:0:3} -eq "000" ] || [ ${SSN:3:2} -eq "00" ] || [ ${SSN:5:4} -eq "0000" ]
  then
    valid=0
    echo "Invalid: No SSN group may be comprised of all zeroes"
  fi

  # Cannot start with '9'
  if [ ${SSN:0:1} -eq "9" ]
  then
    valid=0
    echo "Invalid: SSN Cannot begin with a 9"
  fi

  # First group cannot be comprised of only 6
  if [ ${SSN:0:3} -eq "666" ]
  then
    valid=0
    echo "Invalid: Primary SSN group cannot be 666"
  fi

  if [ ${SSN} -lt "987654329" ] && [ ${SSN} -gt "987654320" ]
  then
    valid=0
    echo "Invalid: Number range between 987654329 and 987654320 is not allowed"
  fi

}

valid=0

while [ $valid -eq 0 ]
do
  generate
  echo -e "\nTesting generated number ${SSN} for validity..."
  validate
done

echo -e "${SSN:0:3}-${SSN:3:2}-${SSN:5:4}\n"