module MaxMindDB
  class KmpBytes
    def self.search(haystack : Bytes, needle : Bytes): Array(Int32)
      matches = [] of Int32
  
      return matches unless haystack && needle
  
      key = 0
      table = table(needle)
  
      (1..haystack.size).each do |i|
        while key >= 0 && needle[key] != haystack[i - 1]
          key = table[key]
        end
  
        key += 1
  
        if key == needle.size
          matches << i - needle.size
          key = table[key]
        end
      end
  
      matches
    end
  
    private def self.table(needle : Bytes): Array(Int32)
      table = Array.new(needle.size + 1, -1)
      key = -1
  
      (1..needle.size).each do |i|
        while key >= 0 && needle[key] != needle[i - 1]
          key = table[key]
        end
  
        key += 1
        table[i] = key
      end
  
      table
    end
  end
end