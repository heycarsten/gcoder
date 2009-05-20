require 'test_helper'

class PostalCoderTest < Test::Unit::TestCase

  context 'ProxyMethods' do
    should 'be present in PostalCoder module' do
      assert_respond_to PostalCoder, :config=
      assert_respond_to PostalCoder, :connect
    end

    context 'PostalCoder.config=' do
      should 'proxy to Config.update' do
        PostalCoder::Config.expects(:update).with({})
        assert PostalCoder.config = {}
      end
    end

    context 'PostalCoder.connect' do
      should 'proxy to Resolver.new' do
        PostalCoder::Resolver.expects(:new).with({}).returns(:it_works)
        assert_equal :it_works, PostalCoder.connect
      end
    end
  end

end
