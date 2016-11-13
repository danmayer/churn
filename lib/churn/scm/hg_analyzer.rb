module Churn

  # Analyzes Hg / Mercurial SCM to find recently changed files, and what lines have been altered
  class HgAnalyzer < SourceControl

    # @return [Array]
    def self.supported?
      !!(`hg branch 2>&1` && cmd_success?)
    end

    # @return [Array]
    def get_logs
      `hg log -v#{date_range}`.split("\n").reject{|line| line !~ /^files:/}.map{|line| line.split(" ")[1..-1]}.flatten
    end

    # @return [Array]
    def get_revisions
      `hg log#{date_range}`.split("\n").reject{|line| line !~ /^changeset:/}.map{|line| line[/:(\S+)$/, 1] }
    end

    # @raise RunTimeError Currently, the generate history option does not support Mercurial
    def generate_history(starting_point)
      raise NotImplementedError, "currently the generate history option does not support mercurial"
    end

    private

    def self.cmd_success?
      $?.success?
    end
    
    def get_diff(revision, previous_revision)
      `hg diff -r #{revision}:#{previous_revision} -U 0`.split(/\n/).select{|line| /^@@|^---|^\+\+\+/ =~ line }
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
