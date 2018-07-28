require "./geoip2/root"

module MaxMindDB::Format::GeoIP2
  DEFAULT_LOCALE = "en"

  def self.new(data : Any)
    Root.new(data)
  end
end
