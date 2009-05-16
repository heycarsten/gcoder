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
      eval "::PostalCoder::Formats::#{class_name}"
    end


    class AbstractPostalCode

      def initialize(raw_value)
        @value = cleanup(raw_value)
        check_form!
      end

      def cleanup(raw_value)
        raw_value.strip
      end

      def form_check
        raise NotImplementedError, '#form_check must be implemented'
      end

      def to_s
        @value
      end

      def check_form!
        return true if form_check
        raise Errors::MalformedPostalCodeError, "#{value.inspect} is not a " \
        "properly formed #{self.class}"
      end

    end


    class CAPostalCode < AbstractPostalCode

      def cleanup(raw_value)
        unless raw_value.is_a?(String)
          raise ArgumentError, "value must be String, not: #{raw_value.class}"
        end
        raw_value.upcase.gsub(/\s/, '')
      end

      def form_check
        value.to_s =~ /\A[A-Z][0-9]{3}\Z/
      end

    end


    class USZipCode < AbstractPostalCode

      def cleanup(raw_value)
        unless raw_value.is_a?(String) || raw_value.is_a?(Integer)
          raise ArgumentError, 'value must be String or Integer, not: ' +
          raw_value.class.to_s
        end
        raw_value.to_s.gsub(/\s/, '')
      end

      def form_check
        value.to_s =~ /\A(\d{5}|\d{5}-\d{4})\Z/
      end

    end


  end
end