require 'spec_helper'

describe GCoder::Storage::Adapter do
  it 'shoyld raise an error if instantiated directly' do
    -> { GCoder::Storage::Adapter.new }.must_raise GCoder::NotImplementedError
  end
end

describe GCoder::Storage::HeapAdapter do
  before do
    @db = GCoder::Storage[:heap].new
  end

  after do
    @db.clear
  end

  it 'should be able to get values that were previously set' do
    @db.set('1 a', 'test_1')
    @db.set('2 b', 'test_2')
    @db.set('3 c', 'test_3')
    @db.get('1 a').must_equal 'test_1'
    @db.get('2 b').must_equal 'test_2'
    @db.get('3 c').must_equal 'test_3'
  end

  it 'should remove all keys from the heap' do
    @db.set('1 a', 'test_1')
    @db.set('2 b', 'test_2')
    @db.set('3 c', 'test_3')
    @db.clear
    @db.get('1 a').must_be_nil
    @db.get('2 b').must_be_nil
    @db.get('3 c').must_be_nil
  end
end

describe GCoder::Storage::RedisAdapter do
  before do
    @db = GCoder::Storage[:redis].new
  end

  after do
    @db.clear
  end

  it 'should be able to get values that were previously set' do
    @db.set('1 a', 'test_1')
    @db.set('2 b', 'test_2')
    @db.set('3 c', 'test_3')
    @db.get('1 a').must_equal 'test_1'
    @db.get('2 b').must_equal 'test_2'
    @db.get('3 c').must_equal 'test_3'
  end

  it 'should remove all keys from the heap' do
    @db.set('1 a', 'test_1')
    @db.set('2 b', 'test_2')
    @db.set('3 c', 'test_3')
    @db.clear
    @db.get('1').must_be_nil
    @db.get('2').must_be_nil
    @db.get('3').must_be_nil
  end
end
