module MaxMindDB::Format::GeoIP2::Entity
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
end