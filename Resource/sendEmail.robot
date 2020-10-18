*** Settings ***
Documentation                          ****
Library                                String
Library                                RequestsLibrary
Library                                Collections
Resource                               common.robot



*** Keywords ***

Send Email From One User To Another
    [Arguments]                        ${url}   ${tokenAPI}    ${graphURL}    ${sendMailAPI}    ${fileContents}    ${params}

    ${access_token}=                   Get Access Token    ${url}    ${tokenAPI}    ${params}
    ${header}=                         Create Dictionary   Content-Type=application/json      Authorization=${access_token}
    ${responseSendMailAPI}=            Post API Request    ${graphURL}   ${sendMailAPI}    ${fileContents}   ${header}

Read Email From MailBox
    [Arguments]                        ${graphURL}    ${readMailAPI}     ${paramsReadMailAPI}     ${access_token}
    ${header}=                         Create Dictionary   Content-Type=application/json      Authorization=${access_token}
    ${responseReadMailAPI}=            Get API Request    ${graphURL}    ${readMailAPI}       ${header}     ${paramsReadMailAPI}
    [Return]    ${responseReadMailAPI}

Verify Email Body And Subject Are Same As Sent Message
    [Arguments]                        ${mails}    ${sentMessage}

    FOR  ${mail}   IN   @{mails}
        ${found}=                      Run Keyword And Return Status    Compare Mail Body And Subject Values       ${sentMessage}     ${mail}
        EXIT FOR LOOP IF               ${found}
    END
    Run Keyword If                     '${found}' == '${FALSE}'     Fail    Email not found

Verify Email Body And Attachment Are Same As Sent Message
    [Arguments]                        ${mails}    ${sentMessage}    ${access_token}

    FOR  ${mail}   IN   @{mails}
        ${found}=                      Run Keyword And Return Status    Compare Mail Body And Subject Values       ${sentMessage}     ${mail}
        Continue For Loop If           '${found}' =='${FALSE}'
        ${found}=                      Run Keyword If    '${mail}[hasAttachments]' == '${True}'
        ...                            Get Attachments From Mail        ${mail}[id]       ${sentMessage}     ${access_token}
        ...                            ELSE   Set Variable  ${False}
        EXIT FOR LOOP IF               ${found}
    END
    Run Keyword If                     '${found}' == '${FALSE}'     Fail    Email not found

Get Attachments From Mail
    [Arguments]                        ${mailid}    ${sentMessage}    ${access_token}

    ${header}=                         Create Dictionary   Content-Type=application/json      Authorization=${access_token}
    ${params}=                         Create Dictionary   $count=true
    ${getAttachmentAPI}=               Get API Request     ${GRAPH_BASE_URL}   v1.0/me/messages/${mailid}/attachments    ${header}     ${params}
    ${attachments_count}=              Get length          ${sentMessage}[message][attachments]
    ${found} =                         Run Keyword And Return If    '${getAttachmentAPI}[@odata.count]' != '${attachments_count}'
    ...                                Set Variable        ${FALSE}

    FOR  ${attachment}  IN  @{getAttachmentAPI.value}
        ${found}=                      Verify Attachment With Sent Attachments     ${attachment}      ${sentMessage}[message][attachments]
        EXIT FOR LOOP IF               '${found}' =='${FALSE}'
    END
    [Return]    ${found}

Verify Attachment With Sent Attachments
    [Arguments]                        ${attachment}       ${sentAttachments}

    FOR  ${sentAttachment}  IN  @{sentAttachments}
        ${found}                       Run Keyword And Return Status
        ...                            Compare Email Attachment Values     ${attachment}   ${sentAttachment}
        EXIT FOR LOOP IF               ${found}
    END
    [Return]    ${found}

Update Variable in Test Data Dictionary
    [Arguments]                        ${variableName}       ${value}
    Set Suite Variable                 ${variableName}       ${value}
    ${variableName}                    Replace Variables     ${variableName}
    [Return]    ${variableName}

Update Attachment Variable in Test Data Dictionary
    [Arguments]                        ${attachments}
    Set Suite Variable                       ${TestSuiteLocation}  ${CURDIR}

    FOR  ${attachment}   IN    @{attachments}
        ${attachment.contentLocation}                         Replace Variables   ${attachment.contentLocation}
        ${content}=                                           Read File Data      ${attachment.contentLocation}
        ${attachment.contentBytes}                            Replace Variables   ${attachment.contentBytes}
    END
    [Return]    ${attachments}

Decode Encrypted Text
    [Arguments]                        ${encryptedText}
    ${Secret}=                         Get Decrypted Text    ${encryptedText}
    [Return]    ${Secret}

Convert Robot Dictionary To Json
    [Arguments]                        ${dict}
    ${Contents}=                       evaluate              json.dumps(${dict})       json
    [Return]    ${Contents}
