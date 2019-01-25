require "spec"
require "../src/maxminddb"

DATABASES_PATH = "spec/databases"

Dir.glob("#{DATABASES_PATH}/*.mmdb.gz") do |file_path|
  unless File.writable?(DATABASES_PATH)
    raise "Invalid `#{DATABASES_PATH}` directory permissions"
  end

  Process.run("sh", {"-c", "gunzip -k #{file_path}"})
end

def db_path(name : String)
  path = "#{DATABASES_PATH}/#{name}.mmdb"

  unless File.readable?(path)
    raise "Invalid `#{path}` directory permissions"
  end

  path
end