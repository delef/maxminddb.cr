require "immutable"
require "./any"

module MaxMindDB
  struct Cache(K, V)
    property capacity : Int32
    property storage : Immutable::Map(K, V)

    def initialize(@capacity : Int32)
      @storage = Immutable::Map(K, V).new
    end

    def fetch(key : K, &block : K -> V) : V
      value = storage[key]?
      return value if value

      value = yield(key)

      self.storage =
        if full?
          Immutable::Map(K, V).new.set(key, value)
        else
          storage.set(key, value)
        end

      value
    end

    def full?
      storage.size >= @capacity
    end
  end
end
