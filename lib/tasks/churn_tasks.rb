def report_churn()
  require File.join(File.dirname(__FILE__), '..', 'churn', 'churn_calculator')
  Churn::ChurnCalculator.new({:minimum_churn_count => 3}).report
end

desc "Report the current churn for the project"
task :churn do
  report = report_churn()
  puts "entire report"
  puts report.inspect.to_s
  puts "_"*50
  puts "changed classes: #{report[:churn][:changed_classes].inspect}"
  puts "_"*50
  puts "cahnged methods: #{report[:churn][:changed_methods].inspect}"
  puts "_"*50
  puts "method churn: #{report[:churn][:method_churn].inspect}"
end

