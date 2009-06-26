require 'test_helper'

class GCoderTest < Test::Unit::TestCase

  context 'ProxyMethods' do
    should 'be present in GCoder module' do
      assert_respond_to GCoder, :config=
      assert_respond_to GCoder, :connect
    end

    context 'GCoder.config=' do
      should 'proxy to Config.update' do
        GCoder::Config.expects(:update).with({})
        assert GCoder.config = {}
      end
    end

    context 'GCoder.connect' do
      should 'proxy to Resolver.new' do
        GCoder::Resolver.expects(:new).with({}).returns(:it_works)
        assert_equal :it_works, GCoder.connect
      end
    end
  end

end
