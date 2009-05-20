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
        PostalCoder::Formats.symbol_to_class(:uberfail)
      end
    end

    should 'return the appropriate class when passed the proper symbol' do
      assert_equal PostalCoder::Formats::CAPostalCode,
        PostalCoder::Formats.symbol_to_class(:ca_postal_code)
    end
  end

  context 'Formats.symbols_to_classes' do
    should 'throw an argument error unless passed an array' do
      assert_raise ArgumentError do
        PostalCoder::Formats.symbols_to_classes(nil)
      end
    end

    should 'throw an argument error if passed an empty array' do
      assert_raise ArgumentError do
        PostalCoder::Formats.symbols_to_classes([])
      end
    end

    should 'return the appropriate classes when passed proper symbols' do
      assert_equal [PostalCoder::Formats::CAPostalCode],
        PostalCoder::Formats.symbols_to_classes([:ca_postal_code])
    end
  end

  context 'Formats.auto_instantiate' do
    should 'raise a malformed postal code error if no accepted formats match the input' do
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats.auto_instantiate('failtron')
      end
    end

    should 'return the first matching instance' do
      assert_instance_of PostalCoder::Formats::USZipCode,
        PostalCoder::Formats.auto_instantiate('20037')
    end
  end

  context 'Formats.instantiate' do
    should 'raise an error if passed nil as a postal code' do
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats.instantiate(nil)
      end
    end

    should 'auto instantiate to the first matching accepted format if no format is specified' do
      assert_instance_of PostalCoder::Formats::CAPostalCode,
        PostalCoder::Formats.instantiate('m6r2g5')
    end

    should 'return true if passed a postal code that matches at least one of the accepted formats' do
      assert_instance_of PostalCoder::Formats::CAPostalCode,
        PostalCoder::Formats.instantiate('m6r2g5', :ca_postal_code)
    end
  end

  context 'Creating an instance of AbstractFormat' do
    should 'throw a not implemented error' do
      assert_raise NotImplementedError do
        PostalCoder::Formats::AbstractFormat.new('test')
      end
    end
  end

  context 'Creating an instance of USZipCode' do
    should 'fail with the wrong type' do
      assert_raise ArgumentError do
        PostalCoder::Formats::USZipCode.new(nil)
      end
      assert_raise ArgumentError do
        PostalCoder::Formats::USZipCode.new(20037)
      end
    end

    should 'fail with a string of the wrong format' do
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats::USZipCode.new('2003')
      end
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats::USZipCode.new('20037-8')
      end
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats::USZipCode.new('')
      end
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats::USZipCode.new('BOOM7-8001')
      end
    end

    should 'work with whitespace present' do
      assert PostalCoder::Formats::USZipCode.new(' 200 37   ')
    end

    should 'allow ZIP+4 with or without a dash' do
      assert PostalCoder::Formats::USZipCode.new('20037-8001')
      assert PostalCoder::Formats::USZipCode.new('20037 8001')
      assert PostalCoder::Formats::USZipCode.new('200378001')
    end
  end

  context 'An instance of USZipCode for ZIP+4 address' do
    setup do
      @zip = PostalCoder::Formats::USZipCode.new(' 20037 8001 ')
    end

    should 'reformat the value to include a dash' do
      assert_equal '20037-8001', @zip.to_s
    end
  end

  context 'Creating an instance of CAPostalCode' do
    should 'fail with the wrong type' do
      assert_raise ArgumentError do
        PostalCoder::Formats::CAPostalCode.new(123456)
      end
      assert_raise ArgumentError do
        PostalCoder::Formats::CAPostalCode.new(nil)
      end
    end

    should 'fail with a string of the wrong format' do
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats::CAPostalCode.new('M6R')
      end
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats::CAPostalCode.new('')
      end
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats::CAPostalCode.new('M6R2G5A1')
      end
      assert_raise PostalCoder::Errors::MalformedPostalCodeError do
        PostalCoder::Formats::CAPostalCode.new('M6R205')
      end
    end

    should 'work with whitespace present' do
      assert PostalCoder::Formats::CAPostalCode.new('   M6R2G5 ')
      assert PostalCoder::Formats::CAPostalCode.new('   M6R 2G5 ')
    end

    should 'upcase any lowercase characters' do
      assert_equal 'M6R2G5', PostalCoder::Formats::CAPostalCode.new('m6r2g5').to_s
    end
  end

end
