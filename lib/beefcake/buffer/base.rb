module Beefcake

  class Buffer

    MinUint32 =  0
    MaxUint32 =  (1 << 32)-1
    MinInt32  = -(1 << 31)
    MaxInt32  =  (1 << 31)-1

    MinUint64 =  0
    MaxUint64 =  (1 << 64)-1
    MinInt64  = -(1 << 63)
    MaxInt64  =  (1 << 63)-1

    WIRES = {
      :int32    => 0,
      :uint32   => 0,
      :sint32   => 0,
      :int64    => 0,
      :uint64   => 0,
      :sint64   => 0,
      :bool     => 0,
      :fixed64  => 1,
      :sfixed64 => 1,
      :double   => 1,
      :string   => 2,
      :bytes    => 2,
      :fixed32  => 5,
      :sfixed32 => 5,
      :float    => 5,
    }

    def self.wire_for(type)
      wire = WIRES[type]

      if wire
        wire
      elsif Class === type && encodable?(type)
        2
      elsif Module === type
        0
      else
        raise UnknownType, type
      end
    end

    def self.encodable?(type)
      return false if ! type.is_a?(Class)
      pims = type.public_instance_methods
      pims.include?(:encode) || pims.include?("encode")
    end

    attr_reader :buf

    alias :to_s   :buf
    alias :to_str :buf

    class OutOfRangeError < StandardError
      def initialize(n)
        super("Value of of range: %d" % [n])
      end
    end

    class BufferOverflowError < StandardError
      def initialize(s)
        super("Too many bytes read for %s" % [s])
      end
    end

    class UnknownType < StandardError
      def initialize(s)
        super("Unknown type '%s'" % [s])
      end
    end

    def initialize(buf="")
      self.buf = buf
    end

    def buf=(new_buf)
      @buf = new_buf.force_encoding('BINARY')
      @cursor = 0
    end

    def length
      remain = buf.slice(@cursor..-1)
      remain.respond_to?(:bytesize) ? remain.bytesize : remain.length
    end

    def <<(bytes)
      bytes = bytes.force_encoding('BINARY') if bytes.respond_to? :force_encoding
      buf << bytes
    end

    def read(n)
      case n
      when Class
        n.decode(read_string)
      when Symbol
        __send__("read_#{n}")
      when Module
        read_uint64
      else
        read_slice = buf.slice(@cursor, n)
        @cursor += n
        return read_slice
      end
    end

  end

end
