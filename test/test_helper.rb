require 'rubygems'
require 'simplecov'
require 'minitest/autorun'
#require 'shoulda'
require 'test_construct'
require 'mocha/minitest'

SimpleCov.start do
  add_filter 'specs/ruby/1.9.1/gems/'
  add_filter '/test/'
  add_filter '/config/'
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'churn/calculator'

class Minitest::Test
  include TestConstruct::Helpers
end

# shoulda style test names
def test(name, &block)
  test_name = "test_#{name.gsub(/\s+/, "_")}".to_sym
  defined = begin
              instance_method(test_name)
            rescue
              false
            end
  raise "#{test_name} is already defined in #{self}" if defined

  if block_given?
    define_method(test_name, &block)
  else
    define_method(test_name) do
      flunk "No implementation provided for #{name}"
    end
  end
end

alias :should :test
