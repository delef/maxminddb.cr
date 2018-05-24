module MaxMindDB
  struct Any
    getter raw

    def initialize(@raw : MapValue)
    end

    def [](key : String) : Any
      case data = @raw
      when Hash
        Any.new(data[key])
      else
        raise "Expected Hash for #[](key : String), not #{data.class}"
      end
    end

    def []?(key : String) : Any?
      case data = @raw
      when Hash
        if value = data[key]?
          Any.new(value)
        end
      else
        raise "Expected Hash for #[](key : String), not #{data.class}"
      end
    end

    def [](index : Int) : Any
      case data = @raw
      when Array
        Any.new(data[index])
      else
        raise "Expected Array for #[](index : Int), not #{data.class}"
      end
    end

    def []?(index : Int) : Any?
      case data = @raw
      when Array
        value = data[index]?
        value.nil? ? nil : Any.new(value)
      else
        raise "Expected Array for #[](index : Int), not #{data.class}"
      end
    end

    def size : Int
      case object = @raw
      when Array
        object.size
      when Hash
        object.size
      else
        raise "Expected Array or Hash for #size, not #{object.class}"
      end
    end

    def each : Nil
      case object = @raw
      when Array
        object.each do |v|
          yield(v)
        end
      when Hash
        object.each do |k, v|
          yield({k, v})
        end
      else
        raise "Expected Array or Hash for #each, not #{object.class}"
      end
    end

    def as_nil : Nil
      @raw.as(Nil)
    end
  
    def as_bool : Bool
      @raw.as(Bool)
    end
  
    def as_bool? : Bool?
      as_bool if @raw.is_a?(Bool)
    end

    def as_i : Int32
      @raw.as(Int).to_i
    end

    def as_i? : Int32?
      as_i if @raw.is_a?(Int)
    end
    
    def as_u : UInt32
      @raw.as(UInt32).to_u32
    end
  
    def as_u? : UInt32?
      as_u32 if @raw.is_a?(UInt32)
    end

    def as_u16 : UInt16
      @raw.as(UInt16).to_u16
    end

    def as_u16? : UInt16?
      as_u16 if @raw.is_a?(UInt16)
    end

    def as_u64 : UInt64
      @raw.as(UInt64).to_u64
    end

    def as_u64? : UInt64?
      as_u64 if @raw.is_a?(UInt64)
    end

    def as_u128 : BigInt
      @raw.as(BigInt).to_big_i
    end

    def as_u128? : BigInt?
      as_u128 if @raw.is_a?(BigInt)
    end

    def as_f : Float64
      @raw.as(Float).to_f
    end

    def as_f? : Float64?
      as_f if @raw.is_a?(Float64)
    end

    def as_f32 : Float32
      @raw.as(Float).to_f32
    end

    def as_f32? : Float32?
      as_f32 if (@raw.is_a?(Float32) || @raw.is_a?(Float64))
    end

    def as_s : String
      @raw.as(String)
    end

    def as_s? : String?
      as_s if @raw.is_a?(String)
    end
    
    def as_a : Array(MapValue)
      @raw.as(Array)
    end

    def as_a? : Array(MapValue)?
      as_a if @raw.is_a?(Array)
    end

    def as_h : Hash(String, MapValue)
      @raw.as(Hash)
    end

    def as_h? : Hash(String, MapValue)?
      as_h if @raw.is_a?(Hash)
    end

    def found?
      size > 0
    end

    def empty?
      !found?
    end

    def inspect(io)
      @raw.inspect(io)
    end
  end
end
