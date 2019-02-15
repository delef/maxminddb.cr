require "./maxminddb/reader"
require "./maxminddb/version"

module MaxMindDB
  class InvalidDatabaseException < Exception
  end

  def self.open(db_path : String)
    Reader.new(db_path)
  end
end
