require 'minitest/spec'
require 'gcoder'

MiniTest::Unit.autorun

unless defined? SpecHelper
  module SpecHelper
    PAYLOADS = {
      :json_m6r2g5 => <<-JSON
{
"name": "M6R2G5",
"Status": {
  "code": 200,
  "request": "geocode"
},
"Placemark": [ {
  "id": "p1",
  "address": "Ontario M6R 2G5, Canada",
  "AddressDetails": {"Country": {"CountryNameCode": "CA","CountryName": "Canada","AdministrativeArea": {"AdministrativeAreaName": "ON","PostalCode": {"PostalCodeNumber": "M6R 2G5"}}},"Accuracy": 5},
  "ExtendedData": {
    "LatLonBox": {
      "north": 43.6536126,
      "south": 43.6473174,
      "east": -79.4418244,
      "west": -79.4481196
    }
  },
  "Point": {
    "coordinates": [ -79.4449720, 43.6504650, 0 ]
  }
} ]
}
JSON
,
      :json_602 => <<-JSON
{
  "name": "crashbangboom",
  "Status": {
    "code": 602,
    "request": "geocode"
  }
}
JSON
,
      :json_400 => <<-JSON
{
  "name": "",
  "Status": {
    "code": 400,
    "request": "geocode"
  }
}
JSON
,
      :test_string => "test\nstring",
      :test_hash => { 'test' => 'value', 100 => 'one hundred' },
      :test_array => ['test', 1, 3.1415, true, false, nil]
    }
  end
end
