require "crystal/datum"

struct MaxMindDB::Any
  Crystal.datum(
    types: {
      nil: Nil,
      bool: Bool,
      i: Int32,
      u16: UInt16,
      u32: UInt32,
      u64: UInt64,
      u128: UInt128,
      f: Float32,
      f64: Float64,
      s: String
    },
    hash_key_type: String,
    immutable: false
  )

  def as_i : Int32
    @raw.as(Int).to_i
  end

  def as_i? : Int32?
    as_i if @raw.is_a?(Int)
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
