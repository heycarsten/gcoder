module PostalCoder
  module Persistence


    module Cacheable

      def fetch(key, &block)
        value = tc_tdb_connection[key]
        return value if value
        tc_tdb_connection[key] = block.call(key)
      end

      private

      def tc_tdb_connection
        @tc_tdb_connection ||
          raise(NotImplementedError, "Cacheable expects #{self.class} to " \
          'implement @tc_tdb_connection')
      end

    end


    class DataStore

      def initialize(tdb_file = nil)
        if !tdb_file && !Config[:tdb_file]
          raise ArgumentError, 'tdb_file must be specified when it is not ' \
          'present in the global configuration'
        else
          self.filepath = (tdb_file || Config[:tdb_file])
        end
        @writer = Rufus::Tokyo::Table.new(filepath, :mode => write_mode_flags)
        @reader = Rufus::Tokyo::Table.new(filepath, :mode => 'r')
      end

      def [](key)
        @reader[key.to_s]
      end

      def []=(key, value)
        unless key.is_a?(String) || key.is_a?(Symbol)
          raise ArgumentError, "key must be String or Symbol, not: #{key.class}"
        end
        unless value.is_a?(Hash)
          raise ArgumentError, "value must be Hash, not: #{value.class}"
        end
        @writer[key.to_s] = prepare_hash_for_storage(value)
      end

      protected

      def prepare_hash_for_storage(hsh)
        unless hsh.keys.all? { |k| k.is_a?(Symbol) || k.is_a?(String) }
          raise Errors::InvalidStorageValueError, 'Storage value keys must ' \
          'all be Strings or Symbols'
        end
        unless value.values.all? { |v| v.is_a?(String) || v.is_a?(Numeric) ||
        v.is_a?(Symbol) }
          raise ArgumentError, 'value hash values must all be Strings, ' \
          'Numbers or Symbols'
        end
        hsh.inject({}) { |h,(k,v)| h.merge(k.to_s => v.to_s) }
      end

      def write_mode_flags
        File.exists?(filepath) ? 'w' : 'wc'
      end

      def reader
        @reader
      end

      def writer
        @writer
      end

      def filepath=(value)
        if '' == value.to_s
          raise Errors::NoDatabaseFileError, 'No Tokyo Cabinet TDB file is ' \
          'specified in the configuration'
        end
        @filepath = (('.tdb' == File.extname(value)) ? value : "#{value}.tdb")
      end

      def filepath
        @filepath
      end

    end

  end
end