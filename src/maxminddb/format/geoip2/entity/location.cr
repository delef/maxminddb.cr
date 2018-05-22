module MaxMindDB::Format::GeoIP2::Entity
  class Location < Base
    def accuracy_radius
      return unless data = @data
      data["accuracy_radius"].as_i
    end

    def latitude
      return unless data = @data
      data["latitude"].as_f
    end

    def longitude
      return unless data = @data
      data["longitude"].as_f
    end

    def metro_code
      return unless data = @data
      data["metro_code"].as_i
    end

    def time_zone
      return unless data = @data
      data["time_zone"].as_s
    end
  end
end