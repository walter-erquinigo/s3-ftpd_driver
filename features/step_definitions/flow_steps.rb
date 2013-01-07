require 'net/ftp'
require 'em-ftpd'

def contains_path(directory_list, name)
  directory_list.each do |item|
    return true if item[name]
  end
  return false
end

def to_folder!(path) 
  path << '/' unless path[-1] == '/'
end

When /creates a folder called (\w+)/ do |folder_name|
  to_folder!(folder_name)
  @ftp.mkdir(folder_name) 
  contains_path(@ftp.list(), folder_name).should be_true
end

When /moves to that folder (\w+)/ do |folder_name|
  @ftp.chdir(folder_name)
  @ftp.pwd.should == folder_name
end

When /uploads a file called ([\w\.]+)/ do |file_name|
  file = File.new('./features/' + file_name)
  @ftp.puttextfile(file, '/' + @ftp.pwd + '/' + File.basename(file))
  contains_path(@ftp.list(), file_name).should be_true
end

When /download a file with the name ([\w\.]+) as ([\w\.]+)/ do |file_name_server, file_name_client|
  @ftp.get('/' + @ftp.pwd + '/' + file_name_server, './features/' + file_name_client)
  stream_original = StringIO.new(File.new('./features/' + file_name_server).read)
  stream_new = StringIO.new(File.new('./features/' + file_name_client).read)
  @line_original = stream_original.gets.chop
  @line_new = stream_new.gets.chop
  File.delete('./features/' + file_name_client)
end

Then /the downloaded file should be the same as the original/ do
  @line_original.should == @line_new
end

