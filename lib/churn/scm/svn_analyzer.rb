module Churn

  # Analyzes SVN SCM to find recently changed files, and what lines have been altered
  class SvnAnalyzer < SourceControl

    # @return [Boolean]
    def self.supported?
      File.exist?(".svn")
    end

    # @return [Array]
    def get_logs
      `svn log --verbose#{date_range}#{svn_credentials}`.split(/\n/).map { |line| clean_up_svn_line(line) }.compact
    end

    # @raise RunTimeError Currently, the generate history option does not support Subversion
    def generate_history(starting_point)
      raise NotImplementedError, "currently the generate history option does not support subversion"
    end

    # This method is not supported by SVN
    # @return [Array]
    def get_revisions
      []
    end

    # This method is not supported by SVN
    # @return [Hash]
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
