module PostalCoder
  class Resolver

    def initialize(options = {})
      @config = Config.merge(options)
    end

  end
end