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

    def generate_history(starting_point)
      get_commit_history.each do |commit|
        `git checkout #{commit}`
        commit_date = `git show -s --format="%ci"`
        commit_date = Time.parse(commit_date)
        next if commit_date < starting_point
        #7776000 == 3.months without adding active support depenancy
        start_date  = (commit_date - 7776000)
        `churn -s "#{start_date}"`
      end
    ensure
      `git checkout master`
    end

    private

    def get_commit_history
      `git log --reverse --pretty=format:"%H"`.split(/\n/).reject{|line| line == ""}
    end

    def get_diff(revision, previous_revision)
      `git diff #{revision} #{previous_revision} --unified=0`.split(/\n/).select{|line| /^@@|^---|^\+\+\+/ =~ line }
    end

    def date_range
      if @start_date
        date = Chronic.parse(@start_date)
        "--after=#{date.strftime('%Y-%m-%d')}"
      end
    end

  end
end
