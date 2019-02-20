require "./maxminddb/reader"
require "./maxminddb/version"

module MaxMindDB
  class InvalidDatabaseException < Exception
  end

  def self.open(input : String | Bytes | IO::Memory, cache_max_size : Int32? = nil)
    Reader.new(input, cache_max_size)
  end
end
