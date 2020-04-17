require "socket/address"

class MaxMindDB::IPAddress
  @ip_address : Socket::IPAddress

  def initialize(address : String)
    @ip_address = Socket::IPAddress.new(address, 0)
  end

  def to_bytes : Bytes?
    case @ip_address.family
    when .inet6?
      ipv6_to_bytes
    else
      ipv4_to_bytes
    end
  end

  macro method_missing(call)
    @ip_address.{{call.name.id}}
  end

  private def ipv4_to_bytes : Bytes
    buffer = IO::Memory.new 4

    split = @ip_address.address.split "."
    split.each { |part| buffer.write Bytes[part.to_u8] }

    buffer.to_slice
  end

  private def ipv6_to_bytes : Bytes?
    return unless @ip_address.family.inet6?

    pointer = @ip_address.to_unsafe.as LibC::SockaddrIn6*
    memory = IO::Memory.new 16

    {% if flag? :darwin %}
      ipv6_address = pointer.value.sin6_addr.__u6_addr.__u6_addr8
      memory.write ipv6_address.to_slice
    {% else %}
      ipv6_address = pointer.value.sin6_addr.__in6_u.__u6_addr8
      memory.write ipv6_address.to_slice
    {% end %}

    memory.to_slice
  end
end
