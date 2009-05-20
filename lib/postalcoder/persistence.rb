module PostalCoder
  module Persistence


    module Cacheable

      def fetch(key, &block)
        value = data_store[key]
        return value if value
        data_store[key] = block.call(key)
      end

      private

      def data_store
        @data_store ||
          raise(NotImplementedError, "Cacheable expects #{self.class} to " \
          'implement @data_store')
      end

    end


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

      def [](key)
        storage_get(key)
      end

      def []=(key, value)
        unless key.is_a?(String) || key.is_a?(Symbol)
          raise ArgumentError, "key must be String or Symbol, not: #{key.class}"
        end
        case value
        when Hash, Array, String, Numeric, TrueClass, FalseClass, NilClass
          storage_put(key, value)
        else
          raise ArgumentError, "value must be Hash, not: #{value.class}"
        end
      end

      protected

      def storage_get(key)
        value = tyrant[key.to_s]
        value ? YAML.load(value) : nil
      end

      def storage_put(key, value)
        tyrant[key.to_s] = YAML.dump(value)
      end

      def tyrant
        @tyrant
      end

    end

  end
end