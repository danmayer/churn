module Churn

  # Analyzes Bzr / Bazaar SCM, to find recently changed files, and what lines have been altered
  class BzrAnalyzer < SourceControl

    # @return [Boolean]
    def self.supported?
      !!(`bzr nick 2>&1` && cmd_success?)
    end

    # @return [Array]
    def get_logs
      `bzr log -v --short #{date_range}`.split("\n").reject{|line| line !~ /^[ ]*(M|A)  /}.map{|line| line.strip.split(" ")[1..-1]}.flatten
    end

    # @return [Array]
    def get_revisions
      `bzr log --line #{date_range}`.split("\n").map{|line| line[/^(\S+):/, 1] }
    end

    # @raise RunTimeError Currently, the generate history option does not support Bazaar
    def generate_history(starting_point)
      raise NotImplementedError, "currently the generate history option does not support bazaar"
    end

    private

    def self.cmd_success?
      $?.success?
    end

    def get_diff(revision, previous_revision)
      `bzr diff -r #{previous_revision}..#{revision}`.split(/\n/).select{|line| /^@@|^---|^\+\+\+/ =~ line }
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
