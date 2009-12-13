def report_churn()
  require File.join(File.dirname(__FILE__), '..', 'churn', 'churn_calculator')
  Churn::ChurnCalculator.new({:minimum_churn_count => 3}).report
end

desc "Report the current churn for the project"
task :churn do
  report = report_churn()
  puts report.inspect.to_s
  puts "classes: #{hash[:churn][:changed_classes].inspect}"
  puts "methods: #{hash[:churn][:changed_methods].inspect}"
  puts "method churn: #{hash[:churn][:method_churn].inspect}"
end

