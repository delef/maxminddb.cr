module MaxMindDB::Format::GeoIP2::Entity
  class RepresentedCountry < Common
    def iso_code
      return unless data = @data
      data["iso_code"].as_s if data["iso_code"]?
    end
  end
end