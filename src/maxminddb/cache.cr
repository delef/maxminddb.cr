require "./any"

class MaxMindDB::Cache(K, V)
  property capacity : Int32
  property storage : Hash(K, V)
  property mutex : Mutex

  def initialize(@capacity : Int32)
    @storage = Hash(K, V).new
    @mutex = Mutex.new :unchecked
  end

  def fetch(key : K, & : K -> V) : V
    value = @mutex.synchronize { storage[key]? }
    return value if value

    value = yield(key)
    return value if capacity.zero?

    @mutex.synchronize do
      self.storage.clear if full?
      self.storage[key] = value
    end

    value
  end

  def full?
    storage.size >= @capacity
  end
end
