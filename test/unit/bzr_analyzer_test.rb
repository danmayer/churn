require File.expand_path('../test_helper', File.dirname(__FILE__))

class BzrAnalyzerTest < Test::Unit::TestCase
  context "BzrAnalyzer#get_logs" do
    should "return a list of changed files" do
      bzr_analyzer = Churn::BzrAnalyzer.new
      bzr_analyzer.expects(:`).with('bzr log -v --short ').returns(" 1947 Adam Walters    2010-01-16\n   Second commit with 3 files now.\n      M  file1.rb\n      M  file2.rb\n      M  file3.rb\n\n 1946 Adam Walters    2010-01-16\n      First commit\n      A  file1.rb\n")
      assert_equal ["file1.rb", "file2.rb", "file3.rb", "file1.rb"], bzr_analyzer.get_logs
    end

    should "scope the changed files to an optional date range" do
      bzr_analyzer = Churn::BzrAnalyzer.new("1/16/2010")
      bzr_analyzer.expects(:`).with('bzr log -v --short -r 2010-01-16..').returns(" 1947 Adam Walters 2010-01-16\n      Second commit with 3 files now.\n      M  file1.rb\n      M  file2.rb\n      M  file3.rb\n\n 1946 Adam Walters    2010-01-16\n      First commit\n      A  file1.rb\n")
      assert_equal ["file1.rb", "file2.rb", "file3.rb", "file1.rb"], bzr_analyzer.get_logs
    end
  end

  context "BzrAnalyzer#get_revisions" do
    should "return a list of changeset ids" do
      bzr_analyzer = Churn::BzrAnalyzer.new
      bzr_analyzer.expects(:`).with('bzr log --line ').returns("1947: Adam Walters 2010-01-16 Second commit with 3 files now.\n1946: Adam Walters 2010-01-16 First commit\n")
      assert_equal ["1947", "1946"], bzr_analyzer.get_revisions
    end

    should "scope the changesets to an optional date range" do
      bzr_analyzer = Churn::BzrAnalyzer.new("1/16/2010")
      bzr_analyzer.expects(:`).with('bzr log --line -r 2010-01-16..').returns("1947: Adam Walters 2010-01-16 Second commit with 3 files now.\n1946: Adam Walters 2010-01-16 First commit\n")
      assert_equal ["1947", "1946"], bzr_analyzer.get_revisions
    end
  end

  context "BzrAnalyzer#get_updated_files_from_log(revision, revisions)" do
    should "return a list of modified files and the change hunks (chunks)" do
      bzr_analyzer = Churn::BzrAnalyzer.new
      bzr_analyzer.expects(:`).with('bzr diff -r 1946..1947').returns("=== modified file 'a/file1.rb'\n--- a/file1.rb\tSat Jan 16 14:21:28 2010 -0600\n+++ b/file1.rb\tSat Jan 16 14:19:32 2010 -0600\n@@ -1,3 +0,0 @@\n-First\n-Adding sample data\n-Third line\ndiff -r 1947 -r 1946 file2.rb\n=== modified file 'a/file2.rb'\n--- a/file2.rb\tSat Jan 16 14:21:28 2010 -0600\n+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,7 +0,0 @@\n-This is the second file.\n-\n-Little more data\n-\n-def cool_method\n-  \"hello\"\n-end\ndiff -r 1947 -r 1946 file3.rb\n--- a/file3.rb\tSat Jan 16 14:21:28 2010 -0600\n+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,5 +0,0 @@\n-Third file here.\n-\n-def another_method\n-  \"foo\"\n-end\n")
      assert_equal ["--- a/file1.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ b/file1.rb\tSat Jan 16 14:19:32 2010 -0600", "@@ -1,3 +0,0 @@", "--- a/file2.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000", "@@ -1,7 +0,0 @@", "--- a/file3.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000", "@@ -1,5 +0,0 @@"], bzr_analyzer.get_updated_files_from_log("1947", ["1947", "1946"])
    end

    should "return an empty array if it's the final revision" do
      bzr_analyzer = Churn::BzrAnalyzer.new
      assert_equal [], bzr_analyzer.get_updated_files_from_log("1946", ["1947", "1946"])
    end
  end

  context "BzrAnalyzer#get_updated_files_change_info(revision, revisions)" do
    setup do
      @bzr_analyzer = Churn::BzrAnalyzer.new
    end

    should "return all modified files with their line differences" do
      @bzr_analyzer.expects(:get_updated_files_from_log).with("1947", ["1947", "1946"]).returns(["--- a/file1.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ b/file1.rb\tSat Jan 16 14:19:32 2010 -0600", "@@ -1,3 +0,0 @@", "--- a/file2.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000", "@@ -1,7 +0,0 @@", "--- a/file3.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000", "@@ -1,5 +0,0 @@"])
      assert_equal({"/dev/null" => [1..8, 0..0, 1..6, 0..0], "file3.rb" => [], "file1.rb" => [], "file2.rb" => [], "file1.rb" => [1..4, 0..0]}, @bzr_analyzer.get_updated_files_change_info("1947", ["1947", "1946"]))
    end

    should "raise an error if it encounters a line it cannot parse" do
      @bzr_analyzer.expects(:get_updated_files_from_log).with("1947", ["1947", "1946"]).returns(["foo"])
      assert_raise RuntimeError do
        @bzr_analyzer.stubs(:puts) # supress output from raised error
        @bzr_analyzer.get_updated_files_change_info("1947", ["1947", "1946"])
      end
    end
  end

end

