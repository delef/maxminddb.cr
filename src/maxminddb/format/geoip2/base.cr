module MaxMindDB::Format::GeoIP2
  abstract class Base
    getter data

    def initialize(@data : Any?)
    end

    def found?
      @data.try &.found?
    end

    def empty?
      @data.try &.empty?
    end

    def inspect(io)
      @data.inspect(io)
    end
  end
end