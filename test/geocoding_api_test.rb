require 'test_helper'


class GeocodingAPITest < Test::Unit::TestCase

  context 'initialize with incorrect arguments' do
    should 'fail with no arguments' do
      assert_raise ArgumentError do
        GCoder::GeocodingAPI::Request.new
      end
    end

    should 'fail with any argument other than a string' do
      assert_raise GCoder::Errors::BlankRequestError do
        GCoder::GeocodingAPI::Request.new(nil)
      end
      assert_raise GCoder::Errors::MalformedQueryError do
        GCoder::GeocodingAPI::Request.new(0)
      end
    end

    should 'fail when passed a blank string as an argument' do
      assert_raise GCoder::Errors::BlankRequestError do
        GCoder::GeocodingAPI::Request.new('         ')
      end
    end
  end

  context 'initialize with no API key present' do
    should 'fall down, go boom' do
      assert_raise GCoder::Errors::NoAPIKeyError do
        GCoder::GeocodingAPI::Request.new('M6R2G5')
      end
    end
  end

  context 'query with correct arguments' do
    setup do
      @zip = GCoder::GeocodingAPI::Request.new('M6R2G5',
        :gmaps_api_key => 'apikey')
    end

    should 'return parsed and tidied JSON' do
      @zip.expects(:http_get).returns(PAYLOADS[:json_m6r2g5])
      response = @zip.get.to_h
      assert_equal 5, response[:accuracy]
      assert_equal 'Canada', response[:country][:name]
      assert_equal 'CA', response[:country][:code]
      assert_equal 'ON', response[:country][:administrative_area]
      assert_equal 43.6504650, response[:point][:latitude]
      assert_equal -79.4449720, response[:point][:longitude]
      assert_equal 43.6536126, response[:box][:north]
      assert_equal 43.6473174, response[:box][:south]
      assert_equal -79.4418244, response[:box][:east]
      assert_equal -79.4481196, response[:box][:west]
    end

    should 'raise an error when API returns malformed request' do
      @zip.expects(:http_get).returns(PAYLOADS[:json_400])
      assert_raise GCoder::Errors::APIMalformedRequestError do
        @zip.get.validate!
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