module MaxMindDB
  alias MapNumeric = Int32|UInt16|UInt32|UInt64|UInt128|Float32|Float64
  alias MapValue = Nil|Bool|Bytes|String|MapNumeric|Hash(String, MapValue)|Array(MapValue)

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

  record Node, position : Int32, value : MapValue do
    def to_any
      Any.new(@value)
    end
  end
end
