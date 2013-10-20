module Churn

  #analizes Hg / Mercurial SCM to find recently changed files, and what lines have been altered
  class HgAnalyzer < SourceControl

    def self.supported?
      !!(`hg branch 2>&1` && $?.success?)
    end

    def get_logs
      `hg log -v#{date_range}`.split("\n").reject{|line| line !~ /^files:/}.map{|line| line.split(" ")[1..-1]}.flatten
    end

    def get_revisions
      `hg log#{date_range}`.split("\n").reject{|line| line !~ /^changeset:/}.map{|line| line[/:(\S+)$/, 1] }
    end

    private

    def get_diff(revision, previous_revision)
      `hg diff -r #{revision}:#{previous_revision} -U 0`.split(/\n/).select{|line| line.match(/^@@/) || line.match(/^---/) || line.match(/^\+\+\+/) }
    end

    def date_range
      if @start_date
        date = Chronic.parse(@start_date)
        " -d \"> #{date.strftime('%Y-%m-%d')}\""
      end
    end

    def get_recent_file(line)
      super(line).split("\t")[0]
    end

  end
end
