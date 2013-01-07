# Amazon S3 - em-ftpd driver

This is a driver for using Amazon S3 to store files via FTP (em-ftpd).

To use it, call (you may have to use it as sudo):
em-ftpd /lib/config.rb

You have also to specify an user-pass file in config.rb (see the file
itself). This user-pass file is a csv file similar to the lib/auth.csv file.

Also, you have to define your own S3 bucket, authorization keys and subfolder.
In order to accomplish this, you just modify the corresponding lines in the driver itself.

* To run Rspec tests: rspec spec/
* To run Cucumber tests (you may have to do it as sudo): cucumber features/


