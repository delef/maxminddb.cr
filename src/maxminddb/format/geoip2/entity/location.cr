module MaxMindDB::Format::GeoIP2::Entity
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
end