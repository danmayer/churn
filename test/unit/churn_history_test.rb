require File.expand_path('../test_helper', File.dirname(__FILE__))

class ChurnHistoryTest < Test::Unit::TestCase
 
  should "store results" do
    within_construct do |container|
      Churn::ChurnHistory.store_revision_history('aaa','data')
      assert File.exists?('tmp/churn/aaa.json')
      data = File.read('tmp/churn/aaa.json')
      assert data.match(/data/)
    end
  end
 
  should "restores results" do
    within_construct do |container|
      container.file('tmp/churn/aaa.json', '{"churn":{"changes":[{"file_path":".gitignore","times_changed":2},{"file_path":"lib\/churn.rb","times_changed":2},{"file_path":"Rakefile","times_changed":2},{"file_path":"README.rdoc","times_changed":2},{"file_path":"lib\/churn\/source_control.rb","times_changed":1},{"file_path":"lib\/churn\/svn_analyzer.rb","times_changed":1},{"file_path":"lib\/tasks\/churn_tasks.rb","times_changed":1},{"file_path":"LICENSE","times_changed":1},{"file_path":"test\/churn_test.rb","times_changed":1},{"file_path":"lib\/churn\/locationmapping.rb","times_changed":1},{"file_path":"lib\/churn\/git_analyzer.rb","times_changed":1},{"file_path":".document","times_changed":1},{"file_path":"test\/test_helper.rb","times_changed":1},{"file_path":"lib\/churn\/churn_calculator.rb","times_changed":1}],"method_churn":[],"changed_files":[".gitignore","lib\/churn\/source_control.rb","lib\/tasks\/churn_tasks.rb","lib\/churn\/svn_analyzer.rb","Rakefile","README.rdoc","lib\/churn\/locationmapping.rb","lib\/churn\/git_analyzer.rb","\/dev\/null","lib\/churn\/churn_calculator.rb","lib\/churn.rb"],"class_churn":[],"changed_classes":[{"klass":"ChurnTest","file":"test\/churn_test.rb"},{"klass":"ChurnCalculator","file":"lib\/churn\/churn_calculator.rb"}],"changed_methods":[{"klass":"","method":"#report_churn","file":"lib\/tasks\/churn_tasks.rb"}]}}')
      changed_files, changed_classes, changed_methods = Churn::ChurnHistory.load_revision_data('aaa')
      assert changed_files.include?("lib/churn/source_control.rb")
      assert_equal 2, changed_classes.length
      assert_equal 1, changed_methods.length
    end
  end
  
end
