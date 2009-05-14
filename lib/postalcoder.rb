module PostalCoder

  require 'rubygems'
  require 'rufus/tokyo'
  require 'json'
  require 'openuri'
  require 'timeout'


  module ProxyMethods

    def PostalCoder.config=(hsh)
      Config.update(hsh)
    end

    def PostalCoder.connect!
      Resolver.new(tdb_file)
    end

  end


  module Config

    @settings = {
      :gmaps_api_key => nil,
      :timeout => 2,
      :tdb_file => nil }

    def self.update(hsh)
      @settings.update(hsh)
    end

    def self.[](key)
      @settings[key]
    end

  end


  module DB

    include Persistence::Cacheable

    def initialize(options = {})
      setup = {
        :accepted_formats => [Formats::CAPostalCode, Formats::USZipCode]
      }.update(options)
    end

  end


  module Formats

    class Error < StandardError; end
    class MalformedPostalCodeError < Error; end


    module PostalCodeable

      def initialize(raw_value)
        @value = cleanup(raw_value)
        check_form!
      end

      def cleanup(raw_value)
        raw_value.strip
      end

      def form_check
        raise NotImplementedError, '#form_check must be implemented'
      end

      def to_s
        @value
      end

      def check_form!
        return true if form_check
        raise MalformedPostalCodeError, "#{value.inspect} is not a properly " \
        "formed #{self.class}"
      end

    end


    class CAPostalCode

      include PostalCodeable

      def cleanup(raw_value)
        unless raw_value.is_a?(String)
          raise ArgumentError, "value must be String, not: #{raw_value.class}"
        end
        raw_value.upcase.gsub(/\s/, '')
      end

      def form_check
        value.to_s =~ /\A[A-Z][0-9]{3}\Z/
      end

    end


    class USZipCode

      include PostalCodeable

      def cleanup(raw_value)
        unless raw_value.is_a?(String) || raw_value.is_a?(Integer)
          raise ArgumentError, 'value must be String or Integer, not: ' +
          raw_value.class.to_s
        end
        raw_value.to_s.gsub(/\s/, '')
      end

      def form_check
        value.to_s =~ /\A(\d{5})\Z|\A(\d{5}-\d{4})\Z/
      end

    end

  end


  module Persistence

    class Error < StandardError; end
    class NoDatabaseFileError < Error; end
    class InvalidStorageValueError < Error; end


    module Cacheable

      def fetch(key, &block)
        value = tc_tdb_connection[key]
        return value if value
        tc_tdb_connection[key] = &block.call(key)
      end

      private

      def tc_tdb_connection
        @tc_tdb_connection ||
          raise NotImplementedError, "Cacheable expects #{self.class} to " \
          'implement @tc_tdb_connection'
      end

    end


    class DataStore

      def initialize(tdb_file = nil)
        if !tdb_file && !Config[:tdb_file]
          raise ArgumentError, 'tdb_file must be specified when it is not ' \
          'present in the global configuration'
        else
          self.filepath = (tdb_file || Config[:tdb_file])
        end
        @writer = Rufus::Tokyo::Table.new(filepath, :mode => write_mode_flags)
        @reader = Rufus::Tokyo::Table.new(filepath, :mode => 'r')
      end

      def [](key)
        @reader[key.to_s]
      end

      def []=(key, value)
        unless key.is_a?(String) || key.is_a?(Symbol)
          raise ArgumentError, "key must be String or Symbol, not: #{key.class}"
        end
        unless value.is_a?(Hash)
          raise ArgumentError, "value must be Hash, not: #{value.class}"
        end
        @writer[key.to_s] = prepare_hash_for_storage(value)
      end

      protected

      def prepare_hash_for_storage(hsh)
        unless hsh.keys.all? { |k| k.is_a?(Symbol) || k.is_a?(String) }
          raise InvalidStorageValueError, 'Storage value keys must all be ' \
          'Strings or Symbols'
        end
        unless value.values.all? { |v| v.is_a?(String) || v.is_a?(Numeric) ||
        v.is_a?(Symbol) }
          raise ArgumentError, 'value hash values must all be Strings, ' \
          'Numbers or Symbols'
        end
        hsh.inject({}) { |h,(k,v)| h.merge(k.to_s => v.to_s) }
      end

      def write_mode_flags
        File.exists?(filepath) ? 'w' : 'wc'
      end

      def reader
        @reader
      end

      def writer
        @writer
      end

      def filepath=(value)
        if '' == value.to_s
          raise NoDatabaseFileError, 'No Tokyo Cabinet TDB file is specified ' \
          'in the configuration'
        end
        @filepath = (('.tdb' == File.extname(value)) ? value : "#{value}.tdb")
      end

      def filepath
        @filepath
      end

    end

  end


  module GeocodingAPI

    BASE_URI = 'http://maps.google.com/maps/geo'
    BASE_PARAMS = {
      :q => 'postal_code',
      :output => 'json',
      :oe => 'utf8',
      :sensor => 'false',
      :key => 'google_maps_api_key' }

    class Error < StandardError; end
    class BlankQueryError < Error; end
    class QueryTimeoutError < Error; end
    class NoAPIKeyError < Error; end


    class Query

      attr_reader :query

      def self.get(query)
        new(query).to_hash
      end

      def initialize(query)
        @query = query
        verify_integrity!
      end

      def get
        Timeout.timeout(Config[:timeout]) do
          open(to_uri).read
        end
      rescue Timeout::TimeoutError
        raise QueryTimeoutError, "The query timed out at #{Config[:timeout]} " \
          'second(s)'
      end

      def to_hash
        JSON.parse(get)
      end

      def params
        BASE_PARAMS.merge(:key => Config[:gmaps_api_key], :q => query)
      end

      def to_params
        # No need to escape the keys and values because in our case because they
        # will not contain escapable characters. -- CKN
        params.inject([]) { |a, (k, v)| a << "#{k}=#{v}" }.join('&')
      end

      def to_uri
        [BASE_URI, '?', to_params].join
      end

      protected

      def validate_query!
        if '' == query.to_s
          raise BlankQueryError, 'You must specifiy a query to resolve.'
        end
        unless Config[:gmaps_api_key]
          raise NoAPIKeyError, 'You must provide a Google Maps API key in ' \
            'your configuration! Go to http://code.google.com/apis/maps/si' \
            'gnup.html to get one.'
        end
      end

    end

  end


end
