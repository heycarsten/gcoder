module PostalCoder

  require 'rubygems'
  require 'rufus/tokyo'
  require 'json'
  require 'openuri'


  GMAPSGEO_BASE_URI = 'http://maps.google.com/maps/geo'
  GMAPSGEO_BASE_PARAMS = {
    :q => 'postal_code',
    :output => 'json',
    :oe => 'utf8',
    :sensor => false,
    :key => 'google_maps_api_key' }

  def self.connect(tokyo_cabinet_hdb_file)
    Resolver.new(tokyo_cabinet_hdb_file)
  end

  def self.config=(hsh)
    Config.update(hsh)
  end


  module Config

    @settings = { :google_api_key => nil }

    def self.update(hsh)
      @settings.update(hsh)
    end

    def self.[](key)
      @settings[key]
    end

  end


  class Resolver

    def initialize()
    end

    private

    def get_json(query)
      open(build_uri(query)).read
    end

    def json_to_ruby(json)
      JSON.parse(json)
    end

    def build_params(query)
      GMAPSGEO_BASE_PARAMS.merge(:key => Config[:google_api_key], :q => query)
    end

    def build_query_string(query)
      build_params(query).inject([]) { |a, (k ,v)| a << "#{k}=#{v}" }.join('&')
    end

    def build_uri(query)
      [GMAPSGEO_BASE_URI, '?', build_query_string(query)].join
    end

  end


  class PostalCode
  
    def intialize(postal_code)
      @postal_code = postal_code
      clean_postal_code!
    end
  
    protected
    
    def clean_postal_code!
      
    end
  
  end


end