module PostalCoder
  module Config

    @default_settings = {
      :gmaps_api_key => nil,
      :gmaps_api_timeout => 2,
      :tdb_file => nil,
      :accepted_formats => [:ca_postal_code, :us_zip_code] }

    def self.update(overrides)
      @default_settings.update(overrides)
    end

    def self.update!(hsh)
      @default_settings.update!(hsh)
    end

    def self.[](key)
      @default_settings[key]
    end

  end
end
