require "ipaddress"
require "./buffer"
require "./decoder"
require "./metadata"

module MaxMindDB
  class Reader
    private DATA_SEPARATOR_SIZE = 16

    @ipv4_start_node : Int32?

    getter metadata

    def initialize(db_path : String, cache_max_size : Int32? = nil)
      unless File.exists?(db_path)
        raise InvalidDatabaseException.new("Database not found")
      end

      initialize(read_file(db_path), cache_max_size)
    end

    def initialize(db : Bytes | IO::Memory, cache_max_size : Int32? = nil)
      @buffer = Buffer.new(db.to_slice)
      @metadata = Metadata.new(@buffer)

      pointer_base = @metadata.search_tree_size + DATA_SEPARATOR_SIZE
      @decoder = Decoder.new(@buffer, pointer_base, cache_max_size)
    end

    def get(address : String | Int)
      get(IPAddress.parse(address))
    end

    def get(address : IPAddress)
      if address.is_a?(IPAddress::IPv6) && @metadata.ip_version == 4
        raise ArgumentError.new(
          "Error looking up '#{address.to_s}'. " +
          "You attempted to look up an IPv6 address in an IPv4-only database."
        )
      end

      pointer = find_address_in_tree(address)

      if pointer > 0
        resolve_data_pointer(pointer)
      else
        Any.new({} of String => Any)
      end
    end

    def inspect(io : IO)
      @metadata.inspect(io)
    end

    private def read_file(file_name : String) : Bytes
      file = File.new(file_name, "rb")
      bytes = Bytes.new(file.size)

      begin
        file.read_fully(bytes)
      ensure
        file.close
      end

      bytes
    end

    private def find_address_in_tree(address : IPAddress) : Int32
      raw_address = address.data
      bit_size = raw_address.size * 8
      node_number = start_node(bit_size)

      bit_size.times do |i|
        break if node_number >= @metadata.node_count

        index = raw_address[i >> 3]
        bit = 1 & (index >> 7 - (i % 8))

        node_number = read_node(node_number, bit)
      end

      if node_number == @metadata.node_count
        0
      elsif node_number > @metadata.node_count
        node_number
      else
        raise InvalidDatabaseException.new("Something bad happened")
      end
    end

    private def start_node(bit_size) : Int32
      unless @metadata.ip_version == 6 && bit_size == 32
        return 0
      end

      if ipv4_start_node = @ipv4_start_node
        return ipv4_start_node
      end

      node_number = 0

      96.times do
        break if node_number >= @metadata.node_count
        node_number = read_node(node_number, 0)
      end

      @ipv4_start_node = node_number
    end

    private def read_node(node_number : Int, index : Int) : Int32
      base_offset = node_number * @metadata.node_byte_size

      case @metadata.record_size
      when 24
        @decoder.decode_int(base_offset + index * 3, 3, 0)
      when 28
        middle_byte = @buffer[base_offset + 3].to_i32

        middle =
          if index.zero?
            (0xf0 & middle_byte) >> 4
          else
            middle_byte & 0x0f
          end

        @decoder.decode_int(base_offset + index * 4, 3, middle)
      when 32
        @decoder.decode_int(base_offset + index * 4, 4, 0)
      else
        raise InvalidDatabaseException.new(
          "Unknown record size: #{@metadata.record_size}"
        )
      end
    end

    private def resolve_data_pointer(pointer : Int) : Any
      offset = pointer - @metadata.node_count + @metadata.search_tree_size

      if offset > @buffer.size
        raise InvalidDatabaseException.new(
          "The MaxMind DB file's search tree is corrupt: " +
          "contains pointer larger than the database."
        )
      end

      @decoder.decode(offset).to_any
    end
  end
end
