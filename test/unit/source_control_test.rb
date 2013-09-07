require File.expand_path('../test_helper', File.dirname(__FILE__))

class SourceControlTest < Test::Unit::TestCase
  
  should "get_updated_files_from_log if revision and previous revision" do
    sc = Churn::SourceControl.new(Date.today)
    current = 'current'
    revisions = ['future',current,'past']
    def sc.get_diff(revision, previous_revision)
      [previous_revision]
    end
    assert_equal ['past'], sc.get_updated_files_from_log(current,revisions)
  end

  should "get_updated_files_from_log get empty array when no revisions found" do
    sc = Churn::SourceControl.new(Date.today)
    current = 'current'
    revisions = ['future',current]
    assert_equal [], sc.get_updated_files_from_log(current,revisions)
  end
  
end
