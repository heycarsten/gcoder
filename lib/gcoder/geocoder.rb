module GCoder
  module Geocoder

    BASE_URI = 'http://maps.google.com/maps/geo'
    BASE_PARAMS = {
      :q => nil,
      :output => 'json',
      :oe => 'utf8',
      :sensor => 'false',
      :key => nil }

    def self.get(query, options = {})
      response = new(query, options).get
      response.validate!
      response.to_h
    end

    class Request
      def initialize(query, options = {})
        unless query
          raise Errors::BlankRequestError, "query cannot be nil"
        end
        unless query.is_a?(String)
          raise Errors::MalformedQueryError, "query must be String, not: #{query.class}"
        end
        @config = GCoder.config.merge(options)
        @query = query
        validate_state!
      end

      def params
        BASE_PARAMS.dup.tap do |p|
          p[:key] = @config[:api_key]
          p[:q]   = query
          p[:gl]  = @config[:country] if @config[:country]
          p
        end
      end

      def to_params
        @to_params ||= begin
          params.map { |k, v| "#{uri_escape(k)}=#{uri_escape(v)}" }.join('&')
        end
      end

      def query
        @config[:append] ? "#{@query} #{@config[:append]}" : @query
      end

      def uri
        [BASE_URI, '?', to_params].join
      end

      def get
        return @json_response if @json_response
        Timeout.timeout(@config[:timeout]) do
          Response.new(self)
        end
      rescue Timeout::Error
        raise TimeoutError, "Query timeout after #{@config[:timeout]} second(s)"
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
          raise Errors::GeocoderError, 'You must specifiy a query to resolve.'
        end
        unless @config[:api_key]
          raise Errors::GeocoderError, 'You must provide a Google Maps API ' \
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
          raise GeocoderError, 'The GMaps Geo API has ' \
          'indicated that the request is not formed correctly: ' \
          "(#{@request.uri})\n\n#{@request.inspect}"
        when 602
          raise GeocoderError, 'The GMaps Geo API has indicated ' \
          "that it is not able to geocode the request: (#{@request.uri})" \
          "\n\n#{@request.inspect}"
        end
      end

      def to_hash
        { :accuracy => accuracy,
          :country => {
            :name => country_name,
            :code => country_code,
            :administrative_area => administrative_area_name },
          :point => {
            :longitude => longitude,
            :latitude => latitude },
          :box => box }
      end

      def as_json
        JSON.dump(to_hash)
      end

      def box
        { :north => latlon_box['north'],
          :south => latlon_box['south'],
          :east => latlon_box['east'],
          :west => latlon_box['west'] }
      end

      def accuracy
        address_details['Accuracy']
      end

      def latitude
        coordinates[1]
      end

      def longitude
        coordinates[0]
      end

      def country_name
        country['CountryName']
      end

      def country_code
        country['CountryNameCode']
      end

      def administrative_area_name
        administrative_area['AdministrativeAreaName']
      end

      private

      def coordinates
        point['coordinates'] || []
      end

      def point
        placemark['Point'] || {}
      end

      def country
        address_details['Country'] || {}
      end

      def administrative_area
        country['AdministrativeArea'] || {}
      end

      def address_details
        placemark['AddressDetails'] || {}
      end

      def latlon_box
        extended_data['LatLonBox'] || {}
      end

      def extended_data
        placemark['ExtendedData'] || {}
      end

      def placemark
        (p = @response['Placemark']) ? p[0] : {}
      end

    end


  end
end