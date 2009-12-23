require File.expand_path('../test_helper', File.dirname(__FILE__))

class ChurnCalculatorTest < Test::Unit::TestCase
 
  should "uses minimum churn count" do
    within_construct do |container|
      Churn::ChurnCalculator.stubs(:git?).returns(true)
      churn = Churn::ChurnCalculator.new({:minimum_churn_count => 3})
 
      churn.stubs(:parse_log_for_changes).returns([['file.rb', 4],['less.rb',1]])
      churn.stubs(:parse_log_for_revision_changes).returns(['revision'])
      churn.stubs(:analyze)
      report = churn.report
      assert_equal 1, report[:churn][:changes].length
      assert_equal ["file.rb", 4], report[:churn][:changes].first
    end
  end

  should "analize sorts changes" do
    within_construct do |container|
      Churn::ChurnCalculator.stubs(:git?).returns(true)
      churn = Churn::ChurnCalculator.new({:minimum_churn_count => 3})
 
      churn.stubs(:parse_log_for_changes).returns([['file.rb', 4],['most.rb', 9],['less.rb',1]])
      churn.stubs(:parse_log_for_revision_changes).returns(['revision'])
      #churn.stubs(:analyze)
      report = churn.report
      assert_equal 2, report[:churn][:changes].length
      top = {:file_path => "most.rb", :times_changed => 9}
      assert_equal top, report[:churn][:changes].first
      bottom = {:file_path => "file.rb", :times_changed => 4}
      assert_equal bottom, report[:churn][:changes].last
    end
  end
  
end
