*** Settings ***
Library    Collections
Library    RequestsLibrary
Test Setup    Connect To API
*** Variables ***
${SESSION}=    localhost
${BASE_URL}=    http://localhost:5000/api
*** Test Cases ***

Todo API should return all todo items
    ${length}=    Get Number Of Todos
    Should Not Be Equal As Integers    ${length}    0

Todo API should add new item when sending post request
    ${todo_item_name}=    Set Variable    Tesmos demo
    ${resp}=    Create New Todo Item    ${todo_item_name}
    ${observed}=    Get Todo Attribute From Json    ${resp}    name
    Should Be Equal As Strings    ${observed}    ${todo_item_name}
    [Teardown]    Delete Last Created Item

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

Todo API should update when sending put request
    ${todo_item_name}=    Set Variable    Update me
    ${item}=    Create New Todo Item    ${todo_item_name}
    ${item_id}=    Get Todo Attribute From Json    ${item}    key
    ${observed_name}=    Get Todo Attribute From Json    ${item}    name
    ${observed_is_complete}=    Get Todo Attribute From Json    ${item}    isComplete
    Should Be Equal As Strings    ${observed_name}    ${todo_item_name}
    Should Not Be True    ${observed_is_complete}
    ${resp}=    Update Todo Item    Updated    ${item_id}    true
    ${updated_name}=    Get Todo Attribute From Json    ${resp}    name
    ${updated_is_complete}=    Get Todo Attribute From Json    ${resp}    isComplete
    Should Be Equal As Strings    ${updated_name}    Updated
    Should Be True    ${updated_is_complete}
    [Teardown]    Delete Last Created Item

Todo API should return correct item when using key
    ${todo_item_name}=    Set Variable    Find me
    ${item}=    Create New Todo Item    ${todo_item_name}
    ${item_id}=    Get Todo Attribute From Json    ${item}    key
    ${find_item}=    Get Todo Item    ${item_id}
    Dictionaries Should Be Equal    ${item}    ${find_item}
    [Teardown]    Delete Last Created Item


*** Keywords ***
Connect To API
    Create Session    ${SESSION}    ${BASE_URL}

Get All Todo Items As JSON
    ${resp}=    Get Request    ${SESSION}    /todo
    Should Be Equal As Strings    ${resp.status_code}    200
    [Return]    ${resp.json()}

Create Json Headers
    &{headers}=  Create Dictionary  Content-Type=application/json
    [Return]    ${headers}

Create New Todo Item
    [Arguments]    ${name}    ${is_complete}=false
    &{headers}=  Create Json Headers
    &{data}=    Create Dictionary    name=${name}    isComplete=${is_complete}
    ${resp}=    Post Request    ${SESSION}    /todo    headers=${headers}    data=${data}
    Set Test Variable    ${LAST_CREATED}    ${resp.json()}
    Should Be Equal As Strings    ${resp.status_code}    201
    [Return]    ${resp.json()}

Get Todo Item
    [Arguments]    ${item_id}
    ${resp}=    Get Request    ${SESSION}    /todo/${item_id}
    Should Be Equal As Strings    ${resp.status_code}    200
    [Return]    ${resp.json()}


Update Todo Item
    [Arguments]    ${name}    ${item_id}    ${is_complete}=false
    &{data}=    Create Dictionary    name=${name}    isComplete=${is_complete}    key=${item_id}
    ${headers}=    Create Json Headers
    ${resp}=    Put Request    ${SESSION}    /todo/${item_id}    headers=${headers}    data=${data}
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

Delete Last Created Item
    ${delete_id}=    Get Todo Attribute From Json    ${LAST_CREATED}    key
    Delete Todo Item    ${delete_id}


