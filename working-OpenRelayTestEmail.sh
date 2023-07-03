#!/bin/bash

#Generate a valid Social Security Number
function generate_ssn() {
SSN=""

for ((i=0; i<9; i++)); do
DIGIT=$((RANDOM%9+1))
SSN=$SSN$DIGIT
done
}

function validate_ssn() {

Validate the length is 9 characters
if [[ ${#SSN} -ne 9 ]]; then
return 1
fi

#No group can be all zeros
if [[ ${SSN:0:3} = "000" || ${SSN:3:2} = "00" || ${SSN:5:4} = "0000" ]]; then
return 1
fi

#Cannot start with '9'
if [[ ${SSN:0:1} = "9" ]]; then
return 1
fi

#First group cannot be comprised of only 6
if [[ ${SSN:0:3} = "666" ]]; then
return 1
fi

if (( SSN < 987654320 || SSN > 987654329 )); then
return 1
fi

return 0
}

function generate_and_validate_ssn() {
generate_ssn
validate_ssn
while (( $? != 0 )); do
generate_ssn
validate_ssn
done
}

echo -e "Enter IP address of SMTP server: "
read -r varSMTPServer

echo -e "Input sending email (can be anything): "
read -r varSenderEmail

echo -e "Input receiving email address: "
read -r varReceivingEmail

echo -e "Press 1 to send a test email or 2 to test with socials: "
read -r response

if [[ "$response" = "1" ]]; then
echo -e "Input text to include in the body (e.g., SMTP Openrelay): "
read -r varBody
swaks --to "$varReceivingEmail" --from "$varSenderEmail" --header "Subject: OpenRelay test $varSMTPServer" --body "$varBody" --server "$varSMTPServer"
elif [[ "$response" = "2" ]]; then
echo -e "How many socials would you like to generate?"
read -r varNumberofSocials
echo "Generating $varNumberofSocials socials and outputting to file ${varNumberofSocials}-ssn.txt"

for ((i=1; i<=varNumberofSocials; i++)); do
generate_and_validate_ssn
echo -e "${SSN:0:3}-${SSN:3:2}-${SSN:5:4}" >> "${varNumberofSocials}-ssn.txt"
done

swaks --to "$varReceivingEmail" --from "$varSenderEmail" --header "Subject: OpenRelay test $varSMTPServer" --body "@${varNumberofSocials}-ssn.txt" --server "$varSMTPServer"
else
echo -e "Incorrect selection. Please try again."
fi