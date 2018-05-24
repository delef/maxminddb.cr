require "ipaddress"

require "./maxminddb/kmp_bytes"
require "./maxminddb/consts"
require "./maxminddb/types"
require "./maxminddb/any"
require "./maxminddb/decoder"
require "./maxminddb/reader"
require "./maxminddb/format/*"

module MaxMindDB
  class Database
    def initialize(@db_path : String)
      @reader = Reader.new(@db_path)
    end

    def lookup(addr : String)
      ip_address = IPAddress.new(addr)
      decimal =
        if ip_address.ipv4?
          ip_address.as(IPAddress::IPv4).to_u32
        elsif ip_address.ipv6?
          ip_address.as(IPAddress::IPv6).to_u128
        else
          raise ArgumentError.new("Invalid IP address")
        end

      @reader.lookup(decimal)
    end

    def lookup(addr : UInt32|UInt128|BigInt)
      @reader.lookup(addr)
    end

    def metadata
      @reader.metadata
    end

    def inspect(io : IO)
      io << "#<#{self.class}:0x#{self.object_id.to_s(16)}\n\t@db_path: " << @db_path << ">"
    end
  end

  class GeoIP2 < Database
    def lookup(addr : String)
      Format::GeoIP2.new(super(addr))
    end

    def lookup(addr : UInt32|UInt128|BigInt)
      Format::GeoIP2.new(super(addr))
    end
  end

  def self.new(db_path : String)
    Database.new(db_path)
  end
end