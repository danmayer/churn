module Churn

  #analizes git SCM to find recently changed files, and what lines have been altered
  class GitAnalyzer < SourceControl

    def self.supported?
      !!(`git branch 2>&1` && $?.success?)
    end

    def get_logs
      `git log #{date_range} --name-only --pretty=format:`.split(/\n/).reject{|line| line == ""}
    end
    
    def get_revisions
      `git log #{date_range} --pretty=format:"%H"`.split(/\n/).reject{|line| line == ""}
    end

    def get_commit_history
      `git log --reverse --pretty=format:"%H"`.split(/\n/).reject{|line| line == ""}
    end
    
    private

    def get_diff(revision, previous_revision)
      `git diff #{revision} #{previous_revision} --unified=0`.split(/\n/).select{|line| line.match(/^@@/) || line.match(/^---/) || line.match(/^\+\+\+/) }
    end

    def date_range
      if @start_date
        date = Chronic.parse(@start_date)
        "--after=#{date.strftime('%Y-%m-%d')}"
      end
    end
    
  end
end
