#coding: utf-8

# Monkey path some methods for testing S3FTPDriver.
class S3FTPDriver 
  def simple_make_dir(path)
    make_dir(path) { |success| return success }
  end
  
  def simple_change_dir(path)
    change_dir(path) { |success| return success }
  end
  
  def simple_dir_contents(path = '/')
    dir_contents(path){ |contents| return contents }
  end

  def simple_delete_dir(path)
    delete_dir(path) { |success| return success }
  end

  def simple_delete_file(path)
    delete_file(path) { |success| return success }
  end

  def simple_bytes(path)
    bytes(path) { |success| return success }
  end

  def simple_get_file(path)
    get_file(path) { |data| return data }
  end

  class SimpleDataSocket 
    def initialize(data)
      @data = data;
    end
    def on_stream(&block)
      yield @data
    end
    def callback(&block)
      yield
    end
    def errback(&block)
      yield
    end
  end

  def simple_put_file_streamed(path, data)
    datasocket = SimpleDataSocket.new(data)
    put_file_streamed(path, datasocket) { |size| return size }
  end

  def simple_rename(path, new_path)
    rename(path, new_path) {}#{ |success| return success }
  end
end
