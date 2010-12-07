# GCoder

GCoder geocodes stuff using the Google Maps Geocoding API and caches it in
Redis if available. If you're looking for something hardcore check out
[Geokit](http://github.com/andre/geokit-gem).


## Bon Usage

    require 'gcoder'

    G = GCoder.connect \
      :api_key => 's3cr37s4uc3',    # Google Maps API key
      :append  => 'Ontario Canada', # Appended to all geocoder queries
      :country => :ca               # Country code for geocoder to favour

    G['dundas and sorauren']

    # => {:box=>
    # =>   {:north=>43.6543396,
    # =>    :south=>43.6480444,
    # =>    :east=>-79.4421004,
    # =>    :west=>-79.4483956},
    # =>  :point=>{:longitude=>-79.445248, :latitude=>43.651192},
    # =>  :accuracy=>7,
    # =>  :country=>{:administrative_area=>"ON", :code=>"CA", :name=>"Canada"}}
