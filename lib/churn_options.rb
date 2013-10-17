require 'singleton'

module Churn
  
  # responsible for storing the churn configuration
  class ChurnOptions
    include Singleton 
    DEFAULT_CHURN_DIRECTORY = "tmp/churn"
    DEFAULT_MINIMUM_CHURN_COUNT = 5
    DEFAULT_START_TIME = '3 months ago'
    DEFAULT_REPORT_HOST = 'http://churn.picoappz.com'

    attr_accessor :data_directory, :minimum_churn_count, :ignore_files, :start_date, :history, :report_host, :name
    
    def initialize()
      @data_directory      = DEFAULT_CHURN_DIRECTORY
      @minimum_churn_count = DEFAULT_MINIMUM_CHURN_COUNT
      @ignore_files        = ['/dev/null']
      @start_date          = DEFAULT_START_TIME
      @history             = nil
      @report_host         = nil
      @name                = nil
    end

    def set_options(options = {})
      @data_directory      = options.fetch(:data_directory){ @data_directory } unless options[:data_directory]==''
      @minimum_churn_count = options.fetch(:minimum_churn_count){ @minimum_churn_count }.to_i
      @ignore_files        = (options.fetch(:ignore_files){ @ignore_files }).to_s.split(',').map(&:strip)
      @ignore_files << '/dev/null' unless @ignore_files.include?('/dev/null')
      @start_date          = options[:start_date] if !options[:start_date].nil? && options[:start_date]!=''
      @history             = options[:history] if !options[:history].nil? && options[:history]!=''
      if @history=='true'
        @history = DEFAULT_START_TIME
      end
      if !options[:report].nil? && options[:report]!='' 
        @report_host         = options[:report]
        if @report_host=='true'
          @report_host = DEFAULT_REPORT_HOST
        end
      end

      @name = options[:name] if !options[:name].nil? && options[:name]!=''
      if !@report_host.nil? && @name.nil?
        raise ArgumentError.new "If you are reporting churn results you must pass a valid github project name in the form of username/project_name"
      end

      self
    end
        
  end

end
