module GCoder
  class Resolver

    def initialize(opts = {})
      @config = GCoder.config.merge(opts)
      if (adapter_name = @config[:adapter])
        @conn = Adapters[adapter_name].new(@config)
      else
        @conn = nil
      end
    end

    def [](*args)
      geocode *args
    end

    def geocode(query, opts = {})
      return nil if '' == query.to_s.strip
      fetch(query + opts.to_s) do
        Geocoder.get(query, opts)
      end
    end

    def fetch(query)
      raise ArgumentError, 'block required' unless block_given?
      if (resp = get(query))
        JSON.parse(resp)
      else
        set(query, yield.as_json)
      end
    end

    private

    def get(query)
      return nil unless @conn
      @conn.get(nkey(key))
    end

    def set(key, value)
      val = nval(value)
      return val unless @conn
      @conn.set(nkey(key), val)
      val
    end

    def nval(value)
      value.to_s
    end

    def nkey(key)
      Digest::SHA1.hexdigest(key.to_s)
    end

  end
end
