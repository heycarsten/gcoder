require 'spec_helper'

describe GCoder::Geocoder do
  it 'should fail when asked to resolve nil' do
    -> { GCoder::Geocoder.get(nil) }.must_raise GCoder::GeocoderError
  end

  it 'should fail when asked to resolve a blank string' do
    -> { GCoder::Geocoder.get('')  }.must_raise GCoder::GeocoderError
    -> { GCoder::Geocoder.get(' ') }.must_raise GCoder::GeocoderError
  end

  it 'should geocode queries' do
    @geo = GCoder::Geocoder.get('queen and spadina', :region => :ca)
    @geo.must_be_instance_of Hash
    @geo[:accuracy].must_equal 7
    @geo[:point][:latitude].must_be_close_to 43.6487606
    @geo[:point][:longitude].must_be_close_to -79.3962415
  end
end

describe GCoder::Geocoder::Utils do
  describe '#u' do
    before do
      @q = GCoder::Geocoder::Utils.u('hello world')
    end

    it 'should URI encode the string' do
      @q.must_equal 'hello+world'
    end
  end

  describe '#to_params' do
    before do
      @q = GCoder::Geocoder::Utils.to_params(:q => 'hello world', :a => 'test')
    end

    it 'should create a query string' do
      @q.must_equal 'q=hello+world&a=test'
    end
  end

  describe '#bounds_to_q' do
    before do
      @q = GCoder::Geocoder::Utils.bounds_to_q([[1, 2], [3, 4]])
    end

    it 'should join the coordinates appropriately' do
      @q.must_equal '1,2|3,4'
    end
  end
end
