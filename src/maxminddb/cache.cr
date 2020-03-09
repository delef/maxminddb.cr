require "immutable"
require "./any"

module MaxMindDB
  class Cache(K, V)
    property capacity : Int32
    property storage : Immutable::Map(K, V)

    def initialize(@capacity : Int32)
      @storage = empty_map
    end

    def fetch(key : K, & : K -> V) : V
      value = storage[key]?
      return value if value

      value = yield(key)

      self.storage =
        if full?
          empty_map.set(key, value)
        else
          storage.set(key, value)
        end

      value
    end

    def full?
      storage.size >= @capacity
    end

    private def empty_map
      Immutable::Map(K, V).new
    end
  end
end
