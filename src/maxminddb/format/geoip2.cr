require "./geoip2/root"

module MaxMindDB::Format::GeoIP2
  def self.new(data : Any)
    Root.new(data)
  end
end