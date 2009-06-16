require 'test_helper'

class ConfigTest < Test::Unit::TestCase

  context 'Config#merge' do
    setup do
      @config = PostalCoder::Config.merge(:gmaps_api_timeout => 3)
    end

    should 'return a hash of updated config settings' do
      assert_instance_of Hash, @config
      assert_equal 6, @config.size
      assert_equal 3, @config[:gmaps_api_timeout]
    end

    should 'not change default configuration' do
      assert_equal 2, PostalCoder::Config[:gmaps_api_timeout]
    end
  end

  context 'Config#update' do
    setup do
      @config = PostalCoder::Config.update(:gmaps_api_timeout => 1)
    end

    should 'return a hash of updated config settings' do
      assert_instance_of Hash, @config
      assert_equal 6, @config.size
      assert_equal 1, @config[:gmaps_api_timeout]
    end

    should 'change default configuration' do
      assert_equal 1, PostalCoder::Config[:gmaps_api_timeout]
    end
  end

end
