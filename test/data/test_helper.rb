require 'rubygems'
require 'minitest/autorun'
require 'shoulda'
require 'test_construct'
require 'mocha/minitest'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'churn/churn_calculator'
Mocha::Configuration.prevent(:stubbing_non_existent_method)

class Minitest::Test
  include TestConstruct::Helpers
end
