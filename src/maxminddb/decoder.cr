require "./any"
require "./cache"

module MaxMindDB
  class Decoder
    private CACHE_MAX_SIZE        = 6_000
    private SIZE_BASE_VALUES      = [0, 29, 285, 65_821]
    private POINTER_VALUE_OFFSETS = [0, 0, 1 << 11, (1 << 19) + ((1) << 11), 0]

    private enum DataType
      Extended,
      Pointer,
      Utf8,
      Double,
      Bytes,
      Uint16,
      Uint32,
      Map,
      Int32,
      Uint64,
      Uint128,
      Array,
      Container,
      EndMarker,
      Boolean,
      Float
    end

    private struct Node
      getter offset, value

      def initialize(@offset : Int32, @value : Any::Type)
      end

      def to_any
        Any.new(@value)
      end
    end

    def initialize(@bytes : Bytes, @base_offset : Int32, cache_max_size : Int32? = nil)
      @cache = Cache(Int32, Node).new(cache_max_size || CACHE_MAX_SIZE)
    end

    def decode(offset : Int32) : Node
      if offset >= @bytes.size
        raise InvalidDatabaseException.new(
          "The MaxMind DB file's data section contains bad data: " +
          "pointer larger than the database."
        )
      end

      ctrl_byte = @bytes[offset].to_i32
      data_type = DataType.new(ctrl_byte >> 5)
      offset += 1

      if data_type.pointer?
        pointer = decode_pointer(ctrl_byte, offset)
        target_offset = pointer.value.as(Int32)
        node = @cache.fetch(target_offset) { |offset| decode(offset) }

        return Node.new(pointer.offset, node.value)
      end

      if data_type.extended?
        offset, type_number = read_extended(offset)
        data_type = DataType.new(type_number)
      end

      offset, size = size_from_ctrl_byte(ctrl_byte, offset)
      decode_by_type(data_type, offset, size)
    end

    def decode_int(offset : Int32, size : Int32, base : Int32 = 0) : Int32
      @bytes[offset, size].reduce(base) { |r, v| (r << 8) | v.to_i32 }
    end

    private def decode_by_type(data_type : DataType, offset : Int32, size : Int32) : Node
      case data_type
      when .utf8?
        decode_string(offset, size)
      when .double?
        decode_float(offset, size)
      when .bytes?
        decode_bytes(offset, size)
      when .uint16?, .uint32?, .uint64?, .uint128?
        decode_uint(offset, size)
      when .map?
        decode_map(offset, size)
      when .int32?
        decode_int32(offset, size)
      when .array?
        decode_array(offset, size)
      when .container?
        raise InvalidDatabaseException.new("Сontainers are not currently supported")
      when .end_marker?
        Node.new(offset, nil)
      when .boolean?
        Node.new(offset, !size.zero?)
      when .float?
        decode_float(offset, size)
      else
        raise InvalidDatabaseException.new("Unknown or unexpected type: #{data_type.to_i}")
      end
    end

    private def size_from_ctrl_byte(ctrl_byte : Int32, offset : Int32) : Tuple(Int32, Int32)
      size = ctrl_byte & 0x1f

      if size >= 29
        bytes_size = size - 29 + 1
        int = decode_int(offset, bytes_size)
        offset += bytes_size
        size = SIZE_BASE_VALUES[bytes_size] + int
      end

      {offset, size}
    end

    private def read_extended(offset : Int32) : Tuple(Int32, Int32)
      type_number = 7 + @bytes[offset]
      offset += 1

      if type_number < 8
        raise InvalidDatabaseException.new(
          "Something went horribly wrong in the decoder. " +
          "An extended type resolved to a type number < 8" +
          " (#{type_number})."
        )
      end

      {offset, type_number}
    end

    # Pointers are a special case, we don't read the next 'size' bytes, we
    # use the size to determine the length of the pointer and then follow it.
    private def decode_pointer(ctrl_byte : Int32, offset : Int32) : Node
      pointer_size = ((ctrl_byte >> 3) & 0x3) + 1
      base = pointer_size == 4 ? 0 : (ctrl_byte & 0x7)
      packed = decode_int(offset, pointer_size, base)
      pointer = packed + @base_offset + POINTER_VALUE_OFFSETS[pointer_size]

      Node.new(offset + pointer_size, pointer)
    end

    private def decode_string(offset : Int32, size : Int32) : Node
      Node.new(offset + size, String.new(@bytes[offset, size]))
    end

    private def decode_float(offset : Int, size : Int32) : Node
      io = IO::Memory.new(@bytes[offset, size])
      value = io.read_bytes(Float64, IO::ByteFormat::BigEndian)
      Node.new(offset + size, value)
    end

    private def decode_bytes(offset : Int32, size : Int32) : Node
      value = @bytes[offset, size].to_a.map { |e| Any.new(e.to_i) }
      Node.new(offset + size, value)
    end

    private def decode_uint(offset : Int32, size : Int32) : Node
      Node.new(offset + size, decode_int(offset, size))
    end

    private def decode_int32(offset : Int32, size : Int32) : Node
      Node.new(offset + size, decode_int(offset, size))
    end

    private def decode_array(offset : Int32, size : Int32) : Node
      value = [] of Any

      size.times.each do
        node = decode(offset)
        offset = node.offset

        value << node.to_any
      end

      Node.new(offset, value)
    end

    private def decode_map(offset : Int32, size : Int32) : Node
      map = {} of String => Any

      size.times.each do
        key_node = decode(offset)
        val_node = decode(key_node.offset)
        offset = val_node.offset

        map[key_node.value.as(String)] = val_node.to_any
      end

      Node.new(offset, map)
    end
  end
end
