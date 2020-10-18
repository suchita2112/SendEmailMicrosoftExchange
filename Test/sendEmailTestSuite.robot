*** Settings ***
Resource                               ../Resource/sendEmail.robot
Variables                              ${CURDIR}/../TestData/testData.yaml
Library                                ../Resource/readFileInBase64.py
Library                                OperatingSystem
Library                                CryptoLibrary

*** Variables ***
${BASE_URL}                            https://login.microsoftonline.com/
${TOKEN_API}                           automationwork.onmicrosoft.com/oauth2/v2.0/token
${GRAPH_BASE_URL}                      https://graph.microsoft.com/
${SEND_MAIL_API}                       v1.0/me/sendMail
${READ_MAIL_API}                       v1.0/me/mailFolders/Inbox/messages
${READ_ATTACHMENT_API}                 v1.0/me/messages/AAMkADhkMTRhOTkwLTc1YTMtNGJjNS1hODgwLTZkYmUyMDUxZmY3NgBGAAAAAAA0BcxviXRZT4Tm8u5wIG8SBwAVz3HRYHegQ74amgijTnEDAAAAAAEMAAAVz3HRYHegQ74amgijTnEDAAACdTKrAAA=/attachments

*** Test Cases ***

TC:1 Send Email From One User To Another
    ${senderPassword}=                 Decode Encrypted Text    ${SENDER_PASSWORD}
    ${clientSecret}=                   Decode Encrypted Text    ${CLIENT_SECRET}
    ${MESSAGE_WITHOUT_ATTACHMENT.message.toRecipients[0].emailAddress.address}=    Update Variable in Test Data Dictionary    ${MESSAGE_WITHOUT_ATTACHMENT.message.toRecipients[0].emailAddress.address}    ${RECEIVER_EMAIL_ADDRESS}
    ${fileContents}=                   Convert Robot Dictionary To Json            ${MESSAGE_WITHOUT_ATTACHMENT}

    ${params}                          Create Dictionary     client_id=${CLIENT_ID}
    ...                                                      client_secret=${clientSecret}
    ...                                                      grant_type=password
    ...                                                      scope=user.read mail.read mail.send
    ...                                                      userName=${SENDER_EMAIL_ADDRESS}
    ...                                                      password=${senderPassword}

    Send Email From One User To Another     ${BASE_URL}      ${TOKEN_API}    ${GRAPH_BASE_URL}    ${SEND_MAIL_API}     ${fileContents}    ${params}


TC:2 Verify From Recipient Mailbox That Email Subject And Body Matches
    ${clientSecret}=                   Decode Encrypted Text    ${CLIENT_SECRET}
    ${receiverPassword}=               Decode Encrypted Text     ${RECEIVER_PASSWORD}

    ${paramsTokenAPI}                  Create Dictionary      client_id=${CLIENT_ID}
    ...                                                       client_secret=${clientSecret}
    ...                                                       grant_type=password
    ...                                                       scope=user.read mail.read mail.send
    ...                                                       userName=${RECEIVER_EMAIL_ADDRESS}
    ...                                                       password=${receiverPassword}

    ${paramsReadMailAPI}=              Create Dictionary      $filter=from/emailAddress/address eq '${SENDER_EMAIL_ADDRESS}' and isRead eq false
    ...                                                       $count=true

    ${access_token}=                   Get Access Token       ${BASE_URL}    ${TOKEN_API}    ${paramsTokenAPI}
    ${responseReadMailAPI}             Read Email From MailBox     ${GRAPH_BASE_URL}    ${READ_MAIL_API}     ${paramsReadMailAPI}     ${access_token}
    Verify Email Body And Subject Are Same As Sent Message         ${responseReadMailAPI.value}    ${MESSAGE_WITHOUT_ATTACHMENT}

TC:3 Send Email From One User To Another With File Attachments
    ${senderPassword}=                 Decode Encrypted Text    ${SENDER_PASSWORD}
    ${clientSecret}=                   Decode Encrypted Text    ${CLIENT_SECRET}

    ${MESSAGE_WITH_ATTACHMENT.message.attachments}=    Update Attachment Variable in Test Data Dictionary    ${MESSAGE_WITH_ATTACHMENT.message.attachments}
    ${MESSAGE_WITH_ATTACHMENT.message.toRecipients[0].emailAddress.address}=    Update Variable in Test Data Dictionary    ${MESSAGE_WITH_ATTACHMENT.message.toRecipients[0].emailAddress.address}    ${RECEIVER_EMAIL_ADDRESS}

    ${fileContents}=                   Convert Robot Dictionary To Json            ${MESSAGE_WITH_ATTACHMENT}

    ${params}                          Create Dictionary      client_id=${CLIENT_ID}
    ...                                                       client_secret=${clientSecret}
    ...                                                       grant_type=password
    ...                                                       scope=user.read mail.read mail.send
    ...                                                       userName=${SENDER_EMAIL_ADDRESS}
    ...                                                       password=${senderPassword}

    Send Email From One User To Another     ${BASE_URL}       ${TOKEN_API}    ${GRAPH_BASE_URL}    ${SEND_MAIL_API}     ${fileContents}    ${params}


TC:4 Verify From Recipient Mailbox That Email Body And Attachment Matches
    ${clientSecret}=                   Decode Encrypted Text    ${CLIENT_SECRET}
    ${receiverPassword}=               Decode Encrypted Text    ${RECEIVER_PASSWORD}
    ${paramsTokenAPI}                  Create Dictionary      client_id=${CLIENT_ID}
    ...                                                       client_secret=${clientSecret}
    ...                                                       grant_type=password
    ...                                                       scope=user.read mail.read mail.send
    ...                                                       userName=${RECEIVER_EMAIL_ADDRESS}
    ...                                                       password=${receiverPassword}

    ${paramsReadMailAPI}=              Create Dictionary      $filter=from/emailAddress/address eq '${SENDER_EMAIL_ADDRESS}' and isRead eq false
    ...                                                       $count=true

    ${access_token}=                   Get Access Token       ${BASE_URL}    ${TOKEN_API}    ${paramsTokenAPI}
    ${responseReadMailAPI}             Read Email From MailBox      ${GRAPH_BASE_URL}    ${READ_MAIL_API}     ${paramsReadMailAPI}     ${access_token}
    Verify Email Body And Attachment Are Same As Sent Message       ${responseReadMailAPI.value}    ${MESSAGE_WITH_ATTACHMENT}      ${access_token}


