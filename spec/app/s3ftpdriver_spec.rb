require 'spec_helper'

describe 'S3FTPDriver' do

  def contains_directory(collection, path)
    collection.each do |directory|
      return true if directory.name.eql?(path) && directory.directory
    end
    return false
  end

  def contains_file(collection, path)
    collection.each do |file|
      return true if file.name.eql?(path) && !file.directory
    end
    return false
  end

  let(:s3) { S3FTPDriver.new }
  let(:test_dir) { '/test_dir/' }
  let(:root_level_file_path) { '/test_file.txt' }
  let(:root_level_renamed_file_path) { '/test_file_moved.txt' }
  let(:test_file_data) { "This is a test file\n" }

  describe 'create a file at root level' do
    before do
      VCR.use_cassette "delete test file at root level" do
        s3.simple_delete_file(root_level_file_path)
      end
    end
    
    it "should have the correct sent size and data" do
      VCR.use_cassette "upload test file at root level" do
        s3.simple_put_file_streamed(root_level_file_path, test_file_data).should == test_file_data.size
      end
    end
    
    describe "the file is at server" do
      before do
        VCR.use_cassette "upload test file at root level" do
          s3.simple_put_file_streamed(root_level_file_path, test_file_data)
        end
      end
      
      it "should have the correct data" do
        VCR.use_cassette 'get test file at root level' do
          s3.simple_get_file(root_level_file_path).eql?(test_file_data).should be_true
        end
      end
    
      describe "rename the root file" do
        before do
          VCR.use_cassette 'rename test file at root level' do
          s3.simple_rename(root_level_file_path, root_level_renamed_file_path) 
          end
        end

        it 'should exists' do
          VCR.use_cassette 'check if renamed test file at root level exists'  do
            response = s3.simple_dir_contents
            contains_file(response, root_level_renamed_file_path).should be_true
          end
        end

        it 'should have the correct data' do
          VCR.use_cassette 'get renamed test file at root level' do
            s3.simple_get_file(root_level_renamed_file_path).eql?(test_file_data).should be_true
          end
        end
      end
    end
  end


  describe 'create a test directory at root level' do
    before do
      VCR.use_cassette 'delete and create a test dir' do
        s3.simple_delete_dir(test_dir)
        s3.simple_make_dir(test_dir)
      end
    end   
     
    it "should exist" do
      VCR.use_cassette 'check if the test dir exists' do
        response = s3.simple_dir_contents
        contains_directory(response, test_dir).should be_true 
      end
    end

    it "should have zero size" do
      VCR.use_cassette "get the test dir" do
        response = s3.simple_bytes(test_dir)
        response.should == 0
      end
    end
  
    describe 'create a file inside the test directory' do
      before do
        VCR.use_cassette "create file inside test dir" do
          s3.simple_put_file_streamed(test_dir[0..-1] + root_level_file_path, test_file_data) 
        end
      end
      it "should have the file with the correct data" do
        VCR.use_cassette "get the test file inside the test dir" do
          s3.simple_get_file(test_dir[0..-1] + root_level_file_path).eql?(test_file_data).should be_true
        end
      end
    end

    describe 'move to test dir' do
      it "should move" do
        VCR.use_cassette "move to test dir" do 
          response = s3.simple_change_dir(test_dir)
          response.should be_true
        end
      end
    end
  end

end
