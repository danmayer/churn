def report_churn()
  require File.join(File.dirname(__FILE__), '..', 'churn', 'churn_calculator')
  puts Churn::ChurnCalculator.new({}).report.inspect.to_s
end

desc "Report the current churn for the project"
task :churn do
  report_churn()
end

