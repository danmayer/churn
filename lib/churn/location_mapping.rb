module Churn

  # Given a ruby file, map the klass and methods to a range of line numbers
  # The klass and method to line numbers mappings, are stored in
  # @klasses_collection and @methods_collection
  # this is based off https://github.com/seattlerb/ruby_parser which seems to have some known line number bugs
  # perhaps look at and move more to the style of line numbers from metric_fu
  # https://github.com/metricfu/metric_fu/blob/master/lib/data_structures/line_numbers.rb
  class LocationMapping < SexpProcessor

    attr_reader :klasses_collection, :methods_collection

    def initialize()
      super
      @klasses_collection  = {}
      @methods_collection  = {}
      @parser              = RubyParser.new
      self.auto_shift_type = true
      self.require_empty = false
    end

    def get_info(file)
      ast = @parser.process(File.read(file), file)
      process ast
    end

    def process_class(exp)
      name           = exp.shift
      start_line     = exp.line
      last_line      = deep_last_line(exp)
      name           = name if name.is_a?(Symbol)
      name           = name.values.value if name.is_a?(Sexp) #deals with cases like class Test::Unit::TestCase
      @current_class = name
      @klasses_collection[name.to_s] = [] unless @klasses_collection.include?(name)
      @klasses_collection[name.to_s] << (start_line..last_line)
      analyze_list exp
      s()
    end

    def deep_last_line(exp)
      lines = []
      exp.deep_each{|x| lines << x.line }
      lines.max + 1
    end

    def analyze_list exp
      process exp.shift until exp.empty?
      exp
    end

    def process_defn(exp)
      name        = exp.shift
      start_line  = exp.line
      last_line   = deep_last_line(exp)
      full_name   = "#{@current_class}##{name}"
      @methods_collection[full_name] = [] unless @methods_collection.include?(full_name)
      @methods_collection[full_name] << (start_line..last_line)
      return s(:defn, name, process(exp.shift), process(exp.shift))
    end

  end

end
