module Churn
  
  class LocationMapping < SexpProcessor
    
    attr_reader :klasses_collection, :methods_collection
    
    def initialize()
      super
      @klasses_collection  = {}
      @methods_collection  = {}
      @parser              = RubyParser.new
      self.auto_shift_type = true
    end
    
    def get_info(file)
      ast = @parser.process(File.read(file), file)
      process ast
    end
    
    def process_class(exp)
      name           = exp.shift
      start_line     = exp.line
      last_line      = exp.last.line
      name           = name if name.is_a?(Symbol)
      name           = name.values.value if name.is_a?(Sexp) #deals with cases like class Test::Unit::TestCase
      @current_class = name
      @klasses_collection[name.to_s] = [] unless @klasses_collection.include?(name)
      @klasses_collection[name.to_s] << (start_line..last_line)
      analyze_list exp
      s()
    end
    
    def analyze_list exp
      process exp.shift until exp.empty?
    end
    
    def process_defn(exp)
      name        = exp.shift
      start_line  = exp.line
      last_line   = exp.last.line
      full_name   = "#{@current_class}##{name}"
      @methods_collection[full_name] = [] unless @methods_collection.include?(full_name)
      @methods_collection[full_name] << (start_line..last_line)
      return s(:defn, name, process(exp.shift), process(exp.shift))
    end

  end

end
