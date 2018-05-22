require "ipaddress"

require "./maxminddb/kmp_bytes"
require "./maxminddb/consts"
require "./maxminddb/types"
require "./maxminddb/any"
require "./maxminddb/decoder"
require "./maxminddb/format/*"

module MaxMindDB
  class Database
    def initialize(@db_path : String)
      raise ArgumentError.new("Database not found") unless File.exists?(db_path)

      size = File.size(@db_path)
      @buffer = Bytes.new(size)
      File.open(@db_path, "rb") { |file| file.read_fully(@buffer) }

      @decoder = Decoder.new(@buffer)
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

      lookup(decimal)
    end

    def lookup(addr : UInt32|UInt128|BigInt)
      node = 0

      (@decoder.start_index...128).each do |i|
        flag = (addr >> (127 - i)) & 1
        next_node = @decoder.read(node, flag)

        raise ArgumentError.new("Invalid file format") if next_node.zero?

        if next_node < @decoder.node_count
          node = next_node
        else
          base = @decoder.search_tree_size + DATA_SEPARATOR_SIZE
          position = (next_node - @decoder.node_count) - DATA_SEPARATOR_SIZE
          
          return @decoder.build(position, base).to_any
        end
      end

      raise ArgumentError.new("Invalid file format")
    end

    def metadata
      @decoder.metadata
    end

    def inspect(io : IO)
      io << "#<#{self.class}:0x#{self.object_id.to_s(16)}\n\t@db_path: " << @db_path << ">"
    end
  end

  class GeoIP2 < Database
    def lookup(addr : UInt32|UInt128|BigInt)
      Format::GeoIP2.new(super(addr))
    end
  end

  def self.new(db_path : String)
    Database.new(db_path)
  end
end