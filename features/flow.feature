Feature: Flow

Scenario: Login, create a directory, move to it, create a file inside it and download the file
Given a client
  And tries to login with a correct authentication
When creates a folder called cucumber_test_folder
  And moves to that folder cucumber_test_folder
  And uploads a file called test_file.txt
  And download a file with the name test_file.txt as downloaded_file.txt
Then the downloaded file should be the same as the original
