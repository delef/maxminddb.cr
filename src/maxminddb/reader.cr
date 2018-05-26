module MaxMindDB
  class Reader
    @metadata : Any? = nil
    @ip_version : Int32? = nil
    @node_count : Int32? = nil
    @node_byte_size : Int32? = nil

    def initialize(@db_path : String)
      raise ArgumentError.new("Database not found") unless File.exists?(db_path)

      size = File.size(@db_path)
      @buffer = Bytes.new(size)
      File.open(@db_path, "rb") { |file| file.read_fully(@buffer) }

      @decoder = Decoder.new(@buffer)
    end

    def metadata
      @metadata ||=
        begin
          offset = KmpBytes.search(@buffer, METADATA_BEGIN_MARKER)[0]
          raise ArgumentError.new("Invalid file format") unless offset
          offset += METADATA_BEGIN_MARKER.size

          @decoder.decode(offset, 0).to_any
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

    def read_node(node, flag)
      position = node_byte_size * node
      middle = @buffer[position + record_byte_size].to_i32 if node_byte_size.odd?
      
      if flag.zero? # LEFT node
        val = @decoder.fetch(position, 0, record_byte_size)
        val += ((middle & 0xf0) << 20) if middle
      else # RIGHT node
        val = @decoder.fetch(position + node_byte_size - record_byte_size, 0, record_byte_size)
        val += ((middle & 0xf) << 24) if middle
      end

      val
    end

    def lookup(addr : UInt32|UInt128|BigInt)
      node = 0

      (start_index...128).each do |i|
        flag = (addr >> (127 - i)) & 1
        next_node = read_node(node, flag)

        raise ArgumentError.new("Invalid file format") if next_node.zero?

        if next_node < node_count
          node = next_node
        else
          base = search_tree_size + DATA_SEPARATOR_SIZE
          position = (next_node - node_count) - DATA_SEPARATOR_SIZE
          
          return @decoder.decode(position, base).to_any
        end
      end

      raise ArgumentError.new("Invalid file format")
    end
  end
end