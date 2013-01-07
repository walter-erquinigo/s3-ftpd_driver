Feature: Login

Scenario: Unsuccessful login
Given a client 
When tries to login with an incorrect authentication
Then the client should prompt an incorrect authentication message

Scenario: Successful login
Given a client 
When tries to login with a correct authentication
Then the client should prompt a correct authentication message

