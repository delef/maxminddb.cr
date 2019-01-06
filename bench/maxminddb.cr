require "benchmark"
require "../src/maxminddb"

COUNT = 100_000

country_db = MaxMindDB.new("spec/cache/GeoLite2-Country.mmdb")
# city_db = MaxMindDB.new("spec/cache/GeoLite2-City.mmdb")

Benchmark.bm do |x|
  x.report("country:") do
    COUNT.times do
      country_db.lookup("187.47.6.0")
    end
  end
  # x.report("city:") do
  #   COUNT.times do
  #     country_db.lookup("187.47.6.0")
  #   end
  # end
end