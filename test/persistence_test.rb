require 'test_helper'

class PersistenceTest < Test::Unit::TestCase

  context 'Creating an instance of DataStore' do
    should 'throw and argument error without :tt_host specified' do
      assert_raise ArgumentError do
        PostalCoder::Persistence::DataStore.new
      end
    end

    should 'throw a better error if a tyrant connection fails' do
      assert_raise PostalCoder::Errors::TTUnableToConnectError do
        PostalCoder::Persistence::DataStore.new(:tt_host => '/tmp/fake')
      end
    end
  end

  context 'An instance of DataStore' do
    setup do
      Rufus::Tokyo::Tyrant.stubs(:new).returns({})
      @db = PostalCoder::Persistence::DataStore.new(:tt_host => '/tmp/tttest')
    end

    context '#[]=' do
      should 'now allow numbers or nil as a key' do
        assert_raise ArgumentError do
          @db[nil] = 'extreme fail'
        end
        assert_raise ArgumentError do
          @db[23] = 'massive fail'
        end
      end
    end

    context '#[]' do
      should 'return nil for a key that does not exist' do
        assert_nil @db['nope']
        assert_nil @db['']
        assert_nil @db[0]
        assert_nil @db[nil]
      end

      should 'alow retrieval of nil' do
        @db[:nil_key] = nil
        assert_nil @db[:nil_key]
      end

      should 'return parsed JSON for keys that do exist' do
        @db[:payload_1] = PAYLOADS[:test_string]
        @db[:payload_2] = PAYLOADS[:test_hash]
        @db[:payload_3] = PAYLOADS[:test_array]
        assert_equal PAYLOADS[:test_string], @db[:payload_1]
        assert_equal PAYLOADS[:test_hash], @db[:payload_2]
        assert_equal PAYLOADS[:test_array], @db[:payload_3]
      end
    end
  end

end