require 'rubygems'
require 'rufus/tokyo/tyrant'
require 'json'
require 'yaml'
require 'open-uri'
require 'timeout'

$:.unshift(File.dirname(__FILE__))

require 'postalcoder/config'
require 'postalcoder/formats'
require 'postalcoder/geocoding_api'
require 'postalcoder/persistence'
require 'postalcoder/resolver'


module PostalCoder

  module Errors
    class Error < StandardError; end
    class MalformedPostalCodeError < Error; end
    class BlankQueryError < Error; end
    class QueryTimeoutError < Error; end
    class NoAPIKeyError < Error; end
    class APIMalformedRequestError < Error; end
    class APIGeocodingError < Error; end
    class TTUnableToConnectError < Error; end
    class InvalidStorageValueError < Error; end
    class UnknownFormatSymbolError < Error; end
  end


  module ProxyMethods
    def PostalCoder.config=(hsh)
      Config.update(hsh)
    end

    def PostalCoder.connect(options = {})
      Resolver.new(options)
    end
  end

end
