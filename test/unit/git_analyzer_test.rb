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

  should "run get_logs correctly" do
    git_analyzer = Churn::GitAnalyzer.new
    git_analyzer.expects(:`).returns(git_logs_output) #`fix syntax hilighting
    assert_equal ["public/css/application.css", "views/layout.erb", "README.md", "app.rb"], git_analyzer.get_logs
  end

  should "run get_revisions correctly" do
    git_analyzer = Churn::GitAnalyzer.new
    git_analyzer.expects(:`).returns(git_revisions_output) #`fix syntax hilighting
    assert_equal ["0aef1f56d5b3b546457e996450fd9ceca379f0a8",
                  "8038f1b17c3749540650aaab3f4e5e846cfc3b47",
                  "4d7e4859b2ed8a7e4f73e3540e7879c00cba9783"], git_analyzer.get_revisions
  end
  
  should "run date range correctly" do
    git_analyzer = Churn::GitAnalyzer.new(Date.parse('3/3/2010'))
    assert_equal "--after=2010-03-03", git_analyzer.send(:date_range)
  end

  should "run get_diff correctly" do
    git_analyzer = Churn::GitAnalyzer.new
    git_analyzer.expects(:`).returns(git_git_diff_output) #`fix syntax hilighting
    assert_equal ["--- a/public/css/application.css",
                  "+++ b/public/css/application.css",
                  "@@ -18,0 +19,4 @@ footer{",
                  "--- a/views/layout.erb",
                  "+++ b/views/layout.erb",
                  "@@ -43,0 +44 @@"], git_analyzer.send(:get_diff, 'rev', 'prev_rev')
  end

  protected

  # ran in a project
  # git log --after=2013-09-05 --name-only --pretty=format:
  def git_logs_output
  "public/css/application.css
views/layout.erb

README.md
app.rb"
  end

  # ran in a project
  # git log --after=2013-09-05 --pretty=format:"%H"
  def git_revisions_output
   "0aef1f56d5b3b546457e996450fd9ceca379f0a8
8038f1b17c3749540650aaab3f4e5e846cfc3b47
4d7e4859b2ed8a7e4f73e3540e7879c00cba9783"
  end

  # ran in a project
  # git diff 4d7e4859b2ed8a7e4f73e3540e7879c00cba9783 8038f1b17c3749540650aaab3f4e5e846cfc3b47 --unified=0
  def git_git_diff_output
    output = <<EOF
diff --git a/public/css/application.css b/public/css/application.css
index 522ca1a..730eb1e 100644
--- a/public/css/application.css
+++ b/public/css/application.css
@@ -18,0 +19,4 @@ footer{
+
+footer .container .right {
+    float:right;
+}
diff --git a/views/layout.erb b/views/layout.erb
index f8d3aea..7f4fb2f 100644
--- a/views/layout.erb
+++ b/views/layout.erb
@@ -43,0 +44 @@
+       <span class="right">a part of <a href="http://picoappz.com">picoappz</a></span>
EOF
    output
  end
end
