module Churn

  # Base clase for analyzing various SCM systems like git, HG, and SVN
  class SourceControl

    def self.set_source_control(start_date)
      if GitAnalyzer.supported?
        GitAnalyzer.new(start_date)
      elsif HgAnalyzer.supported?
        HgAnalyzer.new(start_date)
      elsif BzrAnalyzer.supported?
        BzrAnalyzer.new(start_date)
      elsif SvnAnalyzer.supported?
        SvnAnalyzer.new(start_date)
      else
        raise "Churn requires a bazaar, git, mercurial, or subversion source control"
      end
    end
    
    def self.supported?
      raise "child class must implement"
    end

    def initialize(start_date=nil)
      @start_date = start_date
    end

    def get_logs
      raise "child class must implement"
    end

    def get_revisions
      raise "child class must implement"
    end

    def get_updated_files_change_info(revision, revisions)
      updated     = {}
      logs        = get_updated_files_from_log(revision, revisions)
      recent_file = nil
      logs.each do |line|
        if line.match(/^---/) || line.match(/^\+\+\+/)
          # Remove the --- a/ and +++ b/ if present
          recent_file = get_recent_file(line)
          updated[recent_file] = [] unless updated.include?(recent_file)
        elsif line.match(/^@@/)
          # Now add the added/removed ranges for the line
          removed_range = get_changed_range(line, '-')
          added_range   = get_changed_range(line, '\+')
          updated[recent_file] << removed_range
          updated[recent_file] << added_range
        else
          puts line.match(/^---/)
          raise "diff lines that don't match the two patterns aren't expected: '#{line}'"
        end
      end
      updated
    end

    def get_updated_files_from_log(revision, revisions)
      current_index = revisions.index(revision)
      previous_index = current_index+1
      previous_revision = revisions[previous_index] unless revisions.length < previous_index
      if revision && previous_revision
        get_diff(revision, previous_revision)
      else
        []
      end
    end
    
    private

    def get_changed_range(line, matcher)
      change_start = line.match(/#{matcher}[0-9]+/)
      change_end   = line.match(/#{matcher}[0-9]+,[0-9]+/)
      change_start = change_start.to_s.gsub(/#{matcher}/,'')
      change_end   = change_end.to_s.gsub(/.*,/,'')
      
      change_start_num = change_start.to_i
      range  = if change_end && change_end!=''
                 (change_start_num..(change_start_num+change_end.to_i))
               else
                 (change_start_num..change_start_num)
               end
      range
    end

    def get_recent_file(line)
      line = line.gsub(/^--- /,'').gsub(/^\+\+\+ /,'').gsub(/^a\//,'').gsub(/^b\//,'')
    end

  end

end
