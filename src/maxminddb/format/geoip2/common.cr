module MaxMindDB::Format::GeoIP2
  abstract class Common < Base
    DEFAULT_LOCALE = "en"

    def geoname_id : Int32?
      return unless data = @data
      data["geoname_id"].as_i if data["geoname_id"]?
    end

    def name(locale = DEFAULT_LOCALE) : String?
      return unless data = @data
      data["names"][locale].as_s if data["names"][locale]?
    end

    def names : Hash(String, String)?
      return unless data = @data
      result = {} of String => String

      data["names"].as_h.each do |k, v|
        result[k] = v.as(String)
      end

      result
    end
  end
end