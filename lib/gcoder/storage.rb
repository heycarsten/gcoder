module GCoder
  module Storage

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
        @config = (opts || {})
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

      def set(key, val)
        raise NotImplementedError, 'This adapter needs to implement #set'
      end

      protected

      def nval(value)
        value.to_s
      end

      def nkey(key)
        Digest::SHA1.hexdigest(key.to_s.downcase)
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
        @heap[nkey(key)]
      end

      def set(key, value)
        @heap[nkey(key)] = nval(value)
      end
    end


    class RedisAdapter < Adapter
      def connect
        require 'redis'
        @rdb = Redis.connect(*[config[:connection]].compact)
        @keyspace = "#{config[:keyspace] || 'gcoder'}:"
      end

      def clear
        @rdb.keys(@keyspace + '*').each { |key| @rdb.del(key) }
      end

      def get(key)
        @rdb.get(keyns(key))
      end

      def set(key, value)
        if (ttl = config[:key_ttl])
          @rdb.setex(keyns(key), ttl, nval(value))
        else
          @rdb.set(keyns(key), nval(value))
        end
      end

      private

      def keyns(key)
        "#{@keyspace}#{nkey(key)}"
      end
    end

    register :heap,  HeapAdapter
    register :redis, RedisAdapter

  end
end
