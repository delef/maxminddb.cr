module MaxMindDB
  class Decoder
    @metadata : Any? = nil
    @ip_version : Int32? = nil
    @node_count : Int32? = nil
    @node_byte_size : Int32? = nil

    def initialize(@buffer : Bytes)
    end

    def metadata
      @metadata ||=
        begin
          offset = KmpBytes.search(@buffer, METADATA_BEGIN_MARKER)[0]
          raise ArgumentError.new("Invalid file format") unless offset
          offset += METADATA_BEGIN_MARKER.size

          build(offset, 0).to_any
        end
      @metadata.not_nil!
    end

    def ip_version
      @ip_version ||= metadata["ip_version"].as_i
      @ip_version.not_nil!
    end

    def node_count
      @node_count ||= metadata["node_count"].as_i
      @node_count.not_nil!
    end

    def node_byte_size
      @node_byte_size ||= metadata["record_size"].as_i * 2 / 8
      @node_byte_size.not_nil!
    end

    def start_index
      ip_version == 4 ? 96 : 0
    end

    def search_tree_size
      node_count * node_byte_size
    end

    def record_byte_size
      node_byte_size / 2
    end

    def version
      "#{@data["binary_format_major_version"]}.#{@data["binary_format_minor_version"]}"
    end

    def read(node, flag)
      position = node_byte_size * node
      middle = @buffer[position + record_byte_size].to_i32 if node_byte_size.odd?
      
      if flag.zero? # LEFT node
        val = fetch(position, 0)
        val += ((middle & 0xf0) << 20) if middle
      else # RIGHT node
        val = fetch(position + node_byte_size - record_byte_size, 0)
        val += ((middle & 0xf) << 24) if middle
      end

      val
    end

    def build(position : Int, offset : Int): Node
      ctrl = @buffer[position + offset]
      data_type = DataType.new(ctrl.to_i32 >> 5)
      position += 1

      if data_type.pointer?
        pointer(position, offset, ctrl)
      else
        if data_type.extended?
          data_type = DataType.new(7 + @buffer[position + offset].to_i32)
          position += 1
        end

        size = ctrl & 0x1f
        if size >= 29
          byte_size = size - 29 + 1
          val = fetch(position, offset, byte_size)
          position += byte_size
          size = val + SIZE_BASE_VALUES[byte_size]
        end

        case data_type
        when .utf8?
          val = String.new(@buffer[position + offset, size])
          Node.new(position + size, val)
        when .double?
          io  = IO::Memory.new(@buffer[position + offset, size])
          val = io.read_bytes(Float64, IO::ByteFormat::BigEndian)
          Node.new(position + size, val)
        when .bytes?
          val = @buffer[position + offset, size]
          Node.new(position + size, val)
        when .uint16?, .uint32?, .uint64?, .uint128?
          val = fetch(position, offset, size)
          Node.new(position + size, val)
        when .map?
          val = size.times.each_with_object({} of String => MapValue) do |_, map|
            key_node = build(position, offset)
            val_node = build(key_node.position, offset)
            position = val_node.position
            map[key_node.to_any.as_s] = val_node.value
          end

          Node.new(position, val)
        when .int32?
          v1 = (@buffer[position + offset, size].to_unsafe.as(Int32*)).value
          bits = size * 8
          val = (v1 & ~(1 << bits)) - (v1 & (1 << bits))

          Node.new(position + size, val)
        when .array?
          val = Array(MapValue).new(size) do
            node = build(position, offset)
            position = node.position
            node.value
          end

          Node.new(position, val)
        when .container?
          raise "Unsupport"
        when .end_marker?
          Node.new(position, nil)
        when .boolean?
          Node.new(position, !size.zero?)
        when .float?
          io  = IO::Memory.new(@buffer[position + offset, size])
          val = io.read_bytes(Float64, IO::ByteFormat::BigEndian)
          Node.new(position + size, val)
        else
          raise "Invalid file format"
        end
      end
    end

    private def pointer(position, offset, ctrl)
      size = ((ctrl >> 3) & 0x3) + 1
      v1 = ctrl.to_i32 & 0x7
      v2 = fetch(position, offset, size)
      pointer = (v1 << (8 * size)) + v2 + POINTER_BASE_VALUES[size]

      Node.new(position + size, build(pointer, offset).value)
    end

    private def fetch(position, offset, size = record_byte_size)
      bytes = @buffer[position + offset, size]
      bytes.reduce(0) { |r, v| (r << 8) + v }
    end
  end
end
