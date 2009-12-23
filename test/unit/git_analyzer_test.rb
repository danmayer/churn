require File.expand_path('../test_helper', File.dirname(__FILE__))

class GitAnalyzerTest < Test::Unit::TestCase
  
  should "parses logs correctly" do
    git_analyzer = Churn::GitAnalyzer.new
    revision     = 'first'
    revisions    = ['first']
    lines        = ["--- a/lib/churn/churn_calculator.rb", "+++ b/lib/churn/churn_calculator.rb", "@@ -18,0 +19 @@ module Churn"]
    git_analyzer.stubs(:get_updated_files_from_log).returns(lines)
    updated = git_analyzer.get_updated_files_change_info(revision, revisions)
    expected_hash = {"lib/churn/churn_calculator.rb"=>[18..18, 19..19]}
    assert_equal = updated
  end
  
end

