require "ipaddress"
require "./reader"

module MaxMindDB
  class Database
    def initialize(@db_path : String)
      @reader = Reader.new(@db_path)
    end

    def get(query : String | Int)
      @reader.get(address(query))
    end

    def metadata
      @reader.metadata
    end

    def inspect(io : IO)
      io << "#<#{self.class}:0x#{self.object_id.to_s(16)}\n\t@db_path: " << @db_path << ">"
    end

    private def address(query : String | Int)
      ip_address = IPAddress.new(query)

      if ip_address.is_a?(IPAddress::IPv4)
        ip_address.as(IPAddress::IPv4)
      elsif ip_address.is_a?(IPAddress::IPv6)
        ip_address.as(IPAddress::IPv6)
      else
        raise ArgumentError.new("Invalid IP address")
      end
    end
  end
end
