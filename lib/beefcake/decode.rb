require 'stringio'

module Beefcake
  module Decode
    extend self

    def decode(r, obj, flds)
    end

    def decode!(r, type)
      if ! r.respond_to?(:read)
        r = StringIO.new(r)
      end

      u    = decode_varint(r)
      wire = (u & 0x7)
      fn   = (u >> 3)
      x    = decode_raw(r, wire)
      val  = convert(x, type)

      [fn, val]
    end

    def convert(x, to)
      case to
      when :int32, :uint32, :int64, :uint64, :fixed32
        x
      when :sint32
        (x & 1) == 0 ? x >> 1 : ~x >> 1
      when :sfixed32
        (x & 1) == 0 ? x >> 1 : ~x >> 1
      else
        raise UnknownType, type
      end
    end

    def decode_raw(r, wire)
      case wire
      when 0
        decode_varint(r)
      when 5
        decode_fixed32(r)
      else
        raise UnknownWireType, wire
      end
    end

    def decode_varint(r)
      s = x = 0
      while b = r.read(1)[0]
        x |= (b & 0x7F) << s
        break if (b & 0x80) == 0
        s += 7
      end
      x
    end

    def decode_fixed32(r)
      s = r.read(4)
      s.unpack("V").first
    end
  end
end
