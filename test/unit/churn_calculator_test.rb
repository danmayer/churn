require File.expand_path('../test_helper', File.dirname(__FILE__))

class ChurnCalculatorTest < Test::Unit::TestCase
 
  should "use minimum churn count" do
    within_construct do |container|
      Churn::ChurnCalculator.stubs(:git?).returns(true)
      churn = Churn::ChurnCalculator.new({:minimum_churn_count => 3})
 
      churn.stubs(:parse_log_for_changes).returns([['file.rb', 4],['less.rb',1]])
      churn.stubs(:parse_log_for_revision_changes).returns(['revision'])
      churn.stubs(:analyze)
      report = churn.report(false)
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
      report = churn.report(false)
      assert_equal 2, report[:churn][:changes].length
      top = {:file_path => "most.rb", :times_changed => 9}
      assert_equal top, report[:churn][:changes].first
      bottom = {:file_path => "file.rb", :times_changed => 4}
      assert_equal bottom, report[:churn][:changes].last
    end
  end

  should "have correct changed_files data" do
    within_construct do |container|
      Churn::ChurnCalculator.stubs(:git?).returns(true)
      churn = Churn::ChurnCalculator.new({:minimum_churn_count => 3})
      
      churn.stubs(:parse_log_for_changes).returns([['less.rb',1]])
      churn.stubs(:parse_log_for_revision_changes).returns(['first'])
      churn.stubs(:parse_logs_for_updated_files).returns({'fake_file.rb'=>[]})
      report = churn.report(false)
      assert_equal ["fake_file.rb"], report[:churn][:changed_files]
    end
  end

  should "have correct changed classes and methods data" do
    within_construct do |container|
      Churn::ChurnCalculator.stubs(:git?).returns(true)
      churn = Churn::ChurnCalculator.new({:minimum_churn_count => 3})
      
      churn.stubs(:parse_log_for_changes).returns([['less.rb',1]])
      churn.stubs(:parse_log_for_revision_changes).returns(['first'])
      churn.stubs(:parse_logs_for_updated_files).returns({'fake_file.rb'=>[]})
      klasses = [{"klass"=>"LocationMapping", "file"=>"lib/churn/location_mapping.rb"}]
      methods = [{"klass"=>"LocationMapping", "method"=>"LocationMapping#process_class", "file"=>"lib/churn/location_mapping.rb"}]
      churn.stubs(:get_changes).returns([klasses,methods])
      report = churn.report(false)
      assert_equal [{"klass"=>"LocationMapping", "method"=>"LocationMapping#process_class", "file"=>"lib/churn/location_mapping.rb"}], report[:churn][:changed_methods]
      assert_equal [{"klass"=>"LocationMapping", "file"=>"lib/churn/location_mapping.rb"}], report[:churn][:changed_classes]
    end
  end

  should "have correct churn method and classes at 1 change" do
    within_construct do |container|
      Churn::ChurnCalculator.stubs(:git?).returns(true)
      churn = Churn::ChurnCalculator.new({:minimum_churn_count => 3})
      
      churn.stubs(:parse_log_for_changes).returns([['less.rb',1]])
      churn.stubs(:parse_log_for_revision_changes).returns(['first'])
      churn.stubs(:parse_logs_for_updated_files).returns({'fake_file.rb'=>[]})
      klasses = [{"klass"=>"LocationMapping", "file"=>"lib/churn/location_mapping.rb"}]
      methods = [{"klass"=>"LocationMapping", "method"=>"LocationMapping#process_class", "file"=>"lib/churn/location_mapping.rb"}]
      churn.stubs(:get_changes).returns([klasses,methods])
      report = churn.report(false)
      assert_equal [{"method"=>{"klass"=>"LocationMapping", "method"=>"LocationMapping#process_class", "file"=>"lib/churn/location_mapping.rb"}, "times_changed"=>1}], report[:churn][:method_churn]
      assert_equal [{"klass"=>{"klass"=>"LocationMapping", "file"=>"lib/churn/location_mapping.rb"}, "times_changed"=>1}], report[:churn][:class_churn]
    end
  end

  should "initialize a churn calculator for hg repositories" do
    Churn::ChurnCalculator.stubs(:git?).returns(false)
    Churn::ChurnCalculator.stubs(:system).with('hg branch').returns(true)
    churn = Churn::ChurnCalculator.new({:minimum_churn_count => 3})
    assert churn.instance_variable_get(:@source_control).is_a?(Churn::HgAnalyzer)
  end

  
end
