require "./maxminddb/database"
require "./maxminddb/version"

module MaxMindDB
  class InvalidDatabaseException < Exception
  end

  def self.open(db_path : String)
    Database.new(db_path)
  end
end
