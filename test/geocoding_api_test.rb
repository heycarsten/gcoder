require 'test_helper'


class GeocodingAPITest < Test::Unit::TestCase

  context 'initialize with incorrect arguments' do
    should 'fail with no arguments' do
      assert_raise ArgumentError do
        PostalCoder::GeocodingAPI::Query.new
      end
    end

    should 'fail with any argument other than a string' do
      assert_raise ArgumentError do
        PostalCoder::GeocodingAPI::Query.new(nil)
      end
      assert_raise ArgumentError do
        PostalCoder::GeocodingAPI::Query.new(0)
      end
    end

    should 'fail when passed a blank string as an argument' do
      assert_raise PostalCoder::Errors::BlankQueryError do
        PostalCoder::GeocodingAPI::Query.new('         ')
      end
    end
  end

  context 'initialize with no API key present' do
    should 'fall down, go boom' do
      assert_raise PostalCoder::Errors::NoAPIKeyError do
        PostalCoder::GeocodingAPI::Query.new('M6R2G5')
      end
    end
  end

  context 'query with correct arguments' do
    setup do
      @zip = PostalCoder::GeocodingAPI::Query.new('M6R2G5',
        :gmaps_api_key => 'apikey')
    end

    should 'retun JSON' do
      @zip.expects(:http_get).returns(PAYLOADS[:json_m6r2g5])
      assert_equal 'M6R2G5', @zip.to_hash['name']
      assert_equal 200, @zip.to_hash['Status']['code']
    end

    should 'return a Hash on #to_ruby' do
      @zip.expects(:http_get).returns(PAYLOADS[:json_m6r2g5])
      assert_instance_of Hash, @zip.to_hash
      assert_equal 'M6R2G5', @zip.to_hash['name']
    end

    should 'raise an error when API returns malformed request' do
      @zip.expects(:http_get).returns(PAYLOADS[:json_400])
      assert_raise PostalCoder::Errors::APIMalformedRequestError do
        @zip.to_hash
      end
    end

    should 'have an appropriate URI' do
      assert_match /output=json/, @zip.uri
      assert_match /q=M6R2G5/, @zip.uri
      assert_match /oe=u/, @zip.uri
      assert_match /sensor=false/, @zip.uri
      assert_match /key=apikey/, @zip.uri
    end
  end

end