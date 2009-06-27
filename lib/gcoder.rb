require 'rubygems'
require 'rufus/tokyo/tyrant'
require 'json'
require 'yaml'
require 'open-uri'
require 'timeout'

$:.unshift(File.dirname(__FILE__))

require 'gcoder/config'
require 'gcoder/geocoding_api'
require 'gcoder/persistence'
require 'gcoder/resolver'


module GCoder

  module Errors
    class Error < StandardError; end
    class MalformedQueryError < Error; end
    class BlankRequestError < Error; end
    class RequestTimeoutError < Error; end
    class NoAPIKeyError < Error; end
    class APIMalformedRequestError < Error; end
    class APIGeocodingError < Error; end
    class TTUnableToConnectError < Error; end
    class InvalidStorageValueError < Error; end
    class UnknownFormatSymbolError < Error; end
  end


  module ProxyMethods
    def GCoder.config=(hsh)
      Config.update(hsh)
    end

    def GCoder.connect(options = {})
      Resolver.new(options)
    end
  end

end
