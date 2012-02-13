module GCoder
  module Geocoder

    HOST = 'maps.googleapis.com'
    PATH = '/maps/api/geocode/json'

    class Request

      def self.to_query(params)
        params.map { |key, val| "#{CGI.escape(key.to_s)}=#{CGI.escape(val.to_s)}" }.join('&')
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
        p = { :sensor => 'false' }
        p[:address]   = address             if @address
        p[:latlng]    = latlng              if @latlng
        p[:language]  = @config[:language]  if @config[:language]
        p[:region]    = @config[:region]    if @config[:region]
        p[:bounds]    = bounds              if @config[:bounds]
        p[:client]    = @config[:client]    if @config[:client]
        p
      end

      def path
        "#{PATH}?#{self.class.to_query(params)}#{"&signature=#{sign_key(@config[:key])}" if @config[:key]}"
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
        Yajl::Parser.parse(
          (self.class.stubs[uri] || Net::HTTP.get(HOST, path)),
          :symbolize_keys => true
        )
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
      
      def url_safe_base64_decode(string)
        return Base64.decode64(string.tr('-_','+/')).gsub(/\n/,'')
      end

      def url_safe_base64_encode(raw)
        return Base64.encode64(raw).tr('+/','-_').gsub(/\n/,'')
      end
      
      def sign_key(key)
        sha1 = HMAC::SHA1.new(url_safe_base64_decode(key))
        sha1 << "#{PATH}?#{self.class.to_query(params)}"
        raw_signature = sha1.digest()
        
        url_safe_base64_encode(raw_signature)  
      end
    end

    class Response
      attr_reader :uri, :data

      def initialize(uri, data)
        @uri  = uri
        @data = Hashie::Mash.new(data)
        validate_status!
      end

      def as_mash
        data
      end

      private

      def validate_status!
        case data.status
        when 'OK'
          # All is well!
        when 'ZERO_RESULTS'
          raise NoResultsError, "Geocoding API returned no results: (#{uri})"
        when 'OVER_QUERY_LIMIT'
          raise OverLimitError, 'Rate limit for Geocoding API exceeded!'
        when 'REQUEST_DENIED'
          raise GeocoderError, "Request denied by the Geocoding API: (#{uri})"
        when 'INVALID_REQUEST'
          raise GeocoderError, "An invalid request was made: (#{uri})"
        else
          raise GeocoderError, 'No status in Geocoding API response: ' \
          "(#{uri})\n\n#{data.inspect}"
        end
      end
    end

  end
end
