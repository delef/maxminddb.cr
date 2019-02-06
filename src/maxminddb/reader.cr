require "./decoder"
require "./metadata"

module MaxMindDB
  class Reader
    private DATA_SEPARATOR_SIZE = 16

    getter metadata

    def initialize(db_path : String)
      unless File.exists?(db_path)
        raise InvalidDatabaseException.new("Database not found")
      end

      @buffer = Bytes.new(File.size(db_path))
      File.open(db_path, "rb") { |file| file.read_fully(@buffer) }

      @metadata = Metadata.new(@buffer)
      @decoder = Decoder.new(@buffer, @metadata.search_tree_size + DATA_SEPARATOR_SIZE)
    end

    def get(address : IPAddress)
      pointer = find_address_in_tree(address)

      if pointer > 0
        resolve_data_pointer(pointer)
      else
        Any.new({} of String => Any)
      end
    end

    private def find_address_in_tree(address : IPAddress) : Int32
      raw_address = address.data
      start_node = find_start_node(raw_address.size)
      node_number = start_node

      (@metadata.tree_depth - start_node).times.each do |i|
        break if node_number >= @metadata.node_count

        index = raw_address[i >> 3]
        bit = 1 & (index >> 7 - (i % 8))

        node_number = read_node(node_number, bit)
      end

      if node_number == @metadata.node_count # record is empty
        0
      elsif node_number > @metadata.node_count # is a data pointer
        node_number
      else
        raise InvalidDatabaseException.new("Something bad happened")
      end
    end

    private def find_start_node(address_size)
      @metadata.ip_version == 6 && address_size == 4 ? 128 - 32 : 0
    end

    private def read_node(node_number : Int, index : Int) : Int
      base_offset = node_number * @metadata.node_byte_size

      case @metadata.record_size
      when 24
        @decoder.decode_int(base_offset + index * 3, 3)
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
        @decoder.decode_int(base_offset + index * 4, 4)
      else
        raise InvalidDatabaseException.new(
          "Unknown record size: #{@metadata.record_byte_size}"
        )
      end
    end

    private def resolve_data_pointer(pointer : Int)
      resolved = pointer - @metadata.node_count + @metadata.search_tree_size

      if resolved > @buffer.size
        raise InvalidDatabaseException.new(
          "The MaxMind DB file's search tree is corrupt: " +
          "contains pointer larger than the database."
        )
      end

      @decoder.decode(resolved).to_any
    end
  end
end
