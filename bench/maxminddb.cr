require "benchmark"
require "../src/maxminddb"

COUNT = 100_000

country_db = MaxMindDB.new("spec/cache/GeoLite2-Country.mmdb")
# city_db = MaxMindDB.new("spec/cache/GeoLite2-City.mmdb")

Benchmark.ips do |x|
  x.report("MaxMindDB.cr (Crystal):") do
    COUNT.times do
      country_db.lookup("187.47.6.0")
    end
  end
  x.report("MaxMindDB (Ruby):") do
  end
  x.report("MaxMindDB (Node):") do
  end
  x.report("MaxMindDB (Go):") do
  end
end
