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
  class Error < StandardError; end
  class NoResultsError < Error; end
  class OverLimitError < Error; end
  class GeocoderError < Error; end
  class BadQueryError < Error; end
  class NotImplementedError < Error; end
  class TimeoutError < Error; end

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
