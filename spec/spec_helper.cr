require "spec"
require "../src/maxminddb"

Dir.glob(["spec/databases/*.mmdb.gz", "spec/sources/*.json.gz"]) do |file_path|
  next if File.exists?(file_path.gsub(".gz", ""))

  dir = file_path.split('/').tap(&.pop).join('/')

  unless File.writable?(dir)
    raise "Invalid `#{dir}` directory permissions"
  end

  Process.run("sh", {"-c", "gunzip -k #{file_path}"})
end

def db_path(name : String)
  path = "spec/databases/#{name}.mmdb"

  unless File.exists?(path)
    raise "Invalid `#{path}`. No such file or directory."
  end

  path
end

def source_path(name : String)
  path = "spec/sources/#{name}.json"

  unless File.exists?(path)
    raise "Invalid `#{path}`. No such file or directory."
  end

  path
end
