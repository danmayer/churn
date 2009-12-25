require 'chronic'
require 'sexp_processor'
require 'ruby_parser'
require 'json'
require 'fileutils'

$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'source_control'
require 'git_analyzer'
require 'svn_analyzer'
require 'location_mapping'
require 'churn_history'

module Churn

  class ChurnCalculator

    def initialize(options={})
      start_date = options.fetch(:start_date) { '3 months ago' }
      @minimum_churn_count = options.fetch(:minimum_churn_count) { 5 }
      @source_control = set_source_control(start_date)
      @revision_changes = {}
      @method_changes   = {}
      @class_changes    = {}
    end

    def report
      self.emit 
      self.analyze
      self.to_s
    end
    
    def emit
      @changes   = parse_log_for_changes.reject {|file, change_count| change_count < @minimum_churn_count}
      @revisions = parse_log_for_revision_changes  
    end 

    def analyze
      @changes = @changes.to_a.sort {|x,y| y[1] <=> x[1]}
      @changes = @changes.map {|file_path, times_changed| {:file_path => file_path, :times_changed => times_changed }}

      calculate_revision_changes

      @method_changes = @method_changes.to_a.sort {|x,y| y[1] <=> x[1]}
      @method_changes = @method_changes.map {|method, times_changed| {'method' => method, 'times_changed' => times_changed }}
      @class_changes  = @class_changes.to_a.sort {|x,y| y[1] <=> x[1]}
      @class_changes  = @class_changes.map {|klass, times_changed| {'klass' => klass, 'times_changed' => times_changed }}
    end

    def to_h
      hash                        = {:churn => {:changes => @changes}}
      hash[:churn][:class_churn]  = @class_changes
      hash[:churn][:method_churn] = @method_changes
      #detail the most recent changes made this revision
      if @revision_changes[@revisions.first]
        changes = @revision_changes[@revisions.first]
        hash[:churn][:changed_files]   = changes[:files]
        hash[:churn][:changed_classes] = changes[:classes]
        hash[:churn][:changed_methods] = changes[:methods]
      end
      #TODO crappy place to do this but save hash to revision file but while entirely under metric_fu only choice
      ChurnHistory.store_revision_history(@revisions.first, hash)
      hash
    end

    def to_s
      hash   = to_h
      result = seperator 
      result +="* Revision Changes \n"
      result += seperator
      result += "files: \n"
      result += display_array(hash[:churn][:changed_files])
      result += "\nclasses: \n"
      result += display_array(hash[:churn][:changed_classes])
      result += "\nmethods: \n"
      result += display_array(hash[:churn][:changed_methods])
      result += seperator 
      result +="* Project Churn \n"
      result += seperator
      result += "files: \n"
      result += display_array(hash[:churn][:changes])
      result += "\nclasses: \n"
      result += display_array(hash[:churn][:class_churn])
      result += "\nmethods: \n"
      result += display_array(hash[:churn][:method_churn])
    end

    private

    def display_array(array)
      result = ""
      array.each { |element| result += " * #{element.inspect}\n" }
      result
    end

    def seperator
      "*"*70+"\n"
    end

    def self.git?
      system("git branch")
    end

    def set_source_control(start_date)
      if self.class.git?
        GitAnalyzer.new(start_date)
      elsif File.exist?(".svn")
        SvnAnalyzer.new(start_date)
      else
        raise "Churning requires a subversion or git repo"
      end
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
      changed_files.each do |file_changes|
        if file_changes.first.match(/.*\.rb/)
          classes, methods = get_changes(file_changes)
          changed_classes += classes
          changed_methods += methods
        end
      end
      changed_files   = changed_files.map { |file, lines| file }
      [changed_files, changed_classes, changed_methods]
    end

    def calculate_changes!(changed_objs, total_changes)
      if changed_objs
        changed_objs.each do |change|
          total_changes.include?(change) ? total_changes[change] = total_changes[change]+1 : total_changes[change] = 1
        end
      end
      total_changes
    end

    def get_changes(change)
      file = change.first
      breakdown = LocationMapping.new
      breakdown.get_info(file)
      changes = change.last
      classes = changes_for_type(changes, breakdown.klasses_collection)
      methods = changes_for_type(changes, breakdown.methods_collection)
      classes = classes.map{ |klass| {'file' => file, 'klass' => klass} }
      methods = methods.map{ |method| {'file' => file, 'klass' => get_klass_for(method), 'method' => method} }
      [classes, methods]
    rescue => error
      [[],[]]
    end

    def get_klass_for(method)
      method.gsub(/(#|\.).*/,'')
    end

    def changes_for_type(changes, item_collection)
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
      #SVN doesn't support this
      return {} unless @source_control.respond_to?(:get_updated_files_change_info)
      @source_control.get_updated_files_change_info(revision, revisions)
    end

  end

end
