require "spec"
require "../src/maxminddb"

def get_db(db_link, filename)
  return if File.exists?("spec/cache/#{filename.gsub(".gz", "")}")

  Process.run "sh", {"-c", "curl #{db_link} -o spec/cache/#{filename}"}
  Process.run "sh", {"-c", "gunzip spec/cache/#{filename}"}

  File.delete("spec/cache/#{filename}") if File.exists?("spec/cache/#{filename}")
end

links = {
  country: "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz",
  city:    "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz",
}

get_db(links[:country], links[:country].split("/").last)
get_db(links[:city], links[:city].split("/").last)
