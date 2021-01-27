require "spec"
require "../src/maxminddb"

def db_path(name : String)
  path = "spec/data/test-data/#{name}"
  path += ".mmdb" unless name.includes?(".")
  path
end
