require "./any"
require "./cache"

module MaxMindDB
  class Decoder
    private CACHE_MAX_SIZE        = 6_000
    private SIZE_BASE_VALUES      = [0, 29, 285, 65_821]
    private POINTER_VALUE_OFFSETS = [0, 0, 1 << 11, (1 << 19) + ((1) << 11), 0]

    private enum DataType
      Extended
      Pointer
      Utf8
      Double
      Bytes
      Uint16
      Uint32
      Map
      Int32
      Uint64
      Uint128
      Array
      Container
      EndMarker
      Boolean
      Float
    end

    private struct Node
      getter value

      def initialize(@value : Any::Type)
      end

      def as_any
        Any.new(@value)
      end
    end

    def initialize(
      @buffer : Buffer,
      @pointer_base : Int32,
      cache_max_size : Int32? = nil,
      @pointer_test : Bool = false
    )
      @cache = Cache(Int32, Node).new(cache_max_size || CACHE_MAX_SIZE)
    end

    def decode(offset : Int32) : Node
      if offset >= @buffer.size
        raise InvalidDatabaseException.new(
          "The MaxMind DB file's data section contains bad data: " +
          "pointer larger than the database."
        )
      end

      @buffer.position = offset
      decode
    end

    def decode : Node
      ctrl_byte = @buffer.read_byte.to_i32
      data_type = DataType.new(ctrl_byte >> 5)
      data_type = read_extended if data_type.extended?

      size = size_from_ctrl_byte(ctrl_byte, data_type)
      decode_by_type(data_type, size)
    end

    # Each output data field has an associated type,
    # and that type is encoded as a number that begins the data field.
    # Some types are variable length.
    #
    # In those cases, the type indicator is also followed by a length.
    # The data payload always comes at the end of the field.
    private def decode_by_type(data_type : DataType, size : Int32) : Node
      case data_type
      when .pointer?
        decode_pointer(size)
      when .utf8?
        decode_string(size)
      when .double?
        decode_double(size)
      when .bytes?
        decode_bytes(size)
      when .uint16?
        decode_uint16(size)
      when .uint32?
        decode_uint32(size)
      when .uint64?
        decode_uint64(size)
      when .uint128?
        decode_uint128(size)
      when .map?
        decode_map(size)
      when .int32?
        decode_int32(size)
      when .array?
        decode_array(size)
      when .container?
        raise InvalidDatabaseException.new("Сontainers are not currently supported")
      when .end_marker?
        Node.new nil
      when .boolean?
        Node.new !size.zero?
      when .float?
        decode_float(size)
      else
        raise InvalidDatabaseException.new("Unknown or unexpected type: #{data_type.to_i}")
      end
    end

    # Control byte provides information about
    # the field’s data type and payload size.
    private def size_from_ctrl_byte(ctrl_byte : Int32, data_type : DataType) : Int32
      size = ctrl_byte & 0x1f

      return size if data_type.pointer? || size < 29

      bytes_size = size - 28
      SIZE_BASE_VALUES[bytes_size] + decode_int(bytes_size)
    end

    # With an extended type, the type number in the second byte is
    # the number minus 7.
    # In other words, an array (type 11) will be stored with a 0
    # for the type in the first byte and a 4 in the second.
    private def read_extended : DataType
      type_number = 7 + @buffer.read_byte

      if type_number < 8
        raise InvalidDatabaseException.new(
          "Something went horribly wrong in the decoder. " +
          "An extended type resolved to a type number < 8" +
          " (#{type_number})."
        )
      end

      DataType.new(type_number)
    end

    # Pointers are a special case, we don't read the next 'size' bytes, we
    # use the size to determine the length of the pointer and then follow it.
    private def decode_pointer(ctrl_byte : Int32) : Node
      pointer_size = ((ctrl_byte >> 3) & 0x3) + 1
      base = pointer_size == 4 ? 0 : (ctrl_byte & 0x7)
      packed = decode_int(pointer_size, base)
      pointer = @pointer_base + packed + POINTER_VALUE_OFFSETS[pointer_size]

      return Node.new(pointer) if @pointer_test

      position = @buffer.position
      node = @cache.fetch(pointer) { |offset| decode(offset) }
      @buffer.position = position

      node
    end

    # A variable length byte sequence that contains valid utf8.
    # If the length is zero then this is an empty string.
    private def decode_string(size : Int32) : Node
      Node.new String.new(@buffer.read(size))
    end

    # Decode integer for external use
    def decode_int(offset : Int32, size : Int32, base : Int) : Int
      @buffer[offset, size].reduce(base) { |r, v| (r << 8) | v }
    end

    # Decode integer
    private def decode_int(size : Int32, base : Int = 0) : Int
      @buffer.read(size).reduce(base) { |r, v| (r << 8) | v }
    end

    private def decode_uint16(size : Int32) : Node
      Node.new decode_int(size, 0u16)
    end

    private def decode_uint32(size : Int32) : Node
      Node.new decode_int(size, 0u32)
    end

    private def decode_uint64(size : Int32) : Node
      Node.new decode_int(size, 0u64)
    end

    private def decode_uint128(size : Int32) : Node
      Node.new decode_int(size, 0u128)
    end

    private def decode_int32(size : Int32) : Node
      Node.new decode_int(size, 0)
    end

    private def decode_double(size : Int32) : Node
      if size != 8
        raise InvalidDatabaseException.new(
          "The MaxMind DB file's data section contains bad data: " +
          "invalid size of double."
        )
      end

      Node.new IO::ByteFormat::BigEndian.decode(Float64, @buffer.read(size))
    end

    private def decode_float(size : Int32) : Node
      if size != 4
        raise InvalidDatabaseException.new(
          "The MaxMind DB file's data section contains bad data: " +
          "invalid size of float."
        )
      end

      Node.new IO::ByteFormat::BigEndian.decode(Float32, @buffer.read(size))
    end

    private def decode_bytes(size : Int32) : Node
      Node.new @buffer.read(size).to_a.map { |e| Any.new(e.to_i) }
    end

    private def decode_array(size : Int32) : Node
      Node.new Array(Any).new(size) { decode.as_any }
    end

    private def decode_map(size : Int32) : Node
      map = Hash(String, Any).new

      size.times.each do
        map[decode.value.as(String)] = decode.as_any
      end

      Node.new map
    end
  end
end
