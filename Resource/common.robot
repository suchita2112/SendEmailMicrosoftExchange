*** Settings ***
Documentation                          ****
Library                                String
Library                                RequestsLibrary
Library                                Collections

*** Keywords ***

Get API Request
    [Arguments]                        ${url}   ${session_url}  ${header}=${EMPTY}  ${params}=${EMPTY}
    Create Session                     APISession      url=${url}    headers=${header}
    ${response}=                       Get Request   APISession      ${session_url}      params=${params}
    ${robotDictionary}=                Run Keyword If      '${response.status_code}' == '200'
    ...                                Convert Json To Robot Dictionary         ${response.content}
    ...  ELSE                          Fail    Error In ${session_url} API  Request
    [Return]    ${robotDictionary}

Post API Request
    [Arguments]                        ${url}   ${session_url}  ${updatedata}   ${header}=${EMPTY}
    Create Session                     APISession         url=${url}     headers=${header}
    ${response}=                       Post Request  APISession   ${session_url}     data=${updatedata}
    ${robotDictionary}=                Run Keyword If    '${response.status_code}' in ['200', '202'] and '${response.content}' != '${EMPTY}'
    ...                                Convert Json To Robot Dictionary         ${response.content}
    ...  ELSE IF                       '${response.status_code}' in ['200', '202'] and '${response.content}' == '${EMPTY}'
    ...                                Set Variable    ${response.content}
    ...  ELSE                          Fail    Error In ${session_url} API  Request
    [Return]    ${robotDictionary}

Convert Json To Robot Dictionary
    [Arguments]                        ${json}
    [Documentation]                    Converts Python dictionary to Robot dictionary.
    ${python_dict} =                   Evaluate    json.loads(r'''${json}''')  json
    @{keys} =                          Get Dictionary Keys  ${python_dict}
    ${robot_dict} =                    Create Dictionary
    FOR  ${key}  IN  @{keys}
         Set To Dictionary             ${robot_dict}   ${key}=${python_dict}[${key}]
    END
    [Return]    ${robot_dict}

Get Access Token
    [Arguments]                        ${url}   ${tokenAPI}  ${params}
    ${header}=                         Create Dictionary   Content-Type=application/x-www-form-urlencoded
    ${responseTokenAPI}=               Post API Request    ${url}   ${tokenAPI}    ${params}   ${header}
    [Return]                           ${responseTokenAPI}[access_token]

Compare Email Attachment Values
    [Arguments]                        ${attachment}   ${sentAttachment}
    Should Be Equal                    ${sentAttachment}[name]                      ${attachment}[name]           Saved value are not equal.
    Should Be Equal                    ${sentAttachment}[contentType]               ${attachment}[contentType]    Saved value are not equal.
    Should Be Equal                    ${sentAttachment}[contentBytes]              ${attachment}[contentBytes]   Saved value are not equal.


Compare Mail Body And Subject Values
    [Arguments]                        ${sentMessage}    ${mail}
    Should Be Equal                    ${sentMessage}[message][subject]             ${mail}[subject]              Saved value are not equal.
    Should Be Equal                    ${sentMessage}[message][body][contentType]   ${mail}[body][contentType]    Saved value are not equal.
    Should Contain                     ${mail}[body][content]                       ${sentMessage}[message][body][content]       Saved value are not equal.
