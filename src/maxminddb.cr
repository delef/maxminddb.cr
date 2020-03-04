require "./maxminddb/reader"
require "./maxminddb/version"

module MaxMindDB
  class DatabaseError < Exception
  end

  class IPAddressError < Exception
  end

  def self.open(input : String | Bytes | IO::Memory, cache_max_size : Int32? = nil)
    Reader.new(input, cache_max_size)
  end
end
