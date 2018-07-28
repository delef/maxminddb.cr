module MaxMindDB
  class Decoder
    enum DataType
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
      Float,
    end

    record Node, position : Int32, value : Any::Type do
      def to_any
        Any.new(@value)
      end
    end

    def initialize(@buffer : Bytes)
    end

    def decode(position : Int, offset : Int) : Node
      ctrl_byte = @buffer[position + offset]
      data_type = DataType.new(ctrl_byte.to_i32 >> 5)
      position, size = size_from_ctrl(ctrl_byte, position, offset)

      if data_type.extended?
        data_type = DataType.new(7 + @buffer[position + offset].to_i32)
        position += 1
      end

      case data_type
      when .pointer?                               then decode_pointer(position, offset, ctrl_byte)
      when .utf8?                                  then decode_string(position, offset, size)
      when .double?                                then decode_float(position, offset, size)
      when .bytes?                                 then decode_bytes(position, offset, size)
      when .uint16?, .uint32?, .uint64?, .uint128? then decode_uint(position, offset, size)
      when .map?                                   then decode_map(position, offset, size)
      when .int32?                                 then decode_int32(position, offset, size)
      when .array?                                 then decode_array(position, offset, size)
      when .container?                             then raise "Unsupport"
      when .end_marker?                            then Node.new(position, nil)
      when .boolean?                               then Node.new(position, !size.zero?)
      when .float?                                 then decode_float(position, offset, size)
      else
        raise "Invalid Database error: \"Unexpected type number #{data_type}\""
      end
    end

    def fetch(position, offset, size)
      bytes = @buffer[position + offset, size]
      bytes.reduce(0) { |r, v| (r << 8) + v }
    end

    private def size_from_ctrl(ctrl_byte, position, offset)
      position += 1
      size = ctrl_byte & 0x1f

      if size >= 29
        byte_size = size - 29 + 1
        val = fetch(position, offset, byte_size)
        position += byte_size
        size = val + SIZE_BASE_VALUES[byte_size]
      end

      {position, size}
    end

    private def decode_pointer(position, offset, ctrl_byte)
      size = ((ctrl_byte >> 3) & 0x3) + 1
      v1 = ctrl_byte.to_i32 & 0x7
      v2 = fetch(position, offset, size)
      pointer = (v1 << (8 * size)) + v2 + POINTER_BASE_VALUES[size]

      Node.new(position + size, decode(pointer, offset).value)
    end

    private def decode_map(position, offset, size)
      val = size.times.each_with_object({} of String => Any) do |_, map|
        key_node = decode(position, offset)
        val_node = decode(key_node.position, offset)
        position = val_node.position
        map[key_node.value.as(String)] = Any.new(val_node.value)
      end

      Node.new(position, val)
    end

    private def decode_string(position, offset, size)
      val = String.new(@buffer[position + offset, size])
      Node.new(position + size, val)
    end

    private def decode_float(position, offset, size)
      io = IO::Memory.new(@buffer[position + offset, size])
      val = io.read_bytes(Float64, IO::ByteFormat::BigEndian)
      Node.new(position + size, val)
    end

    private def decode_bytes(position, offset, size)
      val = @buffer[position + offset, size]
      Node.new(position + size, val)
    end

    private def decode_uint(position, offset, size)
      val = fetch(position, offset, size)
      Node.new(position + size, val)
    end

    private def decode_int32(position, offset, size)
      v1 = (@buffer[position + offset, size].to_unsafe.as(Int32*)).value
      bits = size * 8
      val = (v1 & ~(1 << bits)) - (v1 & (1 << bits))

      Node.new(position + size, val)
    end

    private def decode_array(position, offset, size)
      val = Array(Any).new(size) do
        node = decode(position, offset)
        position = node.position

        Any.new(node.value)
      end

      Node.new(position, val)
    end
  end
end
