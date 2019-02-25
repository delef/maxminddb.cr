module MaxMindDB
  struct Buffer
    getter size : Int32
    property position : Int32

    def initialize(@bytes : Bytes)
      @size = @bytes.size
      @position = 0
    end

    # Reads *size* bytes from this bytes buffer.
    # Returns empty `Bytes` if and only if there is no
    # more data to read.
    def read(size : Int32) : Bytes
      new_position = @position + size

      if @size >= new_position 
        value = @bytes[@position, size]
        @position = new_position
      else
        value = Bytes.new(0)
      end
      
      value
    end

    # Read one byte from bytes buffer
    # Returns 0 if and only if there is no
    # more data to read.
    def read_byte : UInt8
      if @size >= @position
        value = @bytes[@position]
        @position += 1
      else
        value = 0u8
      end

      value
    end

    # Returns the index of the _last_ appearance of *search*
    # in the bytes buffer
    #
    # ```
    # Buffer.new(Bytes[1, 2, 3, 4, 5]).rindex(Bytes[3, 4]) # => 2
    # ```
    def rindex(search : Bytes) : Int32?
      (@size - search.size - 1).downto(0) do |i|
        return i if @bytes[i, search.size] == search
      end
    end

    macro method_missing(call)
      @bytes.{{call.name}}({{*call.args}})
    end
  end
end
