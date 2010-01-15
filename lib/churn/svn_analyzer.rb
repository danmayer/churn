module Churn

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
      m = line.match(/\W*[A,M]\W+(\/.*)\b/)
      m ? m[1] : nil
    end
  end

end
