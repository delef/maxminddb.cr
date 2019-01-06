require "spec"
require "../src/maxminddb"

def get_db(remote_link)
  cache_dir = "spec/cache"
  filename  = remote_link.split("/").last

  if File.exists?("#{cache_dir}/#{filename.gsub(".gz", "")}")
    return
  end

  Dir.mkdir(cache_dir) unless Dir.exists?(cache_dir)

  unless File.writable?(cache_dir)
    raise "Invalid `/spec` directory permissions"
  end

  Process.run("sh", {"-c", "curl #{remote_link} -o spec/cache/#{filename}"})
  Process.run("sh", {"-c", "gunzip spec/cache/#{filename}"})
end

[
  "http://geolite.maxmind.com/download/geoip/database/GeoLite2-Country.mmdb.gz",
  "http://geolite.maxmind.com/download/geoip/database/GeoLite2-City.mmdb.gz"
].each { |remote_link| get_db(remote_link) }
