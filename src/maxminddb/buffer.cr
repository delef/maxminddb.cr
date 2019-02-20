module MaxMindDB
  struct Buffer
    getter size : Int32
    property position : Int32

    def initialize(@bytes : Bytes)
      @size = @bytes.size
      @position = 0
    end

    def read(count : Int32) : Bytes
      value = @bytes[@position, count]
      @position += count
      value
    end

    def read_byte : UInt8
      value = @bytes[@position]
      @position += 1
      value
    end

    def rindex(value : Bytes) : Int32?
      vsize = value.size

      (@size - vsize - 1).downto(0) do |i|
        return i if @bytes[i, vsize] == value
      end
    end

    def to_slice
      @bytes
    end

    macro method_missing(call)
      @bytes.{{call.name}}({{*call.args}})
    end
  end
end
