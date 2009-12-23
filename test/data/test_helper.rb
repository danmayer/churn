require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'construct'
require 'mocha'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'churn/churn_calculator'
Mocha::Configuration.prevent(:stubbing_non_existent_method)

class Test::Unit::TestCase
  include Construct::Helpers
end
