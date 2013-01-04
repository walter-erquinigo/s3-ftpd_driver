# coding: utf-8

require 'em-ftpd'
require 'vcr'


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

require File.dirname(__FILE__) + "/../app/s3ftpdriver.rb"
#RSpec.configure do |config|
#  config.include ReaderSpecHelper
#end
