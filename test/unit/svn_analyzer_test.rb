require File.expand_path('../test_helper', File.dirname(__FILE__))

class SvnAnalyzerTest < Test::Unit::TestCase
  
  should "parses logs correctly" do
    svn_analyzer = Churn::SvnAnalyzer.new
    revision     = 'first'
    revisions    = ['first']
    lines        = ["--- a/lib/churn/churn_calculator.rb", "+++ b/lib/churn/churn_calculator.rb", "@@ -18,0 +19 @@ module Churn"]
    svn_analyzer.stubs(:get_updated_files_from_log).returns(lines)
    updated = svn_analyzer.get_updated_files_change_info(revision, revisions)
    expected_hash = {"lib/churn/churn_calculator.rb"=>[18..18, 19..19]}
    assert_equal = updated
  end

  should "run get_logs correctly" do
    svn_analyzer = Churn::SvnAnalyzer.new
    svn_analyzer.expects(:`).returns(svn_output) #`fix syntax hilighting
    assert_equal ["/trunk", "/trunk/test.txt"], svn_analyzer.get_logs
  end

  should "run date range correctly" do
    svn_analyzer = Churn::SvnAnalyzer.new(Date.parse('3/3/2010'))
    assert_equal " --revision {2010-03-03}:{#{Date.today.to_s}}", svn_analyzer.send(:date_range)
  end

  context "SvnAnalyzer#get_logs" do
    should "return a list of changed files" do
      ENV['SVN_PWD']= nil
      ENV['SVN_USR']= nil
      svn_analyzer = Churn::SvnAnalyzer.new
      svn_analyzer.expects(:`).with('svn log --verbose').returns('
      A /file1.rb
      A /dir/file2.rb
      A /file3.rb
      M /file1.rb')
      assert_equal ['/file1.rb', '/dir/file2.rb', '/file3.rb', '/file1.rb'], svn_analyzer.get_logs
    end
    should "invoke with svn credentials " do
      ENV['SVN_PWD']= '123qwe'
      ENV['SVN_USR']= 'user123'
      svn_analyzer = Churn::SvnAnalyzer.new
      svn_analyzer.expects(:`).with('svn log --verbose --username user123 --password 123qwe').returns('
      A /file1.rb
      A /dir/file2.rb
      A /file3.rb
      M /file1.rb')
      assert_equal ['/file1.rb', '/dir/file2.rb', '/file3.rb', '/file1.rb'], svn_analyzer.get_logs
    end
  end

  protected

  def svn_output
    "------------------------------------------------------------------------
r1 | danmayer | 2013-09-07 10:45:32 -0400 (Sat, 07 Sep 2013) | 1 line
Changed paths:
   A /trunk
   A /trunk/test.txt

Initial import of project1
------------------------------------------------------------------------"
  end
  
end
