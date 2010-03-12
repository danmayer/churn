module Churn
  class HgAnalyzer < SourceControl
    def get_logs
      `hg log -v#{date_range}`.split("\n").reject{|line| line !~ /^files:/}.map{|l| l.split(" ")[1..-1]}.flatten
    end

    def get_revisions
      `hg log#{date_range}`.split("\n").reject{|line| line !~ /^changeset:/}.map{|l| l[/:(\S+)$/, 1] }
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
      line = line.gsub(/^--- /,'').gsub(/^\+\+\+ /,'').gsub(/^a\//,'').gsub(/^b\//,'').split("\t")[0]
    end

  end
end
