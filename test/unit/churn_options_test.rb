require File.expand_path('../test_helper', File.dirname(__FILE__))

class ChurnOptionsTest < Minitest::Test

  should "store get default directory" do
    assert_equal Churn::ChurnOptions::DEFAULT_CHURN_DIRECTORY, Churn::ChurnOptions.new.data_directory
  end

  should "store get over ride directory" do
    options = Churn::ChurnOptions.new
    tmp_dir = '/tmp/fake'
    options.set_options({:data_directory => tmp_dir})
    assert_equal tmp_dir, options.data_directory
  end

  should "set the checked file extension" do
    options = Churn::ChurnOptions.new
    options.set_options({:file_extension => 'rb'})
    assert_equal 'rb', options.file_extension
  end

end
