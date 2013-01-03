#coding: utf-8
require 'csv'
require 'aws-sdk'
require 'em-ftpd'

class S3FTPDriver
  ACCESS_KEY_ID = "AKIAJHFPPNK6KAKV63RQ"
  SECRET_ACCESS_KEY = "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"
  BUCKET_NAME = 'werquinigo-test'
	
  USER_PASS_FILE = File.expand_path(File.dirname(__FILE__) + '/config.csv')
  # Minimum packet size defined by Amazon.
  DATA_TRANSFER_PACKET_SIZE = 5 * 1024 * 1024
	
  :root_path_level
  :any_dir_level	

  def initialize()
    @s3 = AWS::S3.new(:access_key_id => ACCESS_KEY_ID,
                      :secret_access_key => SECRET_ACCESS_KEY)

    @bucket = @s3.buckets[BUCKET_NAME]
    @users = {}
    CSV.parse(File.open(USER_PASS_FILE)).map { |user, pass| @users[user] = pass }
  end

  def change_dir(path, &block)
    yield (path == '/' or @bucket.objects[without_root_slash(path)].exists?)
  end
	
  def dir_contents(path, &block)
    path = without_root_slash(path)
    contents = []
    @bucket.objects.with_prefix(path).each do |obj|
      path_suffix = obj.key[path.size..-1]
      if is_dir?(path_suffix, :root_path_level)
        contents.push dir_item(obj.key)
      elsif is_file?(path_suffix, :root_path_level)
        contents.push file_item(obj.key, obj.content_length)
      end
    end
    yield contents
  end

  def authenticate(user, pass, &block)
    yield @users[user] == pass
  end

  def bytes(path, &block)
    path = without_root_slash(path)
    if @bucket.objects[path].exists?
      yield @bucket.objects[path].content_length
    else
      yield false
    end
  end

  def get_file(path, &block)
    path = without_root_slash(path)
    if @bucket.objects[path].exists?
      yield @bucket.objects[path].read
    else
      yield false
    end
  end

  def put_file_streamed(path, datasocket, &block)
    object = @bucket.objects[without_root_slash(path)]
    part1 = ''
    part2 = ''
    single_part = true
    multipart_upload = object.multipart_upload
    # Stream the parts. It must be ensured that in multipart upload each part
    # has at least 5 MB.
    datasocket.on_stream do |packet|
      if part1.size >= DATA_TRANSFER_PACKET_SIZE
        part2 << packet
      else
    	part1 << packet
      end

      if part2.size >= DATA_TRANSFER_PACKET_SIZE
        single_part = false
    	multipart_upload.add_part(part1)
    	part1 = part2
    	part2 = ''
      end
    end
    datasocket.callback do
      part1 << part2 # The possible last and incomplete part.
      if single_part
        object.write(part1)
        upload_size = part1.size
      else
        multipart_upload.add_part(part1) 
   	upload_size = multipart_upload.parts.inject(0) { |sum, part| sum + part.size }
   	multipart_upload.complete(:remote_parts)
      end
      yield upload_size
    end

    datasocket.errback { yield false }
 end

  def delete_file(path, &block)
    path = without_root_slash(path)
  yield @bucket.objects[path].exists? &&
    @bucket.objects[path].delete.nil?
  end

  def delete_dir(path, &block)
    path = without_root_slash(path)
    @bucket.objects.with_prefix(path).delete_all
    yield !@bucket.objects[path].exists?
  end

  def rename(from, to, &block)
    path = without_root_slash(from)
    new_path = without_root_slash(to)
    result = true
    @bucket.objects.with_prefix(path).each do |obj|
      new_name = new_path + obj.key[path.size..-1]
      result &&= obj.rename_to(new_name)
    end
    yield result
  end

  def make_dir(path, &block)
    path = without_root_slash(path)
    path = path + '/' if path[-1] != '/'
    yield @bucket.objects.create(path, '')
  end

  private

  # Return the given dir without the leading '/' if it actually has it.
  #
  def without_root_slash(dir)
    dir.slice!(0) if dir[0] == '/'
    dir
  end

  # Determine if the given path represents a directory. Also, it checks if
  # the directory is at root level or not.
  # 	
  def is_dir?(dir, level)
    path = without_root_slash(dir)
    dir[-1] == '/' && (level == :root_path_level && dir.count('/') == 1 ||
        level == :any_dir_level)
  end

  # Determine if the given path represnts a file. Also, it checks if the file
  # is at root level or not.
  # 
  def is_file?(file, level)
    !is_dir?(file, level) && !dir.empty? && (level == :root_path_level &&
        without_root_slash(file).count('/') == 0 || level == :any_dir_level)
  end

  # Create a DirectoryItem representing a directory.
  #
  def dir_item(name)
    EM::FTPD::DirectoryItem.new(:name => name,
                                :directory => true,
                                :size => 0)
  end

  # Create a DirectoryItem representing a file.
  #
  def file_item(name, bytes)
    EM::FTPD::DirectoryItem.new(:name => name,
                                :directory => false,
                                :size => bytes)
  end

end
