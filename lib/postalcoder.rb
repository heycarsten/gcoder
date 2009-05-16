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


module PostalCoder
  module ProxyMethods

    def PostalCoder.config=(hsh)
      Config.update!(hsh)
    end

    def PostalCoder.connect(options = {})
      DB.new(tdb_file)
    end

  end
end
