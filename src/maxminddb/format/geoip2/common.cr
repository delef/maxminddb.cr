module MaxMindDB::Format::GeoIP2
  abstract class Common < Base
    def geoname_id
      return unless data = @data
      data["geoname_id"].as_i
    end

    def name(locale = DEFAULT_LOCALE)
      return unless data = @data
      data["names"][locale].as_s
    end

    def names
      return unless data = @data

      data["names"].as_h.map do |k, v|
        {k.as(String) => v.as(String)}
      end
    end
  end
end