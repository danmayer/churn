require 'chronic'
require 'sexp_processor'
require 'ruby_parser'
require 'json'
require 'fileutils'
require 'lib/churn/source_control'
require 'lib/churn/git_analyzer'
require 'lib/churn/svn_analyzer'
require 'lib/churn/location_mapping'
require 'lib/churn/churn_history'

module Churn

  class ChurnCalculator

    def initialize(options={})
      start_date = options.fetch(:start_date) { '3 months ago' }
      @minimum_churn_count = options.fetch(:minimum_churn_count) { 5 }
      puts start_date
      if self.class.git?
        @source_control = GitAnalyzer.new(start_date)
      elsif File.exist?(".svn")
        @source_control = SvnAnalyzer.new(start_date)
      else
        raise "Churning requires a subversion or git repo"
      end
      @revision_changes = {}
      @method_changes   = {}
      @class_changes    = {}
    end

    def report
      self.emit 
      self.analyze
      self.to_h
    end
    
    def emit
      @changes   = parse_log_for_changes.reject {|file, change_count| change_count < @minimum_churn_count}
      @revisions = parse_log_for_revision_changes  
    end 

    def analyze
      @changes = @changes.to_a.sort {|x,y| y[1] <=> x[1]}
      @changes = @changes.map {|file_path, times_changed| {:file_path => file_path, :times_changed => times_changed }}

      calculate_revision_changes

      @method_changes.to_a.sort {|x,y| y[1] <=> x[1]}
      @method_changes          = @method_changes.map {|method, times_changed| {'method' => method, 'times_changed' => times_changed }}
      @class_changes.to_a.sort {|x,y| y[1] <=> x[1]}
      @class_changes          = @class_changes.map {|klass, times_changed| {'klass' => klass, 'times_changed' => times_changed }}
    end

    def to_h
      hash                        = {:churn => {:changes => @changes}}
      hash[:churn][:method_churn] = @method_changes
      hash[:churn][:class_churn]  = @class_changes
      #detail the most recent changes made this revision
      if @revision_changes[@revisions.first]
        changes = @revision_changes[@revisions.first]
        hash[:churn][:changed_files]   = changes[:files]
        hash[:churn][:changed_classes] = changes[:classes]
        hash[:churn][:changed_methods] = changes[:methods]
      end
      #TODO crappy place to do this but save hash to revision file but while entirely under metric_fu only choice
      revision = @revisions.first
      ChurnHistory.store_revision_history(revision, hash)
      hash
    end

    private

    def self.git?
      system("git branch")
    end

    def calculate_revision_changes
      @revisions.each do |revision|
        if revision == @revisions.first
          #can't iterate through all the changes and tally them up
          #it only has the current files not the files at the time of the revision
          #parsing requires the files
          changed_files, changed_classes, changed_methods = calculate_revision_data(revision)
        else
          changed_files, changed_classes, changed_methods = ChurnHistory.load_revision_data(revision)
        end
        calculate_changes!(changed_methods, @method_changes) if changed_methods
        calculate_changes!(changed_classes, @class_changes) if changed_classes
        
        @revision_changes[revision] = { :files => changed_files, :classes => changed_classes, :methods => changed_methods }
      end
    end

    def calculate_revision_data(revision)
      changed_files   = parse_logs_for_updated_files(revision, @revisions)
      
      changed_classes = []
      changed_methods = []
      changed_files.each do |file|
        classes, methods = get_changes(file)
        changed_classes += classes
        changed_methods += methods
      end
      changed_files   = changed_files.map { |file, lines| file }
      [changed_files, changed_classes, changed_methods]
    end

    def calculate_changes!(changed, total_changes)
      if changed
        changed.each do |change|
          total_changes.include?(change) ? total_changes[change] = total_changes[change]+1 : total_changes[change] = 1
        end
      end
      total_changes
    end

    def get_changes(change)
      begin
        file = change.first
        breakdown = LocationMapping.new
        breakdown.get_info(file)
        changes = change.last
        classes = changes_for_type(changes, breakdown, :classes)
        methods = changes_for_type(changes, breakdown, :methods)
        #todo move to method
        classes = classes.map{ |klass| {'file' => file, 'klass' => klass} }
        methods = methods.map{ |method| {'file' => file, 'klass' => get_klass_for(method), 'method' => method} }
        [classes, methods]
      rescue => error
        [[],[]]
      end
    end

    def get_klass_for(method)
      method.gsub(/(#|\.).*/,'')
    end

    def changes_for_type(changes, breakdown, type)
      item_collection = if type == :classes
                          breakdown.klasses_collection
                        elsif type == :methods
                          breakdown.methods_collection
                        end
      changed_items  = []
      item_collection.each_pair do |item, item_lines|
        item_lines = item_lines[0].to_a
        changes.each do |change_range|
          item_lines.each do |line|
            changed_items << item if change_range.include?(line) && !changed_items.include?(item)
          end
        end
      end
      changed_items
    end
    
    def parse_log_for_changes
      changes = {}
      
      logs = @source_control.get_logs
      logs.each do |line|
        changes[line] ? changes[line] += 1 : changes[line] = 1
      end
      changes
    end

    def parse_log_for_revision_changes
      @source_control.get_revisions
    end
    
    def parse_logs_for_updated_files(revision, revisions)
      updated     = {}
      recent_file = nil

      #SVN doesn't support this
      return updated unless @source_control.respond_to?(:get_updated_files_from_log)
      logs = @source_control.get_updated_files_from_log(revision, revisions)
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

  end

end
