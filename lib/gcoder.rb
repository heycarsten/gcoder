require 'redis'
require 'json'
require 'open-uri'
require 'timeout'

$:.unshift(File.dirname(__FILE__))

require 'gcoder/version'
require 'gcoder/geocoder'
require 'gcoder/adapters'
require 'gcoder/resolver'

module GCoder
  class GeocoderError < StandardError; end
  class NotImplementedError < StandardError; end
  class TimeoutError < StandardError; end

  DEFAULT_CONFIG = {
    :api_key      => nil,
    :timeout      => 2,
    :append       => nil,
    :country      => nil,
    :adapter      => :heap,
    :adapter_opts => nil
  }.freeze

  def self.config
    @config ||= DEFAULT_CONFIG.dup
  end

  def self.connect(options = {})
    Resolver.new(options)
  end
end
