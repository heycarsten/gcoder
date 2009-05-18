require 'rubygems'
require 'test/unit'
require 'shoulda'
require 'mocha'

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))
require 'postalcoder'

class Test::Unit::TestCase

  PAYLOADS = {
    :json_m6r2g5 => %q<
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
}>,
    :json_602 => %q<
{
  "name": "crashbangboom",
  "Status": {
    "code": 602,
    "request": "geocode"
  }
}>,
    :json_400 => %q<
{
  "name": "",
  "Status": {
    "code": 400,
    "request": "geocode"
  }
}>
  }

end
