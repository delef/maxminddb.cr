require "./any"

module MaxMindDB
  struct Cache(K, V)
    def initialize(@max_size : Int32)
      @storage = {} of K => V
    end

    def fetch(key : K, &block : K -> V) : V
      value = @storage[key]?

      unless value
        value = yield(key)
        @storage[key] = value unless full?
      end

      value
    end

    def full?
      @storage.size >= @max_size
    end
  end
end