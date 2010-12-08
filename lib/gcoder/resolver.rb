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
      @conn.get(query)
    end

    def set(key, value)
      return value unless @conn
      @conn.set(key, value)
      value
    end

  end
end
