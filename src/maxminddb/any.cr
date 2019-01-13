module MaxMindDB
  struct Any
    alias Type = Nil | Bool | Bytes | String | Int32 | UInt16 |
                 UInt32 | UInt64 | UInt128 | Float32 | Float64 |
                 Hash(String, Any) | Array(Any)

    getter raw : Type
    def_hash raw

    def initialize(@raw : Type)
    end

    # Assumes the underlying value is a `Hash` and returns the element
    # with the given key.
    # Raises if the underlying value is not a `Hash`.
    def [](key : String | Symbol) : Any
      case object = @raw
      when Hash
        object[key.to_s]
      else
        raise "Expected Hash for #[](key : String), not #{object.class}"
      end
    end

    # Assumes the underlying value is a `Hash` and returns the element
    # with the given key, or `nil` if the key is not present.
    # Raises if the underlying value is not a `Hash`.
    def []?(key : String | Symbol) : Any?
      case object = @raw
      when Hash
        object[key.to_s]?
      else
        raise "Expected Hash for #[](key : String), not #{object.class}"
      end
    end

    # Assumes the underlying value is an `Array` and returns the element
    # at the given index.
    # Raises if the underlying value is not an `Array`.
    def [](index : Int) : Any
      case object = @raw
      when Array
        object[index]
      else
        raise "Expected Array for #[](index : Int), not #{object.class}"
      end
    end

    # Assumes the underlying value is an `Array` and returns the element
    # at the given index, or `nil` if out of bounds.
    # Raises if the underlying value is not an `Array`.
    def []?(index : Int) : Any?
      case object = @raw
      when Array
        object[index]
      else
        raise "Expected Array for #[](index : Int), not #{object.class}"
      end
    end

    # Assumes the underlying value is an `Array` or `Hash` and returns its size.
    # Raises if the underlying value is not an `Array` or `Hash`.
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

    def as_a : Array(Any)
      @raw.as(Array)
    end

    def as_a? : Array(Any)?
      as_a if @raw.is_a?(Array)
    end

    def as_h : Hash(String, Any)
      @raw.as(Hash)
    end

    def as_h? : Hash(String, Any)?
      as_h if @raw.is_a?(Hash)
    end

    def found?
      size > 0
    end

    def empty?
      !found?
    end

    def to_json(json : ::JSON::Builder)
      raw.to_json(json)
    end

    def inspect(io)
      @raw.inspect(io)
    end
  end
end

class Object
  def ===(other : MaxMindDB::Any)
    self === other.raw
  end
end

struct Value
  def ==(other : MaxMindDB::Any)
    self == other.raw
  end
end

class Reference
  def ==(other : MaxMindDB::Any)
    self == other.raw
  end
end

class Array
  def ==(other : MaxMindDB::Any)
    self == other.raw
  end
end

class Hash
  def ==(other : MaxMindDB::Any)
    self == other.raw
  end
end

class Regex
  def ===(other : MaxMindDB::Any)
    value = self === other.raw
    $~ = $~
    value
  end
end
