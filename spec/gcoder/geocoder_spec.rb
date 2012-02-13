# encoding: UTF-8
require 'spec_helper'

describe GCoder::Geocoder::Request do
  it 'should raise an error when passed nil' do
    -> {
      GCoder::Geocoder::Request.new(nil)
    }.must_raise GCoder::BadQueryError
  end

  it 'should raise an error when passed a blank string' do
    -> {
      GCoder::Geocoder::Request.new(' ')
    }.must_raise GCoder::BadQueryError
  end

  it 'should raise an error when passed incorrect lat/lng pair' do
    GCoder::Geocoder::Request.tap do |req|
      -> { req.new([])           }.must_raise GCoder::BadQueryError
      -> { req.new([43.64])      }.must_raise GCoder::BadQueryError
      -> { req.new([43.64, nil]) }.must_raise GCoder::BadQueryError
      -> { req.new(['', 43.64])  }.must_raise GCoder::BadQueryError
    end
  end

  it 'should URI encode a string' do
    q = GCoder::Geocoder::Request.to_query(:q => 'hello world', :a => 'test')
    q.must_equal 'q=hello+world&a=test'
  end

  it 'should URI encode a string with ampersands' do
    q = GCoder::Geocoder::Request.to_query(:q => 'hello & world', :a => 'test')
    q.must_equal 'q=hello+%26+world&a=test'
  end

  it 'should URI encode a UTF-8 string' do
    q = GCoder::Geocoder::Request.to_query(:q => 'मुंबई', :a => 'test')
    q.must_equal 'q=%E0%A4%AE%E0%A5%81%E0%A4%82%E0%A4%AC%E0%A4%88&a=test'
  end

  it 'should create a query string' do
    q = GCoder::Geocoder::Request.to_query(:q => 'hello world', :a => 'test')
    q.must_equal 'q=hello+world&a=test'
  end

  it '(when passed a bounds option) should generate correct query params' do
    GCoder::Geocoder::Request.new('q', :bounds => [[1,2], [3,4]]).tap do |req|
      req.params[:bounds].must_equal '1,2|3,4'
    end
  end

  it '(when passed a lat/lng pair) should generate correct query params' do
    GCoder::Geocoder::Request.new([43.64, -79.39]).tap do |req|
      req.params[:latlng].must_equal '43.64,-79.39'
      req.params[:address].must_be_nil
    end
  end

  it '(when passed a geocodable string) should generate correct query params' do
    GCoder::Geocoder::Request.new('queen and spadina').tap do |req|
      req.params[:latlng].must_be_nil
      req.params[:address].must_equal 'queen and spadina'
    end
  end
  
  it "(when passed a premier client and key) should generate correct query params" do
    q = GCoder::Geocoder::Request.new('los angeles', :client => "gme-test", :key => "zNf23lb-YIoD4kEFN34C6324cww=").path
    q.must_equal '/maps/api/geocode/json?sensor=false&address=los+angeles&client=gme-test&signature=owxOUlItGsYUp-iEPw6n1S06TSc='
  end
  
end
