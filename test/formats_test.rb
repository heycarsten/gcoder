require 'test_helper'

class FormatsTest < Test::Unit::TestCase

  context 'Formats.symbol_to_class' do
    should 'throw an argument error unless given a symbol' do
      assert_raise ArgumentError do
        PostalCoder::Formats.symbol_to_class('boom!')
      end
    end

    should 'throw an error when passed an unknown format symbol' do
      assert_raise PostalCoder::Errors::UnknownFormatSymbolError do
        PostalCoder::Formats.symbol_to_class(:rubyonfails)
      end
    end

    should 'return the appropriate class when passed the proper symbol' do
      assert_equal PostalCoder::Formats::CAPostalCode,
        PostalCoder::Formats.symbol_to_class(:ca_postal_code)
    end
  end

  context 'AbstractPostalCode' do
    should 'be tested' do
      flunk 'TODO: Continue testing!'
    end
  end

end
