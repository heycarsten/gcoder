module GCoder
  class Resolver < Persistence::DataStore

    def resolve(query)
      fetch(query) do |q|
        GeocodingAPI::Request.get(q, @config)
      end
    end

    def [](postal_code)
      resolve(postal_code)
    end

  end
end