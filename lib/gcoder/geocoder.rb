module GCoder
  module Geocoder

    HOST   = 'maps.googleapis.com'
    PATH   = '/maps/api/geocode/json'
    PARAMS = { :sensor => 'false' }

    class Request
      def self.u(string)
        string.to_s.gsub(/([^ a-zA-Z0-9_.-]+)/n) {
          '%' + $1.unpack('H2' * $1.size).join('%').upcase
        }.tr(' ', '+')
      end

      def self.to_query(params)
        params.map { |key, val| "#{u key}=#{u val}" }.join('&')
      end

      def self.stubs
        @stubs ||= {}
      end

      def self.stub(uri, body)
        stubs[uri] = body
      end

      def initialize(query, opts = {})
        @config = GCoder.config.merge(opts)
        detect_and_set_query(query)
      end

      def params
        PARAMS.dup.tap do |p|
          p[:key]      = @config[:api_key]  if @config[:api_key]
          p[:address]  = address            if @address
          p[:latlng]   = latlng             if @latlng
          p[:language] = @config[:language] if @config[:language]
          p[:region]   = @config[:region]   if @config[:region]
          p[:bounds]   = bounds             if @config[:bounds]
          p
        end
      end

      def path
        "#{PATH}?#{self.class.to_query(params)}"
      end

      def uri
        "http://#{HOST}#{path}"
      end

      def get
        Timeout.timeout(@config[:timeout]) do
          Response.new(uri, http_get)
        end
      rescue Timeout::Error
        raise TimeoutError, "Query timeout after #{@config[:timeout]} second(s)"
      end

      private

      def detect_and_set_query(query)
        if query.is_a?(Array)
          case
          when query.size != 2
            raise BadQueryError, "Unable to geocode lat/lng pair that is not " \
            "two elements long: #{query.inspect}"
          when query.any? { |q| '' == q.to_s.strip }
            raise BadQueryError, "Unable to geocode lat/lng pair with blank " \
            "elements: #{query.inspect}"
          else
            @latlng = query
          end
        else
          if '' == query.to_s.strip
            raise BadQueryError, "Unable to geocode a blank query: " \
            "#{query.inspect}"
          else
            @address = query
          end
        end
      end

      def http_get
        self.class.stubs[uri] || Net::HTTP.get(HOST, path)
      end

      def latlng
        @latlng.join(',')
      end

      def bounds
        @config[:bounds].map { |point| point.join(',') }.join('|')
      end

      def address
        @config[:append] ? "#{@address} #{@config[:append]}" : @address
      end
    end


    class Response
      attr_reader :body, :uri

      def initialize(uri, body)
        @uri      = uri
        @body     = body
        @response = Hashie::Mash.new(JSON.parse(@body))
        validate_status!
      end

      def as_mash
        @response
      end

      private

      def validate_status!
        case @response.status
        when 'OK'
          # All is well!
        when 'ZERO_RESULTS'
          raise NoResultsError, "Geocoding API returned no results: (#{@uri})"
        when 'OVER_QUERY_LIMIT'
          raise OverLimitError, 'Rate limit for Geocoding API exceeded!'
        when 'REQUEST_DENIED'
          raise GeocoderError, "Request denied by the Geocoding API: (#{@uri})"
        when 'INVALID_REQUEST'
          raise GeocoderError, "An invalid request was made: (#{@uri})"
        else
          raise GeocoderError, 'No status in Geocoding API response: ' \
          "(#{@uri})\n\n#{@body}"
        end
      end
    end

  end
end
