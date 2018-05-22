module MaxMindDB::Format::GeoIP2::Entity
  class RegisteredCountry < Common
    def iso_code
      return unless data = @data
      data["iso_code"].as_s
    end
  end
end