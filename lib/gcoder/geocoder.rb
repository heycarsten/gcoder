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
      Request.new(query, options).get.to_hash
    end

    module Utils
      # URI escape, snaked from Rack::Utils.
      def self.u(string)
        string.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
          '%' + $1.unpack('H2' * $1.size).join('%').upcase
        }.tr(' ', '+')
      end

      def self.to_params(hsh)
        hsh.map { |key, value| "#{u key}=#{u value}" }.join('&')
      end

      def self.bounds_to_q(bounds)
        bounds.map { |point| point.join(',') }.join('|')
      end
    end

    class Request
      def initialize(query, options = {})
        unless query
          raise GeocoderError, "query cannot be nil"
        end
        unless query.is_a?(String)
          raise GeocoderError, "query must be String, not: #{query.class}"
        end
        if '' == query.strip
          raise GeocoderError, 'You must specifiy a query to resolve.'
        end
        @config = GCoder.config.merge(options)
        @query = query
      end

      def self.stubs
        @stubs ||= {}
      end

      def self.stub(uri, body)
        stubs[uri] = body
      end

      def params
        BASE_PARAMS.dup.tap do |p|
          p[:key]    = @config[:api_key] if @config[:api_key]
          p[:q]      = query
          p[:region] = @config[:region] if @config[:region]
          p[:bounds] = Utils.bounds_to_q(@config[:bounds]) if @config[:bounds]
          p
        end
      end

      def to_params
        Utils.to_params(params)
      end

      def query
        @config[:append] ? "#{@query} #{@config[:append]}" : @query
      end

      def uri
        "#{BASE_URI}?#{to_params}"
      end

      def get
        Timeout.timeout(@config[:timeout]) do
          Response.new(uri, (self.class.stubs[uri] || open(uri).read))
        end
      rescue Timeout::Error
        raise TimeoutError, "Query timeout after #{@config[:timeout]} second(s)"
      end
    end

    class Response
      def initialize(uri, body)
        @uri      = uri
        @body     = body
        @response = JSON.parse(@body)
        validate
      end

      def status
        @response['Status']['code']
      end

      def validate
        case status
        when 400
          raise GeocoderError, 'The GMaps Geo API has ' \
          'indicated that the request is not formed correctly: ' \
          "(#{@uri})\n\n#{@body}"
        when 602
          raise GeocoderError, 'The GMaps Geo API has indicated ' \
          "that it is not able to geocode the request: (#{@uri})" \
          "\n\n#{@body}"
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
