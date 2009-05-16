require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))
require 'postalcoder'

class Test::Unit::TestCase
end
