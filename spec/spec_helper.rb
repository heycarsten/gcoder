require 'minitest/spec'
require 'gcoder'

MiniTest::Unit.autorun

unless defined? SpecHelper
  module SpecHelper
    PAYLOADS = {
      'http://maps.google.com/maps/geo?q=queen+and+spadina&output=json&oe=utf8&sensor=false&key=&region=ca' => %q<
        {
          "name": "queen and spadina",
          "Status": {
            "code": 200,
            "request": "geocode"
          },
          "Placemark": [ {
            "id": "p1",
            "address": "Spadina Ave \u0026 Queen St W, Toronto, ON M5V, Canada",
            "AddressDetails": {
           "Accuracy" : 7,
           "Country" : {
              "AdministrativeArea" : {
                 "AdministrativeAreaName" : "ON",
                 "SubAdministrativeArea" : {
                    "Locality" : {
                       "LocalityName" : "Toronto",
                       "Thoroughfare" : {
                          "ThoroughfareName" : "Spadina Ave & Queen St W"
                       }
                    },
                    "SubAdministrativeAreaName" : "Toronto Division"
                 }
              },
              "CountryName" : "Canada",
              "CountryNameCode" : "CA"
           }
        },
            "ExtendedData": {
              "LatLonBox": {
                "north": 43.6519082,
                "south": 43.6456130,
                "east": -79.3930939,
                "west": -79.3993891
              }
            },
            "Point": {
              "coordinates": [ -79.3962415, 43.6487606, 0 ]
            }
          }, {
            "id": "p2",
            "address": "Spadina Crescent E \u0026 Queen St, Saskatoon, SK S7K 0N2, Canada",
            "AddressDetails": {
           "Accuracy" : 7,
           "Country" : {
              "AdministrativeArea" : {
                 "AdministrativeAreaName" : "SK",
                 "SubAdministrativeArea" : {
                    "Locality" : {
                       "LocalityName" : "Saskatoon",
                       "PostalCode" : {
                          "PostalCodeNumber" : "S7K 0N2"
                       },
                       "Thoroughfare" : {
                          "ThoroughfareName" : "Spadina Crescent E & Queen St"
                       }
                    },
                    "SubAdministrativeAreaName" : "Division No. 11"
                 }
              },
              "CountryName" : "Canada",
              "CountryNameCode" : "CA"
           }
        },
            "ExtendedData": {
              "LatLonBox": {
                "north": 52.1397143,
                "south": 52.1334191,
                "east": -106.6442669,
                "west": -106.6505621
              }
            },
            "Point": {
              "coordinates": [ -106.6474145, 52.1365667, 0 ]
            }
          } ]
        }
      >
    }

    PAYLOADS.each_pair do |uri, body|
      GCoder::Geocoder::Request.stub(uri, body)
    end
  end
end
