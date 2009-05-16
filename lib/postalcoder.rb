require 'rubygems'
require 'rufus/tokyo'
require 'json'
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
    class NoDatabaseFileError < Error; end
    class InvalidStorageValueError < Error; end
    class UnknownFormatSymbolError < Error; end
  end


  module ProxyMethods
    def PostalCoder.config=(hsh)
      Config.update!(hsh)
    end

    def PostalCoder.connect(options = {})
      DB.new(tdb_file)
    end
  end

end
