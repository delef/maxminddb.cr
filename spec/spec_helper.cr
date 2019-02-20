require "spec"
require "../src/maxminddb"

def db_path(name : String)
  path = "spec/data/test-data/"

  if name.includes?(".")
    path += name
  else
    path += "#{name}.mmdb"
  end

  path
end
