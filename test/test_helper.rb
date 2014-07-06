require 'rubygems'
require 'simplecov'
require 'minitest/autorun'
require 'shoulda'
require 'test_construct'
require 'mocha/mini_test'

SimpleCov.start do
  add_filter 'specs/ruby/1.9.1/gems/'
  add_filter '/test/'
  add_filter '/config/'
end

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'churn/calculator'
Mocha::Configuration.prevent(:stubbing_non_existent_method)

class Minitest::Test
  include TestConstruct::Helpers
end
