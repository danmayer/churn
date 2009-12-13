module Churn

  class GitAnalyzer < SourceControl
    def get_logs
      `git log #{date_range} --name-only --pretty=format:`.split(/\n/).reject{|line| line == ""}
    end
    
    def get_revisions
      `git log #{date_range} --pretty=format:"%H"`.split(/\n/).reject{|line| line == ""}
    end
    
    def get_updated_files_from_log(revision, revisions)
      current_index = revisions.index(revision)
      previous_index = current_index+1
      previous_revision = revisions[previous_index] unless revisions.length < previous_index
      if revision && previous_revision
        `git diff #{revision} #{previous_revision} --unified=0`.split(/\n/).select{|line| line.match(/^@@/) || line.match(/^---/) || line.match(/^\+\+\+/) }
      else
        []
      end
    end
    
    private
    def date_range
      if @start_date
        date = Chronic.parse(@start_date)
        "--after=#{date.strftime('%Y-%m-%d')}"
      end
    end
    
  end

end
