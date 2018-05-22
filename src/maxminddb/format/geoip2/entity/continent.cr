module MaxMindDB::Format::GeoIP2::Entity
  class Continent < Common
    def code
      return unless data = @data
      data["iso_code"].as_s
    end
  end
end