module MaxMindDB::Format::GeoIP2::Entity
  abstract class Base
    getter data
    def_hash data

    def initialize(@data : Any?)
    end

    def found?
      @data.try &.found?
    end

    def empty?
      @data.try &.empty?
    end

    def inspect(io)
      @data.inspect(io)
    end
  end

  class Location < Base
    def accuracy_radius
      return unless data = @data
      data["accuracy_radius"].as_i if data["accuracy_radius"]?
    end

    def latitude
      return unless data = @data
      data["latitude"].as_f if data["latitude"]?
    end

    def longitude
      return unless data = @data
      data["longitude"].as_f if data["longitude"]?
    end

    def metro_code
      return unless data = @data
      data["metro_code"].as_i if data["metro_code"]?
    end

    def time_zone
      return unless data = @data
      data["time_zone"].as_s if data["time_zone"]?
    end
  end

  class Traits < Base
    def is_anonymous_proxy
      return unless data = @data
      data["is_anonymous_proxy"].as_bool if data["is_anonymous_proxy"]?
    end

    def is_satellite_provider
      return unless data = @data
      data["is_satellite_provider"].as_bool if data["is_satellite_provider"]?
    end
  end

  EntityMap = {
    City => [:geoname_id, :names],
    Continent => [:geoname_id, :names, :code],
    Country => [:geoname_id, :names, :iso_code],
    Postal => [:code],
    RegisteredCountry => [:geoname_id, :names, :iso_code],
    RepresentedCountry => [:geoname_id, :names, :iso_code],
    Subdivisions => [:geoname_id, :names, :iso_code]
  }

  {% begin %}
    {% for klass, methods in EntityMap %}
      class {{klass}} < Base
        {% for method in methods %}
          {% if method == :geoname_id %}
            def geoname_id : Int32?
              return unless data = @data
              data["geoname_id"].as_i if data["geoname_id"]?
            end
          {% elsif method == :code %}
            def code : String?
              return unless data = @data
              data["code"].as_s if data["code"]?
            end
          {% elsif method == :iso_code %}
            def iso_code : String?
              return unless data = @data
              data["iso_code"].as_s if data["iso_code"]?
            end
          {% elsif method == :names %}
            def name(locale = DEFAULT_LOCALE) : String?
              return unless data = @data
              data["names"][locale].as_s if data["names"][locale]?
            end
        
            def names : Hash(String, String)?
              return unless data = @data
              result = {} of String => String
        
              data["names"].as_h.each do |k, v|
                result[k] = v.as_s
              end
        
              result
            end
          {% end %}
        {% end %}
      end
    {% end %}
  {% end %}
end