require 'json'

require_relative 'calculator'
require_relative 'version'

module Churn

  # The reporter of churn results. Knows how to report churn
  # in different formats:
  #
  # - Console (stdout)
  # - YAML
  # - JSON
  class ChurnReporter
    attr_accessor :calculator, :options, :params

    def initialize(_params)
      self.params = _params
      self.options = {
        minimum_churn_count: params['minimum_churn_count'].value,
        ignore_files: params['ignore_files'].value,
        start_date: params['start_date'].value,
        data_directory: params['data_directory'].value,
        history: params['past_history'].value,
        report: params['report'].value,
        name: params['name'].value,
        file_extension: params['extension'].value,
        file_prefix: params['prefix'].value,
        json: params['json'].value,
        yaml: params['yaml'].value,
      }
      self.calculator = Churn::ChurnCalculator.new(options)
    end

    # Knows how to return a churn result in different formats.
    #
    # @return [String]
    def report_churn
      print_output = !options[:json] && !options[:yaml]

      if params['version'].value
        puts Churn::VERSION
        return
      end

      result = calculator.report(print_output)

      if options[:json]
        JSON::dump(result)
      elsif options[:yaml]
        YAML::dump(result)
      else
        result
      end
    end
  end
end
