module GCoder
  module Geocoder

    BASE_URI = 'http://maps.googleapis.com/maps/api/geocode/json'
    BASE_PARAMS = { :sensor => 'false' }

    def self.get(query, options = {})
      Request.new(query, options).get.as_hash
    end

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
        if query.is_a?(Array)
          raise GeocoderError, 'latlng is not a pair' unless 2 == query.size
          @latlng = query
        else
          raise GeocoderError, 'address is nil' unless query
          raise GeocoderError, 'address is blank' if '' == query.to_s.strip
          @address = query
        end
      end

      def params
        BASE_PARAMS.dup.tap do |p|
          p[:key]      = @config[:api_key]  if @config[:api_key]
          p[:address]  = address            if @address
          p[:latlng]   = latlng             if @latlng
          p[:language] = @config[:language] if @config[:language]
          p[:region]   = @config[:region]   if @config[:region]
          p[:bounds]   = bounds             if @config[:bounds]
          p
        end
      end

      def uri
        "#{BASE_URI}?#{self.class.to_query(params)}"
      end

      def get
        Timeout.timeout(@config[:timeout]) do
          Response.new(uri, (self.class.stubs[uri] || open(uri).read))
        end
      rescue Timeout::Error
        raise TimeoutError, "Query timeout after #{@config[:timeout]} second(s)"
      end

      private

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
      {
        :key    => 'val',
        :person => { :name => 'car' },
        :list   => [1, 2, 3],
        :hashes => [{ :a => 1}, { :b => 2}]
      }

      def self.symkeys(obj, inside = false)
        case obj
        when Hash
          Hash[obj.map { |key, val| [key.to_sym, symkeys(val)] }]
        when Array
          obj.map do |o|
            case o
            when Hash  then symkeys(o)
            when Array then symkeys(o)
            else o
            end
          end
        else
          obj
        end
      end

      def initialize(uri, body)
        @uri      = uri
        @body     = body
        @response = self.class.symkeys(JSON.parse(@body))
        validate_status!
      end

      def status
        @response[:status]
      end

      def as_hash
        @response
      end

      private

      def validate_status!
        case status
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
