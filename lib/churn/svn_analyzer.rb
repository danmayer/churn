module Churn

  #analizes SVN SCM to find recently changed files, and what lines have been altered
  class SvnAnalyzer < SourceControl
    def get_logs
      `svn log #{date_range} --verbose`.split(/\n/).map { |line| clean_up_svn_line(line) }.compact
    end

    private
    def date_range
      if @start_date
        date = Chronic.parse(@start_date)
        "--revision {#{date.strftime('%Y-%m-%d')}}:{#{Time.now.strftime('%Y-%m-%d')}}"
      end
    end

    def clean_up_svn_line(line)
      match = line.match(/\W*[A,M]\W+(\/.*)\b/)
      match ? match[1] : nil
    end
  end

end
