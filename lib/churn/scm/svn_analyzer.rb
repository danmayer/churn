module Churn

  #analizes SVN SCM to find recently changed files, and what lines have been altered
  class SvnAnalyzer < SourceControl

    def self.supported?
      File.exist?(".svn")
    end

    def get_logs
      `svn log --verbose#{date_range}#{svn_credentials}`.split(/\n/).map { |line| clean_up_svn_line(line) }.compact
    end

    def generate_history(starting_point)
      raise "currently the generate history option does not support subversion"
    end

    #below 2 methods aren't supported by SVN so they become noops
    def get_revisions
      []
    end

    def get_updated_files_change_info(revision, revisions)
      {}
    end

    private

    def svn_credentials
      " --username #{ENV['SVN_USR']} --password #{ENV['SVN_PWD']}" if ENV['SVN_PWD'] && ENV['SVN_USR']
    end

    def date_range
      if @start_date
        date = Chronic.parse(@start_date)
        " --revision {#{date.strftime('%Y-%m-%d')}}:{#{Time.now.strftime('%Y-%m-%d')}}"
      end
    end

    def clean_up_svn_line(line)
      match = line.match(/\W*[A,M]\W+(\/.*)\b/)
      match ? match[1] : nil
    end
  end

end
