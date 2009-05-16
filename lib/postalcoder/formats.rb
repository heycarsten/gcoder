module PostalCoder
  module Formats

    MAP = {
      :ca_postal_code => :CAPostalCode,
      :us_zip_code => :USZipCode }


    module PostalCodeable

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


    class CAPostalCode

      include PostalCodeable

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


    class USZipCode

      include PostalCodeable

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