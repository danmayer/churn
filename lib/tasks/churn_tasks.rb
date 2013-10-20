if defined?(RakeFileUtils) # self.respond_to?(:desc)
  def report_churn()
    require File.join(File.dirname(__FILE__), '..', 'churn', 'calculator')
    options = {}
    { :minimum_churn_count => ENV['CHURN_MINIMUM_CHURN_COUNT'],
      :start_date          => ENV['CHURN_START_DATE'],
      :ignore_files        => ENV['CHURN_IGNORE_FILES'],
      :data_directory        => ENV['CHURN_DATA_DIRECTORY'],
    }.each {|k,v| options[k] = v unless v.nil? }
    Churn::ChurnCalculator.new(options).report
  end
  
  desc "Report the current churn for the project"
  task :churn do
    report = report_churn()
    puts report
  end
end
