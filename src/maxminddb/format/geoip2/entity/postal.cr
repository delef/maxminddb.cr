module MaxMindDB::Format::GeoIP2::Entity
  class Postal < Base
    def code
      return unless data = @data
      data["code"].as_s
    end
  end
end