require 'spec_helper'

describe GCoder::Geocoder do
  it 'should fail when asked to resolve nil' do
    -> { GCoder::Geocoder.get(nil) }.must_raise GCoder::GeocoderError
  end

  it 'should fail when asked to resolve a blank string' do
    -> { GCoder::Geocoder.get('')  }.must_raise GCoder::GeocoderError
    -> { GCoder::Geocoder.get(' ') }.must_raise GCoder::GeocoderError
  end

  it 'should geocode addresses' do
    @geo = GCoder::Geocoder.get('queen and spadina', :region => :ca)
    @geo.must_be_instance_of Hash
    @geo[:results].first.tap do |r|
      r[:geometry][:location][:lng].must_be_close_to -79.3962415
      r[:geometry][:location][:lat].must_be_close_to 43.6487606
    end
  end
end

describe GCoder::Geocoder::Request do
  describe '::u' do
    before do
      @q = GCoder::Geocoder::Request.u('hello world')
    end

    it 'should URI encode the string' do
      @q.must_equal 'hello+world'
    end
  end

  describe '::to_query' do
    before do
      @q = GCoder::Geocoder::Request.to_query(:q => 'hello world', :a => 'test')
    end

    it 'should create a query string' do
      @q.must_equal 'q=hello+world&a=test'
    end
  end
end

describe GCoder::Geocoder::Response do
  describe '::symkeys' do
    it 'should symbolize hash keys' do
      inhsh  = { 'this' => 'is', 'a' => { 'hash' => 'yay' } }
      outhsh = GCoder::Geocoder::Response.symkeys(inhsh)
      outhsh.must_equal({ :this => 'is', :a => { :hash => 'yay' } })
    end
  end
end