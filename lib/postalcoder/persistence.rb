module PostalCoder
  module Persistence


    class DataStore

      def initialize(options = {})
        @config = Config.merge(options)
        unless @config[:tt_host]
          raise ArgumentError, ':tt_host must be specified when it is not ' \
          'present in the global configuration.'
        end
        @tyrant = Rufus::Tokyo::Tyrant.new(@config[:tt_host], @config[:tt_port])
      rescue RuntimeError => boom
        if boom.message.include?('couldn\'t connect to tyrant')
          raise Errors::TTUnableToConnectError, 'Unable to connect to the ' \
          "Tokyo Tyrant server at #{@config[:tt_host]} [#{@config[:tt_port]}]"
        else
          raise boom
        end
      end

      def fetch(key, &block)
        unless block_given?
          raise ArgumentError, 'no block was given but one was expected'
        end
        value = storage_get(key)
        return value if value
        storage_put(key, block.call(key.to_s))
      end

      def [](key)
        storage_get(key)
      end

      def []=(key, value)
        unless key.is_a?(String) || key.is_a?(Symbol)
          raise ArgumentError, "key must be String or Symbol, not: #{key.class}"
        end
        storage_put(key, value)
      end

      protected

      def storage_get(key)
        value = tyrant[key.to_s]
        value ? YAML.load(value) : nil
      end

      def storage_put(key, value)
        tyrant[key.to_s] = YAML.dump(value)
        value # <- We don't want to return YAML in this case.
      end

      def tyrant
        @tyrant
      end

    end

  end
end