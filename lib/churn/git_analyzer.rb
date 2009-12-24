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

    def get_updated_files_change_info(revision, revisions)
      updated     = {}
      logs        = get_updated_files_from_log(revision, revisions)
      recent_file = nil
      logs.each do |line|
        if line.match(/^---/) || line.match(/^\+\+\+/)
          recent_file = get_recent_file(line)
          updated[recent_file] = [] unless updated.include?(recent_file)
        elsif line.match(/^@@/)
          removed_range = get_changed_range(line, '-')
          added_range   = get_changed_range(line, '\+')
          updated[recent_file] << removed_range
          updated[recent_file] << added_range
        else
          puts line.match(/^---/)
          raise "git diff lines that don't match the two patterns aren't expected: '#{line}'"
        end
      end
      updated
    end
    
    private

    def get_changed_range(line, matcher)
      change_start = line.match(/#{matcher}[0-9]+/)
      change_end   = line.match(/#{matcher}[0-9]+,[0-9]+/)
      change_start = change_start.to_s.gsub(/#{matcher}/,'')
      change_end   = change_end.to_s.gsub(/.*,/,'')

      range  = if change_end && change_end!=''
                 (change_start.to_i..(change_start.to_i+change_end.to_i))
               else
                 (change_start.to_i..change_start.to_i)
               end
      range
    end

    def get_recent_file(line)
      line = line.gsub(/^--- /,'').gsub(/^\+\+\+ /,'').gsub(/^a\//,'').gsub(/^b\//,'')
    end

    def date_range
      if @start_date
        date = Chronic.parse(@start_date)
        "--after=#{date.strftime('%Y-%m-%d')}"
      end
    end
    
  end

end
