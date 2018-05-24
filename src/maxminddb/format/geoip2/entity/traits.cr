module MaxMindDB::Format::GeoIP2::Entity
  class Traits < Base
    def iso_code
      return unless data = @data
      data["is_satellite_provider"].as_bool
    end
  end
end