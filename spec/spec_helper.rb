require 'minitest/spec'
require 'gcoder'
require 'yaml'

MiniTest::Unit.autorun

unless defined? SpecHelper
  module SpecHelper
    YAML.load_file('spec/support/requests.yml').each do |stub|
      body = File.read("spec/support/requests/#{stub[:file]}")
      GCoder::Geocoder::Request.stub(stub[:uri], body)
    end
  end
end
