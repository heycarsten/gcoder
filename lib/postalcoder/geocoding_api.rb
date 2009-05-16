module PostalCoder
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
        Timeout.timeout(Config[:gmaps_api_timeout]) do
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
        # No need to escape the keys and values because (so far) they do not
        # contain escapable characters. -- CKN
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