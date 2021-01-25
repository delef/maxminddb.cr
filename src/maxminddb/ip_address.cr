require "socket/address"

class MaxMindDB::IPAddress
  @ip_address : Socket::IPAddress
  
  def initialize(address : String)
    @ip_address = Socket::IPAddress.new(address, 0)
  end

  def to_bytes : Bytes?
    case @ip_address.family
    when .inet6?
      Socket::IPAddress.ipv6_to_bytes(@ip_address)
    else
      Socket::IPAddress.ipv4_to_bytes(@ip_address)
    end
  end

  macro method_missing(call)
    @ip_address.{{call.name.id}}
  end
end
