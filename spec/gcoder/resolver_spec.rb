require 'spec_helper'

describe 'GCoder::Resolver (with caching)' do
  before do
    @g = GCoder.connect(:storage => :heap, :region => :us)
  end

  it 'should resolve geocodable queries' do
    r = @g.geocode('queen and spadina', :region => :ca)
    r.must_be_instance_of Array
  end

  it 'should resolve cached queries' do
    r1 = @g.geocode('queen and spadina', :region => :ca)
    r2 = @g.geocode('queen and spadina', :region => :ca)
    [r1, r2].each { |r| r.must_be_instance_of Array }
  end

  it 'should resolve reverse-geocodeable queries' do
    r = @g.geocode([43.6487606, -79.3962415], :region => nil)
    r.must_be_instance_of Array
  end

  it 'should raise an error for queries with no results' do
    -> { @g['noresults', :region => nil] }.must_raise GCoder::NoResultsError
  end

  it 'should raise an error for denied queries' do
    -> { @g['denied', :region => nil] }.must_raise GCoder::GeocoderError
  end

  it 'should raise an error when the query limit is exceeded' do
    -> { @g['overlimit', :region => nil] }.must_raise GCoder::OverLimitError
  end

  it 'should raise an error when the request is invalid' do
    -> { @g['denied', :region => nil] }.must_raise GCoder::GeocoderError
  end
end

describe 'GCoder::Resolver (without caching)' do
  it 'should resolve queries' do
    g = GCoder.connect(:storage => nil)
    r = g['queen and spadina', :region => :ca]
    r.must_be_instance_of Array
  end
end
