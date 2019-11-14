require 'chronic'
require 'sexp_processor'
require 'ruby_parser'
require 'json'
require 'hirb'
require 'fileutils'

require_relative 'scm/source_control'
require_relative 'scm/git_analyzer'
require_relative 'scm/svn_analyzer'
require_relative 'scm/hg_analyzer'
require_relative 'scm/bzr_analyzer'

require_relative 'location_mapping'
require_relative 'history'
require_relative 'options'

module Churn

  # The work horse of the the churn library.
  # This class takes user input, determines the SCM the user is using.
  # It then determines changes made during this revision.
  # Finally it reads all the changes from previous revisions and displays human
  # readable output on the command line.
  # It can also output a yaml format readable by other tools such as metric_fu
  # and Caliper.
  class ChurnCalculator

    # intialize the churn calculator object
    def initialize(options={})
      @churn_options = ChurnOptions.new.set_options(options)

      @minimum_churn_count = @churn_options.minimum_churn_count
      @ignores             = @churn_options.ignores
      @source_control      = SourceControl.set_source_control(@churn_options.start_date)

      @changes          = {}
      @revision_changes = {}
      @class_changes    = {}
      @method_changes   = {}
    end

    # prepares the data for the given project to be reported.
    # reads git/svn logs analyzes the output, generates a report and either
    # formats as a nice string or returns hash.
    # @param [Boolean] print to return the data, true for string or false for hash
    # @return [Object] returns either a pretty string or a hash representing the
    # churn of the project
    def report(print = true)
      if @churn_options.history
        generate_history
      else
        emit
        analyze
        print ? self.to_s : self.to_h
      end
    end

    # this method generates the past history of a churn project from first
    # commit to current running the report for oldest commits first so they
    # are built up correctly
    def generate_history
      history_starting_point = Chronic.parse(@churn_options.history)
      @source_control.generate_history(history_starting_point)
      "churn history complete, this has manipulated your source control system so please make sure you are back on HEAD where you expect to be"
    end

    # Emits various data from source control to be analyzed later...
    # Currently this is broken up like this as a throwback to metric_fu
    def emit
      @changes   = reject_ignored_files(reject_low_churn_files(parse_log_for_changes))
      @revisions = parse_log_for_revision_changes
    end

    # Analyze the source control data, filter, sort, and find more information
    # on the edited files
    def analyze
      @changes = sort_changes(@changes)
      @changes = filter_changes(@changes)
      @changes = @changes.map {|file_path, times_changed| {:file_path => file_path, :times_changed => times_changed }}

      calculate_revision_changes

      @method_changes = sort_changes(@method_changes)
      @method_changes = @method_changes.map {|method, times_changed| {'method' => method, 'times_changed' => times_changed }}
      @class_changes  = sort_changes(@class_changes)
      @class_changes  = @class_changes.map {|klass, times_changed| {'klass' => klass, 'times_changed' => times_changed }}
    end

    # collect all the data into a single hash data structure.
    def to_h
      hash                        = {:churn => {:changes => @changes}}
      hash[:churn][:class_churn]  = @class_changes
      hash[:churn][:method_churn] = @method_changes
      #detail the most recent changes made this revision
      first_revision         = @revisions.first
      first_revision_changes = @revision_changes[first_revision]
      if first_revision_changes
        changes = first_revision_changes
        hash[:churn][:changed_files]   = changes[:files]
        hash[:churn][:changed_classes] = changes[:classes]
        hash[:churn][:changed_methods] = changes[:methods]
      end
      # TODO crappy place to do this but save hash to revision file but
      # while entirely under metric_fu only choice
      ChurnHistory.store_revision_history(first_revision, hash, @churn_options.data_directory)
      hash
    end

    def to_s
      ChurnCalculator.to_s(to_h[:churn])
    end

    # Pretty print the data as a string for the user
    def self.to_s(hash)
      result = separator
      result +="* Revision Changes \n"
      result += separator
      result += display_array("Files", hash[:changed_files], :fields=>[:to_str], :headers=>{:to_str=>'file'})
      result += "\n"
      result += display_array("Classes", hash[:changed_classes])
      result += "\n"
      result += display_array("Methods", hash[:changed_methods]) + "\n"
      result += separator
      result +="* Project Churn \n"
      result += separator
      result += "\n"
      result += display_array("Files", hash[:changes])
      result += "\n"
      class_churn = collect_items(hash[:class_churn], 'klass')
      result += display_array("Classes", class_churn)
      result += "\n"
      method_churn = collect_items(hash[:method_churn], 'method')
      result += display_array("Methods", method_churn)
    end

    private

    def self.collect_items(collection, match)
      return [] unless collection
      collection.map {|item| (item.delete(match) || {}).merge(item) }
    end

    def sort_changes(changes)
      changes.to_a.sort! {|first,second| second[1] <=> first[1]}
    end

    def filter_changes(changes)
      if @churn_options.file_extension && !@churn_options.file_extension.empty?
        changes = changes.select { |file_path, _revision_count| file_path =~ /\.#{@churn_options.file_extension}\z/ }
      end

      if @churn_options.file_prefix && !@churn_options.file_prefix.empty?
        changes = changes.select { |file_path, _revision_count| file_path =~ /\A#{@churn_options.file_prefix}/ }
      end

      changes
    end

    def filters
      /.*\.rb/
    end

    def self.display_array(title, array, options={})
      response = ''
      if array && array.length > 0
        response = "#{title}\n"
        response << Hirb::Helpers::AutoTable.render(array, options.merge(:description=>false)) + "\n"
      end
      response
    end

    def self.separator
      "*"*70+"\n"
    end

    def calculate_revision_changes
      @revisions.each do |revision|
        if revision == @revisions.first
          #can't iterate through all the changes and tally them up
          #it only has the current files not the files at the time of the revision
          #parsing requires the files
          changed_files, changed_classes, changed_methods = calculate_revision_data(revision)
        else
          changed_files, changed_classes, changed_methods = ChurnHistory.load_revision_data(revision, @churn_options.data_directory)
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
        if file_changes.first =~ filters
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
    rescue
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
      changes = Hash.new(0)

      logs = @source_control.get_logs
      logs.each do |line|
        changes[line] += 1
      end
      changes
    end

    def parse_log_for_revision_changes
      @source_control.get_revisions
    end

    def parse_logs_for_updated_files(revision, revisions)
      files = @source_control.get_updated_files_change_info(revision, revisions)
      reject_ignored_files(files)
    end

    def reject_low_churn_files(files)
      files.reject{ |_, change_count| change_count < @minimum_churn_count }
    end

    def reject_ignored_files(files)
      files.reject{ |file, _| @ignores.any?{ |ignore| /#{ignore}/ =~ file } }
    end

  end

end
