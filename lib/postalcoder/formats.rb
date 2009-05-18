module PostalCoder
  module Formats

    SYMBOLS_TO_NAMES_MAP = {
      :ca_postal_code => 'CAPostalCode',
      :us_zip_code => 'USZipCode' }

    # Eww gross! -- CKN
    def self.symbol_to_class(symbol)
      unless symbol.is_a?(Symbol)
        raise ArgumentError, "expected Symbol, not: #{symbol.class}"
      end
      class_name = SYMBOLS_TO_NAMES_MAP.fetch(symbol) do |sym|
        raise Errors::UnknownFormatSymbolError, 'The format symbol ' \
        "#{sym.inspect} is not one of the reconized symbols, which are: " \
        "#{SYMBOLS_TO_NAMES_MAP.keys.map { |s| s.inspect }.join(', ')}."
      end
      eval class_name
    end


    class AbstractFormat

      attr_reader :value

      def initialize(raw_value)
        unless raw_value.is_a?(String)
          raise ArgumentError, "value must be String, not: #{raw_value.class}"
        end
        @value = cleanup(raw_value)
        validate_form!
      end

      def to_s
        value
      end

      def cleanup(raw_value)
        raw_value.upcase.gsub(/\s|\-/, '')
      end

      def has_valid_form?
        raise NotImplementedError, "#{self.class}#check_form must be implemented"
      end

      protected

      def validate_form!
        return true if has_valid_form?
        raise Errors::MalformedPostalCodeError, "#{@value.inspect} is not a " \
        "properly formed #{self.class}"
      end

    end


    class CAPostalCode < AbstractFormat

      def has_valid_form?
        value =~ /\A([A-Z][0-9]){3}\Z/
      end

    end


    class USZipCode < AbstractFormat

      def to_s
        case value.length
        when 5
          value
        when 9
          "#{value[0,5]}-#{value[5,4]}"
        end
      end

      def has_valid_form?
        value =~ /\A([0-9]{5}|[0-9]{9})\Z/
      end

    end


  end
end