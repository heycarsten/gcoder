module GCoder
  class Resolver

    def initialize(opts = {})
      @config = GCoder.config.merge(opts)
      if (adapter_name = @config[:storage])
        @conn = Storage[adapter_name].new(@config[:storage_config])
      else
        @conn = nil
      end
    end

    def [](*args)
      geocode *args
    end

    def geocode(query, opts = {})
      fetch([query, opts].join) {
        Geocoder::Request.new(query, opts).get.as_mash
      }.results
    end

    def fetch(key)
      raise ArgumentError, 'block required' unless block_given?
      Hashie::Mash.new(
        (val = get(key)) ? Yajl::Parser.parse(val) : set(key, yield)
      )
    end

    private

    def get(query)
      return nil unless @conn
      @conn.get(query)
    end

    def set(key, value)
      return value unless @conn
      @conn.set(key, Yajl::Encoder.encode(value))
      value
    end

  end
end
