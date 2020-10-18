# SendEmailMicrosoftExchange
This repository contains the code implemented in "Robot Framework" which does the Microsoft Exchange's API testing to send and receive email.

## Dependencies:

```text
CryptoLibrary: To decrypt password an client secret
RequestsLibrary: HTTP client keyword library
```

## Pre requisites:

```text
Python 3.8.3
robotframework library
CryptoLibrary
RequestsLibrary
```

Structure of the robot test cases have been kept in below hierarchy:
```text
/ Fsecure_Test_Assignment (Project Base)
     /Test
          sendEmailTestSuite.robot (Contains API test cases)
     /Resource
          sendEmail.robot. (Contains keyword implementations for Send Mail)
          common.robot. (Contains implementation for common keywords)
          readFileInBase64.py  (Python code to read file in base 64)
    /Testdata
            Cats.jpeg
            Test.txt
            testData.yaml (Contains message, sender and receiver's information)
```

Following Microsoft graph APIs has been utilized:
```text
POST      automationwork.onmicrosoft.com/oauth2/v2.0/token
POST      v1.0/me/sendMail
GET       v1.0/me/mailFolders/Inbox/messages
GET       v1.0/me/messages/${mailid}/attachments
```

## How to use:

### Step 1:
Clone the repository
### Step 2:
Update the Testdata/testData.yaml with client secret, sender user and receiver user's details. There is a possibility to modify the email subject and body as well.
### Step 3:
Password & Client secret needs to be encrypted, using below steps:
```text
1. Install robotframework-crypto pip3 install --upgrade robotframework-crypto
2. Generate key pair python -m CryptoLibrary
3. Encrypt the password python -m CryptoClient
```
### Step 4:
run command (from Fsecure_Test_Assignment folder): robot Test/sendEmailTestSuite.robot
 
