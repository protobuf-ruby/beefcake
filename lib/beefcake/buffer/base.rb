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

    def self.wire_for(type)
      case type
      when Class
        if encodable?(type)
          2
        else
          raise UnknownType, type
        end
      when :int32, :uint32, :sint32, :int64, :uint64, :sint64, :bool, Module
        0
      when :fixed64, :sfixed64, :double
        1
      when :string, :bytes
        2
      when :fixed32, :sfixed32, :float
        5
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
      @cursor = 0
    end

    if ''.respond_to?(:force_encoding)
      def buf=(new_buf)
        @buf = new_buf.force_encoding('BINARY')
        @cursor = 0
      end
    else
      def buf=(new_buf)
        @buf = new_buf
        @cursor = 0
      end
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
