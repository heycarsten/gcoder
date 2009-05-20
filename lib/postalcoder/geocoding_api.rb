module PostalCoder
  module GeocodingAPI

    BASE_URI = 'http://maps.google.com/maps/geo'
    BASE_PARAMS = {
      :q => nil,
      :output => 'json',
      :oe => 'utf8',
      :sensor => 'false',
      :key => nil }


    class Query

      attr_reader :query

      def self.get(query, options = {})
        new(query, options).to_hash
      end

      def initialize(query, options = {})
        unless query.is_a?(String)
          raise ArgumentError, "query must be a String, not: #{query.class}"
        end
        @config = Config.merge(options)
        @query = query
        validate_state!
      end

      def to_hash
        return tidy_response if @response
        parse_json_response(http_get)
      end

      def params
        BASE_PARAMS.merge(:key => @config[:gmaps_api_key], :q => query)
      end

      def to_params
        # No need to escape the keys and values because (so far) they do not
        # contain escapable characters. -- CKN
        params.inject([]) { |a, (k, v)| a << "#{k}=#{v}" }.join('&')
      end

      def uri
        [BASE_URI, '?', to_params].join
      end

      protected

      def placemark
        @response['Placemark'][0]
      end

      def latlon_box
        placemark['ExtendedData']['LatLonBox']
      end

      def country
        placemark['AddressDetails']['Country']
      end

      def tidy_response
        { :accuracy => placemark['AddressDetails']['Accuracy'],
          :country => {
            :name => country['CountryName'],
            :code => country['CountryNameCode'],
            :administrative_area => country['AdministrativeArea']['AdministrativeAreaName']
          },
          :point => {
            :latitude => placemark['Point']['coordinates'][0],
            :longitude => placemark['Point']['coordinates'][1]
          },
          :box => {
            :north => latlon_box['north'],
            :south => latlon_box['south'],
            :east => latlon_box['east'],
            :west => latlon_box['west']
        } }
      end

      def http_get
        return @json_response if @json_response
        Timeout.timeout(@config[:gmaps_api_timeout]) do
          @json_response = open(uri).read
        end
      rescue Timeout::TimeoutError
        raise Errors::QueryTimeoutError, 'The query timed out at ' \
        "#{@config[:timeout]} second(s)"
      end

      def parse_json_response(json_response)
        @response = JSON.parse(json_response)
        case @response['Status']['code']
        when 200
          tidy_response
        when 400
          raise Errors::APIMalformedRequestError, 'The GMaps Geo API has ' \
          'indicated that the request is not formed correctly: ' \
          "(#{query.inspect})"
        when 602
          raise Errors::APIGeocodingError, 'The GMaps Geo API has indicated ' \
          "that it is not able to geocode the request: (#{query.inspect})"
        end
      end

      def validate_state!
        if '' == query.strip.to_s
          raise Errors::BlankQueryError, 'You must specifiy a query to resolve.'
        end
        unless @config[:gmaps_api_key]
          raise Errors::NoAPIKeyError, 'You must provide a Google Maps API ' \
          'key in your configuration. Go to http://code.google.com/apis/maps/' \
          'signup.html to get one.'
        end
      end

    end

  end
end