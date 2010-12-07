module GCoder
  module Adapters

    def self.adapters
      @adapters ||= {}
    end

    def self.[](name)
      adapters[name.to_sym]
    end

    def self.register(name, mod)
      adapters[name.to_sym] = mod
    end

    class Adapter
      def initialize(opts = {})
        @config = GCoder.config.merge(opts).tap { |c| cfg[:adapter_opts] || {} }
        connect
      end

      def config
        @config
      end

      def connect
        raise NotImplementedError, 'This adapter needs to implement #connect'
      end

      def clear
        raise NotImplementedError, 'This adapter needs to implement #clear'
      end

      def get(key)
        raise NotImplementedError, 'This adapter needs to implement #get'
      end

      def set(key, value)
        raise NotImplementedError, 'This adapter needs to implement #set'
      end
    end

    class HeapAdapter < Adapter
      def connect
        @heap = {}
      end

      def clear
        @heap = {}
      end

      def get(key)
        @heap[key]
      end

      def set(key, value)
        @heap[key] = value
      end
    end

    class RedisAdapter < Adapter
      def connect
        @rdb = config[:redis] ? Redis.connect(config[:redis]) : Redis.connect
      end

      def clear
        @rdb.del(*@rdb.keys("gcoder:*"))
      end

      def get(key)
        @rdb.get(key)
      end

      def set(key, value)
        if (ttl = config[:cache_ttl])
          @rdb.setex(key, ttl, value)
        else
          @rdb.set(key, value)
        end
      end
    end

    register :heap,  HeapAdapter
    register :redis, RedisAdapter

  end
end
