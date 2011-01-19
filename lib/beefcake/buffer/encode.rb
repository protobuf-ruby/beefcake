require 'beefcake/buffer/base'

module Beefcake

  class Buffer

    def append_info(fn, wire)
      self << ((fn << 3) | wire)
    end

    def append_lendel(o)
      append_uint64(o.length)
      self << o
    end

    def append_fixed32(n, tag=false)
      if ! (MinUint32..MaxUint32).include?(n)
        raise OutOfRange, n
      end

      self << [n].pack("V")
    end

    def append_fixed64(n)
      if ! (MinUint64..MaxUint64).include?(n)
        raise OutOfRange, n
      end

      self << [n & 0xFFFFFFFF, n >> 32].pack("VV")
    end

    def append_varint32(n)
      if ! (MinInt32..MaxInt32).include?(n)
        raise OutOfRange, n
      end

      append_varint64(n)
    end

    def append_uint32(n)
      if ! (MinUint32..MaxUint32).include?(n)
        raise OutOfRange, n
      end

      append_uint64(n)
    end

    def append_varint64(n)
      if ! (MinInt64..MaxInt64).include?(n)
        raise OutOfRange, n
      end

      if n < 0
        n += (1 << 64)
      end

      append_uint64(n)
    end

    def append_uint64(n)
      if ! (MinUint64..MaxUint64).include?(n)
        raise OutOfRange, n
      end

      while true
        bits = n & 0x7F
        n >>= 7
        if n == 0
          return self << bits
        end
        self << (bits | 0x80)
      end
    end

    def append_float(n)
      self << [n].pack("e")
    end

    def append_double(n)
      self << [n].pack("E")
    end

    def append_bool(n)
      append_varint64(n ? 1 : 0)
    end

  end

end
