module GCoder
  module GeocodingAPI

    BASE_URI = 'http://maps.google.com/maps/geo'
    BASE_PARAMS = {
      :q => nil,
      :output => 'json',
      :oe => 'utf8',
      :sensor => 'false',
      :key => nil }


    class Request

      def self.get(query, options = {})
        response = new(query, options).get
        response.validate!
        response.to_h
      end

      def initialize(query, options = {})
        unless query
          raise Errors::BlankRequestError, "query cannot be nil"
        end
        unless query.is_a?(String)
          raise Errors::MalformedQueryError, "query must be String, not: #{query.class}"
        end
        @config = Config.merge(options)
        @query = query
        validate_state!
      end

      def params
        BASE_PARAMS.merge(:key => @config[:gmaps_api_key], :q => query)
      end

      def to_params
        params.inject([]) do |array, (key, value)|
          array << "#{uri_escape key}=#{uri_escape value}"
        end.join('&')
      end

      def query
        @config[:append_query] ? "#{@query} #{@config[:append_query]}" : @query
      end

      def uri
        [BASE_URI, '?', to_params].join
      end

      def get
        return @json_response if @json_response
        Timeout.timeout(@config[:gmaps_api_timeout]) do
          Response.new(self)
        end
      rescue Timeout::Error
        raise Errors::RequestTimeoutError, 'The query timed out at ' \
        "#{@config[:timeout]} second(s)"
      end

      def http_get
        open(uri).read
      end

      protected

      # Snaked from Rack::Utils which 'stole' it from Camping.
      def uri_escape(string)
        string.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) do
          '%' + $1.unpack('H2' * $1.size).join('%').upcase
        end.tr(' ', '+')
      end

      def validate_state!
        if '' == query.strip.to_s
          raise Errors::BlankRequestError, 'You must specifiy a query to resolve.'
        end
        unless @config[:gmaps_api_key]
          raise Errors::NoAPIKeyError, 'You must provide a Google Maps API ' \
          'key in your configuration. Go to http://code.google.com/apis/maps/' \
          'signup.html to get one.'
        end
      end

    end


    class Response

      def initialize(request)
        @request = request
        @response = JSON.parse(@request.http_get)
      end

      def status
        @response['Status']['code']
      end

      def validate!
        case status
        when 400
          raise Errors::APIMalformedRequestError, 'The GMaps Geo API has ' \
          'indicated that the request is not formed correctly: ' \
          "(#{@request.uri})\n\n#{@request.inspect}"
        when 602
          raise Errors::APIGeocodingError, 'The GMaps Geo API has indicated ' \
          "that it is not able to geocode the request: (#{@request.uri})" \
          "\n\n#{@request.inspect}"
        end
      end

      def to_h
        { :accuracy => accuracy,
          :country => {
            :name => country_name,
            :code => country_code,
            :administrative_area => administrative_area },
          :point => {
            :longitude => longitude,
            :latitude => latitude },
          :box => box }
      end

      def box
        { :north => placemark['ExtendedData']['LatLonBox']['north'],
          :south => placemark['ExtendedData']['LatLonBox']['south'],
          :east => placemark['ExtendedData']['LatLonBox']['east'],
          :west => placemark['ExtendedData']['LatLonBox']['west'] }
      end

      def accuracy
        placemark['AddressDetails']['Accuracy']
      end

      def latitude
        placemark['Point']['coordinates'][1]
      end

      def longitude
        placemark['Point']['coordinates'][0]
      end

      def latlon_box
        placemark['ExtendedData']['LatLonBox']
      end

      def country_name
        placemark['AddressDetails']['Country']['CountryName']
      end

      def country_code
        placemark['AddressDetails']['Country']['CountryNameCode']
      end

      def administrative_area
        placemark['AddressDetails']['Country']['AdministrativeArea']['AdministrativeAreaName']
      end

      private

      def placemark
        @response['Placemark'][0]
      end

    end


  end
end