require "ipaddress"
require "./maxminddb/reader"
require "./maxminddb/format/*"

module MaxMindDB
  class InvalidDatabaseException < Exception
  end

  class Database
    def initialize(@db_path : String)
      @reader = Reader.new(@db_path)
    end

    def get(query : String | Int)
      parsed = IPAddress.new(query)

      address =
        if parsed.is_a?(IPAddress::IPv4)
          parsed.as(IPAddress::IPv4)
        elsif parsed.is_a?(IPAddress::IPv6)
          parsed.as(IPAddress::IPv6)
        else
          raise ArgumentError.new("Invalid IP address")
        end

      @reader.get(address)
    end

    def metadata
      @reader.metadata
    end

    def inspect(io : IO)
      io << "#<#{self.class}:0x#{self.object_id.to_s(16)}\n\t@db_path: " << @db_path << ">"
    end
  end

  class GeoIP2 < Database
    def get(query : String | Int)
      Format::GeoIP2.new(super(query))
    end
  end

  def self.new(db_path : String)
    Database.new(db_path)
  end
end
