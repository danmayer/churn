require 'singleton'

module Churn

  # responsible for storing the churn configuration
  class ChurnOptions
    DEFAULT_CHURN_DIRECTORY = "tmp/churn"
    DEFAULT_MINIMUM_CHURN_COUNT = 5
    DEFAULT_START_TIME = '3 months ago'

    attr_accessor :data_directory, :minimum_churn_count, :ignores, :start_date, :history, :name, :file_extension, :file_prefix

    def initialize()
      @data_directory      = DEFAULT_CHURN_DIRECTORY
      @minimum_churn_count = DEFAULT_MINIMUM_CHURN_COUNT
      @ignores             = '/dev/null'
      @start_date          = DEFAULT_START_TIME
      @history             = nil
      @name                = nil
      @file_extension      = nil
      @file_prefix         = nil
    end

    def set_options(options = {})
      @data_directory      = options.fetch(:data_directory){ @data_directory } unless options[:data_directory]==''
      @file_extension      = options.fetch(:file_extension){ @file_extension } unless options[:file_extension]==''
      @file_prefix      = options.fetch(:file_prefix){ @file_prefix } unless options[:file_prefix]==''
      @minimum_churn_count = options.fetch(:minimum_churn_count){ @minimum_churn_count }.to_i
      @ignores             = (options.fetch(:ignore_files){ options[:ignores] || @ignores }).to_s.split(',').map(&:strip)
      @ignores << '/dev/null' unless @ignores.include?('/dev/null')
      @start_date          = options[:start_date] if !options[:start_date].nil? && options[:start_date]!=''
      @history             = options[:history] if !options[:history].nil? && options[:history]!=''
      if @history=='true'
        @history = DEFAULT_START_TIME
      end

      self
    end

  end

end
