# coding: utf-8

require 'em-ftpd'
require 'vcr'


# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[File.dirname(__FILE__) + "/support/**/*.rb"].each {|f| require f }

require 's3ftpdriver'
