require File.expand_path('../test_helper', File.dirname(__FILE__))

class ChurnOptionsTest < Test::Unit::TestCase
 
  should "store get default directory" do
    assert_equal Churn::ChurnOptions::DEFAULT_CHURN_DIRECTORY, Churn::ChurnOptions.instance.data_directory
  end

  should "store get over ride directory" do
    options = Churn::ChurnOptions.instance
    tmp_dir = '/tmp/fake'
    options.set_options({:data_directory => tmp_dir})
    assert_equal tmp_dir, Churn::ChurnOptions.instance.data_directory
  end
  
end
