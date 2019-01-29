require "spec"
require "../src/maxminddb"

def db_path(name : String)
  "spec/data/test-data/#{name}.mmdb"
end

def source_path(name : String)
  "spec/data/source-data/#{name}.json"
end
