def report_churn()
  require File.join(File.dirname(__FILE__), '..', 'churn', 'churn_calculator')
  Churn::ChurnCalculator.new({
                               :minimum_churn_count => ENV['CHURN_MINIMUM_CHURN_COUNT'],
                               :start_date => ENV['CHURN_START_DATE'],
                               :ignore_files => ENV['CHURN_IGNORE_FILES'],
                             }).report
end

desc "Report the current churn for the project"
task :churn do
  report = report_churn()
  puts report
end

