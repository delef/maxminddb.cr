require "./geoip2/entity"

module MaxMindDB::Format::GeoIP2
  DEFAULT_LOCALE = "en"

  class Root
    @connection_type : String?

    getter data, city, continent, country, location, postal, registered_country, subdivisions

    def initialize(@data : Any)
      @city = Entity::City.new(@data["city"]?)
      @continent = Entity::Continent.new(@data["continent"]?)
      @country = Entity::Country.new(@data["country"]?)
      @location = Entity::Location.new(@data["location"]?)
      @postal = Entity::Postal.new(@data["postal"]?)
      @registered_country = Entity::RegisteredCountry.new(@data["registered_country"]?)
      @represented_country = Entity::RepresentedCountry.new(@data["represented_country"]?)
      @traits = Entity::Traits.new(@data["traits"]?)
      @subdivisions = [] of Entity::Subdivisions
      @connection_type = @data["connection_type"].as_s if @data["connection_type"]?

      if @data["subdivisions"]?
        @data["subdivisions"].size.times.each do |i|
          @subdivisions << Entity::Subdivisions.new(@data["subdivisions"][i]?)
        end
      end
    end

    def found?
      @data.found?
    end

    def empty?
      @data.empty?
    end
  end

  def self.new(data : Any)
    Root.new(data)
  end
end
