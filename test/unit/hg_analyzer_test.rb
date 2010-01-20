require File.expand_path('../test_helper', File.dirname(__FILE__))

class HgAnalyzerTest < Test::Unit::TestCase

  context "HgAnalyzer#get_logs" do
    should "return a list of changed files" do
      hg_analyzer = Churn::HgAnalyzer.new
      hg_analyzer.expects(:`).with('hg log -v').returns("changeset:   1:4760c1d7cd40\ntag:         tip\nuser:        Adam Walters <awalters@obtiva.com>\ndate:        Sat Jan 16 14:21:28 2010 -0600\nfiles:       file1.rb file2.rb file3.rb\ndescription:\nSecond commit with 3 files now.\nLong commit\n\n\nchangeset:   0:3cb77114f02a\nuser:        Adam Walters <awalters@obtiva.com>\ndate:        Sat Jan 16 14:19:32 2010 -0600\nfiles:       file1.rb\ndescription:\nFirst commit\n\n\n")
      assert_equal ["file1.rb", "file2.rb", "file3.rb", "file1.rb"], hg_analyzer.get_logs
    end

    should "scope the changed files to an optional date range" do
      hg_analyzer = Churn::HgAnalyzer.new("1/16/2010")
      hg_analyzer.expects(:`).with('hg log -v -d "> 2010-01-16"').returns("changeset:   1:4760c1d7cd40\ntag:         tip\nuser:        Adam Walters <awalters@obtiva.com>\ndate:        Sat Jan 16 14:21:28 2010 -0600\nfiles:       file1.rb file2.rb file3.rb\ndescription:\nSecond commit with 3 files now.\nLong commit\n\n\nchangeset:   0:3cb77114f02a\nuser:        Adam Walters <awalters@obtiva.com>\ndate:        Sat Jan 16 14:19:32 2010 -0600\nfiles:       file1.rb\ndescription:\nFirst commit\n\n\n")
      assert_equal ["file1.rb", "file2.rb", "file3.rb", "file1.rb"], hg_analyzer.get_logs
    end
  end

  context "HgAnalyzer#get_revisions" do
    should "return a list of changeset ids" do
      hg_analyzer = Churn::HgAnalyzer.new
      hg_analyzer.expects(:`).with('hg log').returns("changeset:   1:4760c1d7cd40\ntag:         tip\nuser:        Adam Walters <awalters@obtiva.com>\ndate:        Sat Jan 16 14:21:28 2010 -0600\nsummary:     Second commit with 3 files now.\n\nchangeset:   0:3cb77114f02a\nuser:        Adam Walters <awalters@obtiva.com>\ndate:        Sat Jan 16 14:19:32 2010 -0600\nsummary:     First commit\n\n")
      assert_equal ["4760c1d7cd40", "3cb77114f02a"], hg_analyzer.get_revisions
    end

    should "scope the changesets to an optional date range" do
      hg_analyzer = Churn::HgAnalyzer.new("1/16/2010")
      hg_analyzer.expects(:`).with('hg log -d "> 2010-01-16"').returns("changeset:   1:4760c1d7cd40\ntag:         tip\nuser:        Adam Walters <awalters@obtiva.com>\ndate:        Sat Jan 16 14:21:28 2010 -0600\nsummary:     Second commit with 3 files now.\n\nchangeset:   0:3cb77114f02a\nuser:        Adam Walters <awalters@obtiva.com>\ndate:        Sat Jan 16 14:19:32 2010 -0600\nsummary:     First commit\n\n")
      assert_equal ["4760c1d7cd40", "3cb77114f02a"], hg_analyzer.get_revisions
    end
  end

  context "HgAnalyzer#get_updated_files_from_log(revision, revisions)" do
    should "return a list of modified files and the change hunks (chunks)" do
      hg_analyzer = Churn::HgAnalyzer.new
      hg_analyzer.expects(:`).with('hg diff -r 4760c1d7cd40:3cb77114f02a -U 0').returns("diff -r 4760c1d7cd40 -r 3cb77114f02a file1.rb\n--- a/file1.rb\tSat Jan 16 14:21:28 2010 -0600\n+++ b/file1.rb\tSat Jan 16 14:19:32 2010 -0600\n@@ -1,3 +0,0 @@\n-First\n-Adding sample data\n-Third line\ndiff -r 4760c1d7cd40 -r 3cb77114f02a file2.rb\n--- a/file2.rb\tSat Jan 16 14:21:28 2010 -0600\n+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,7 +0,0 @@\n-This is the second file.\n-\n-Little more data\n-\n-def cool_method\n-  \"hello\"\n-end\ndiff -r 4760c1d7cd40 -r 3cb77114f02a file3.rb\n--- a/file3.rb\tSat Jan 16 14:21:28 2010 -0600\n+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000\n@@ -1,5 +0,0 @@\n-Third file here.\n-\n-def another_method\n-  \"foo\"\n-end\n")
      assert_equal ["--- a/file1.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ b/file1.rb\tSat Jan 16 14:19:32 2010 -0600", "@@ -1,3 +0,0 @@", "--- a/file2.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000", "@@ -1,7 +0,0 @@", "--- a/file3.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000", "@@ -1,5 +0,0 @@"], hg_analyzer.get_updated_files_from_log("4760c1d7cd40", ["4760c1d7cd40", "3cb77114f02a"])
    end

    should "return an empty array if it's the final revision" do
      hg_analyzer = Churn::HgAnalyzer.new
      assert_equal [], hg_analyzer.get_updated_files_from_log("3cb77114f02a", ["4760c1d7cd40", "3cb77114f02a"])
    end
  end

  context "HgAnalyzer#get_updated_files_change_info(revision, revisions)" do
    setup do
      @hg_analyzer = Churn::HgAnalyzer.new
    end

    should "return all modified files with their line differences" do
      @hg_analyzer.expects(:get_updated_files_from_log).with("4760c1d7cd40", ["4760c1d7cd40", "3cb77114f02a"]).returns(["--- a/file1.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ b/file1.rb\tSat Jan 16 14:19:32 2010 -0600", "@@ -1,3 +0,0 @@", "--- a/file2.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000", "@@ -1,7 +0,0 @@", "--- a/file3.rb\tSat Jan 16 14:21:28 2010 -0600", "+++ /dev/null\tThu Jan 01 00:00:00 1970 +0000", "@@ -1,5 +0,0 @@"])
      assert_equal({"/dev/null" => [1..8, 0..0, 1..6, 0..0], "file3.rb" => [], "file1.rb" => [], "file2.rb" => [], "file1.rb" => [1..4, 0..0]}, @hg_analyzer.get_updated_files_change_info("4760c1d7cd40", ["4760c1d7cd40", "3cb77114f02a"]))
    end

    should "raise an error if it encounters a line it cannot parse" do
      @hg_analyzer.expects(:get_updated_files_from_log).with("4760c1d7cd40", ["4760c1d7cd40", "3cb77114f02a"]).returns(["foo"])
      assert_raise RuntimeError do
        @hg_analyzer.stubs(:puts) # supress output from raised error
        @hg_analyzer.get_updated_files_change_info("4760c1d7cd40", ["4760c1d7cd40", "3cb77114f02a"])
      end
    end
  end

end

