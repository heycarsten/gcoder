require 'test_helper'

class ResolverTest < Test::Unit::TestCase

  context 'Resolver' do
    setup do
      Rufus::Tokyo::Tyrant.stubs(:new).returns({})
      @db = GCoder::Resolver.new(:tt_host => '/tmp/tttest', :gmaps_api_key => 'testkey')
    end

    should 'return a hash of information for a new address' do
      GCoder::GeocodingAPI::Request.any_instance.
        expects(:http_get).returns(PAYLOADS[:json_m6r2g5])
      assert_instance_of Hash, @db.resolve('m6r2g5')
    end

    should 'not call api when a cached postal code is called' do
      assert_instance_of Hash, @db.resolve('m6r2g5')
    end

    should 'store the postal code key in the correct format' do
      assert_instance_of Hash, @db.resolve('M6R2G5')
    end

    should 'allow [] to resolve with auto-instantiation' do
      assert_instance_of Hash, @db['M6R2G5']
    end

    should 'raise malformed postal code error for a nil postal code' do
      assert_raise GCoder::Errors::MalformedPostalCodeError do
        @db.resolve(nil)
      end
    end
  end

end