require 'beefcake/buffer/base'

module Beefcake

  class Buffer

    def read_info
      n = read_uint64
      [n >> 3, n & 0x7]
    end

    def read_fixed32
      bytes = read(4)
      bytes.unpack("V").first
    end

    def read_fixed64
      bytes = read(8)
      x, y = bytes.unpack("VV")
      x + (y << 32)
    end

    def read_varint32
      n = read_varint!
      if n > MaxInt64
        n -= (1 << 64)
      end
      n
    end

    def read_uint32
      read_varint!
    end

    def read_varint64
      n = read_varint!
      if n > MaxInt64
        n -= (1 << 64)
      end
      n
    end

    def read_uint64
      read_varint!
    end

    def read_varint!
      n = shift = 0
      while true
        if shift >= 64
          raise BufferOverflow, "varint"
        end
        b = buf.slice!(0)
        n |= ((b & 0x7F) << shift)
        shift += 7
        if (b & 0x80) == 0
          return n
        end
      end
    end

    def read_float
      bytes = read(4)
      bytes.unpack("e").first
    end

    def read_double
      bytes = read(8)
      bytes.unpack("E").first
    end

    def read_bool
      read_varint32 != 0
    end

  end

end
