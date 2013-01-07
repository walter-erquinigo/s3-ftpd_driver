require 'net/ftp'
require 'em-ftpd'

Before do
  Thread.new do
    # @server is a Singleton so this is safe
    @server = EM::FTPD::App.start(File.expand_path("./lib/test_config.rb")) 
  end
end

After do
  @ftp.close
end

Given /a client/ do 
  sleep(2) # A suitable time to wait for the server to load
  @ftp = Net::FTP.new('localhost')
end

When /tries to login with an incorrect authentication/ do
  @message = "correct login"
  begin
    @ftp.login('test', '12347')
  rescue
    @message = "incorrect login"
  end
  
end

When /tries to login with a correct authentication/ do
  @message = "correct login"
  begin
    @ftp.login('test', '1234')
    @ftp.passive
  rescue
    @message = "incorrect login"
  end
  
end

Then /the client should prompt an incorrect authentication message/ do
  @message['incorrect login'].should  be_true 
end

Then /the client should prompt a correct authentication message/ do
  @message['correct login'].should  be_true 
end

