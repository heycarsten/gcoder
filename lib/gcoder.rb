require 'yajl'
require 'hashie'
require 'net/http'
require 'cgi'
require 'base64'
require 'timeout'
require 'digest/sha1'
require 'hmac'
require 'hmac-sha1'

$:.unshift(File.dirname(__FILE__))

require 'gcoder/version'
require 'gcoder/geocoder'
require 'gcoder/storage'
require 'gcoder/resolver'

module GCoder
  class NoResultsError < StandardError; end
  class OverLimitError < StandardError; end
  class GeocoderError < StandardError; end
  class BadQueryError < StandardError; end
  class NotImplementedError < StandardError; end
  class TimeoutError < StandardError; end

  DEFAULT_CONFIG = {
    :timeout        => 5,
    :append         => nil,
    :region         => nil,
    :bounds         => nil,
    :client         => nil,
    :key            => nil,
    :storage        => nil,
    :storage_config => nil
  }.freeze

  def self.config
    @config ||= DEFAULT_CONFIG.dup
  end

  def self.connect(options = {})
    Resolver.new(options)
  end
end
