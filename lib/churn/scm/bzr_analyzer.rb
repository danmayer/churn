module Churn

  #analizes Bzr / Bazaar SCM to find recently changed files, and what lines have been altered
  class BzrAnalyzer < SourceControl
    
    def self.supported?
      !!(`bzr nick 2>&1` && $?.success?)
    end

    def get_logs
      `bzr log -v --short #{date_range}`.split("\n").reject{|line| line !~ /^[ ]*(M|A)  /}.map{|line| line.strip.split(" ")[1..-1]}.flatten
    end

    def get_revisions
      `bzr log --line #{date_range}`.split("\n").map{|line| line[/^(\S+):/, 1] }
    end

    private

    def get_diff(revision, previous_revision)
      `bzr diff -r #{previous_revision}..#{revision}`.split(/\n/).select{|line| line.match(/^@@/) || line.match(/^---/) || line.match(/^\+\+\+/) }
    end

    def date_range
      if @start_date
        date = Chronic.parse(@start_date)
        "-r #{date.strftime('%Y-%m-%d')}.."
      end
    end

    def get_recent_file(line)
      super(line).split("\t")[0]
    end

  end
end
