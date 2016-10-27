*** Settings ***
Library    Collections
Library    RequestsLibrary
Test Setup    Connect To API
*** Variables ***
${SESSION}=    localhost
${BASE_URL}=    http://localhost:5000/api
*** Test Cases ***

Todo API should return all todo items
    ${resp}=    Get All Todo Items As Json
    ${length}=    Get Length    ${resp}
    Should Not Be Equal As Integers    ${length}    0

Todo API should add new item when sending post request
    ${todo_item_name}=    Set Variable    Tesmos demo
    ${resp}=    Create New Todo Item    ${todo_item_name}
    ${observed}=    Get Todo Attribute From Json    ${resp}    name
    Should Be Equal As Strings    ${observed}    ${todo_item_name}

Todo API should remove item when sending delete request
    ${todo_item_name}=    Set Variable    Delete me
    ${before_adding}=    Get Number Of Todos
    ${item}=    Create New Todo Item    ${todo_item_name}
    ${delete_id}=    Get Todo Attribute From Json    ${item}    key
    ${observed_length}=    Get Number Of Todos
    Should Be Equal As Integers    ${observed_length}    ${before_adding+1}
    ${resp}=    Delete Todo Item    ${delete_id}
    ${observed_length}=    Get Number Of Todos
    Should Be Equal As Integers    ${observed_length}    ${before_adding}





*** Keywords ***
Connect To API
    Create Session    ${SESSION}    ${BASE_URL}

Get All Todo Items As JSON
    ${resp}=    Get Request    ${SESSION}    /todo
    Should Be Equal As Strings    ${resp.status_code}    200
    [Return]    ${resp.json()}

Create Post Headers
    &{headers}=  Create Dictionary  Content-Type=application/json
    [Return]    ${headers}

Create New Todo Item
    [Arguments]    ${name}    ${is_complete}=false
    &{headers}=  Create Post Headers
    &{data}=    Create Dictionary    name=${name}    isComplete=${is_complete}
    ${resp}=    Post Request    ${SESSION}    /todo    headers=${headers}    data=${data}
    Should Be Equal As Strings    ${resp.status_code}    201
    [Return]    ${resp.json()}

Get Todo Attribute From Json
    [Arguments]    ${json}   ${attr}
    ${value}=    Get From Dictionary    ${json}    ${attr}
    [Return]    ${value}

Delete Todo Item
    [Arguments]    ${delete_id}
    ${resp}=    Delete Request    ${SESSION}    /todo/${delete_id}
    Should Be Equal As Strings    ${resp.status_code}    204

Get Number Of Todos
    ${current_todos}=   Get All Todo Items As Json
    ${number_of_todos}=    Get Length    ${current_todos}
    [Return]    ${number_of_todos}
