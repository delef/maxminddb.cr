require "./base"
require "./common"
require "./entity/*"

module MaxMindDB::Format::GeoIP2
  class Root
    getter data, city, continent, country, location, postal, registered_country, subdivisions

    def initialize(@data : Any)
      @city = Entity::City.new(@data["city"]?)
      @continent = Entity::Continent.new(@data["continent"]?)
      @country = Entity::Country.new(@data["country"]?)
      @location = Entity::Location.new(@data["location"]?)
      @postal = Entity::Postal.new(@data["postal"]?)
      @registered_country = Entity::RegisteredCountry.new(@data["registered_countrys"]?)
      @subdivisions = [] of Entity::Subdivisions

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
end