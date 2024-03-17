require 'minitest/autorun'
require_relative '../../lib/churn/reporter'

class ChurnReporterTest < Minitest::Test
  StructOption = Struct.new(:value)

  def setup
    @params = {
      'minimum_churn_count' => StructOption.new(3),
      'ignore_files' => StructOption.new('file.rb'),
      'start_date' => StructOption.new('2022-01-01'),
      'data_directory' => StructOption.new('/data'),
      'past_history' => StructOption.new(true),
      'report' => StructOption.new('summary'),
      'name' => StructOption.new('churn_report'),
      'extension' => StructOption.new('.rb'),
      'prefix' => StructOption.new('churn_'),
      'json' => StructOption.new(false),
      'yaml' => StructOption.new(false),
      'version' => StructOption.new(false)
    }
    churn_calculator = Churn::ChurnCalculator.new({:minimum_churn_count => 3})

    churn_calculator.stubs(:parse_log_for_changes).returns([['file.rb', 4],['less.rb',1]])
    churn_calculator.stubs(:parse_log_for_revision_changes).returns(['revision'])
    churn_calculator.stubs(:analyze)
    @churn_reporter = Churn::ChurnReporter.new(@params)
    @churn_reporter.calculator = churn_calculator
  end

  test "initialize sets the params as an instance variable" do
    assert_equal @params, @churn_reporter.params
  end

  test "report churn prints version when version param is true" do
    @params['version'].value = true

    expected_output = "#{Churn::VERSION}\n"

    assert_output(expected_output) { @churn_reporter.report_churn }
  end

  test "report churn returns result as json when json param is true" do
    @churn_reporter.options[:json] = true

    result = "{\"churn\":{\"changes\":[[\"file.rb\",4]],\"class_churn\":{},\"method_churn\":{}}}"

    assert_equal result, @churn_reporter.report_churn
  end

  test "report churn returns result as yaml when yaml param is true" do
    @churn_reporter.options[:yaml] = true

    result =<<~EOS
    ---
    :churn:
      :changes:
      - - file.rb
        - 4
      :class_churn: {}
      :method_churn: {}
    EOS

    assert_equal result, @churn_reporter.report_churn
  end

  test "report churn returns result when neither json nor yaml param is true" do
    output = @churn_reporter.report_churn

    assert_match /Revision Changes/, output
    assert_match /Project Churn/, output
  end
end