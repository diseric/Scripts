import random

# Generate a valid Social Security Number
def generate_ssn():
    ssn = ""
    
    for i in range(9):
        digit = random.randint(1, 9)
        ssn += str(digit)
    
    return ssn

def validate_ssn(ssn):
    # Validate the length is 9 characters
    if len(ssn) != 9:
        return False

    # No group can be all zeros
    if ssn[:3] == "000" or ssn[3:5] == "00" or ssn[5:] == "0000":
        return False

    # Cannot start with '9'
    if ssn[0] == "9":
        return False

    # First group cannot be comprised of only 6
    if ssn[:3] == "666":
        return False

    if not 987654320 <= int(ssn) <= 987654329:
        return False

    return True

def generate_and_validate_ssn():
    valid_ssn = False
    
    while not valid_ssn:
        ssn = generate_ssn()
        valid_ssn = validate_ssn(ssn)
    
    return ssn

varSMTPServer = input("Enter the IP address of the SMTP server: ")
varSenderEmail = input("Input the sending email (can be anything): ")
varReceivingEmail = input("Input the receiving email address: ")

response = input("Press 1 to send a test email or 2 to test with socials: ")

if response == "1":
    varBody = input("Input text to include in the body (e.g., SMTP Openrelay): ")
    command = f"swaks --to {varReceivingEmail} --from {varSenderEmail} --header 'Subject: OpenRelay test {varSMTPServer}' --body '{varBody}' --server {varSMTPServer}"
    print(command)
    # Execute the swaks command
elif response == "2":
    varNumberofSocials = int(input("How many socials would you like to generate? "))
    print(f"Generating {varNumberofSocials} socials and outputting to file {varNumberofSocials}-ssn.txt")
    
    with open(f"{varNumberofSocials}-ssn.txt", "w") as file:
        for _ in range(varNumberofSocials):
            ssn = generate_and_validate_ssn()
            formatted_ssn = f"{ssn[:3]}-{ssn[3:5]}-{ssn[5:]}"
            file.write(formatted_ssn + "\n")
            
    command = f"swaks --to {varReceivingEmail} --from {varSenderEmail} --header 'Subject: OpenRelay test {varSMTPServer}' --body @{varNumberofSocials}-ssn.txt --server {varSMTPServer}"
    print(command)
    # Execute the swaks command
else:
    print("Incorrect selection. Please try again.")
