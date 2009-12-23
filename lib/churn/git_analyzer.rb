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
          line = line.gsub(/^--- /,'').gsub(/^\+\+\+ /,'').gsub(/^a\//,'').gsub(/^b\//,'')
          unless updated.include?(line)
            updated[line] = [] 
          end
          recent_file = line
        elsif line.match(/^@@/)
          #TODO cleanup / refactor
          #puts "#{recent_file}: #{line}"
          removed        = line.match(/-[0-9]+/)
          removed_length = line.match(/-[0-9]+,[0-9]+/)
          removed        = removed.to_s.gsub(/-/,'')
          removed_length = removed_length.to_s.gsub(/.*,/,'')
          added          = line.match(/\+[0-9]+/)
          added_length   = line.match(/\+[0-9]+,[0-9]+/)
          added          = added.to_s.gsub(/\+/,'')
          added_length   = added_length.to_s.gsub(/.*,/,'')
          removed_range  = if removed_length && removed_length!=''
                             (removed.to_i..(removed.to_i+removed_length.to_i))
                           else
                             (removed.to_i..removed.to_i)
                           end
          added_range    = if added_length && added_length!=''
                             (added.to_i..(added.to_i+added_length.to_i))
                           else
                             (added.to_i..added.to_i)
                           end
          updated[recent_file] << removed_range
          updated[recent_file] << added_range
        else
          raise "git diff lines that don't match the two patterns aren't expected"
        end
      end
      updated
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
