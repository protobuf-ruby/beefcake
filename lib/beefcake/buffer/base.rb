module Beefcake

  class Buffer

    MinUint32 =  0
    MaxUint32 =  (1<<32)-1
    MinInt32  = -(1<<31)
    MaxInt32  =  (1<<31)-1

    MinUint64 =  0
    MaxUint64 =  (1<<64)-1
    MinInt64  = -(1<<63)
    MaxInt64  =  (1<<63)-1

    def self.wire_for(type)
      case type
      when :int32, :uint32, :sint32, :int64, :uint64, :sint64, :bool
        0
      when :fixed64, :sfixed64, :double
        1
      when :string, :bytes
        2
      when :fixed32, :sfixed32, :float
        5
      else
        p [:type, type]
        if encodable?(type)
          2
        else
          raise UnknownType, type
        end
      end
    end

    def self.encodable?(type)
      return false if ! type.is_a?(Class)
      pims = type.public_instance_methods.tap
      pims.include?(:encode) || pims.include?("encode")
    end

    attr_reader :buf

    alias :to_s   :buf
    alias :to_str :buf

    class OutOfRange < StandardError
      def initialize(n)
        super("Value of of range: %d" % [n])
      end
    end

    class BufferOverflow < StandardError
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
      @orig = buf
      @buf = buf
      clear!
    end

    def clear!
      @buf = @orig
    end

    def length
      @buf.length
    end

    def <<(bytes)
      buf << bytes
    end

    def read(n)
      buf.slice!(0, n)
    end

    def method_missing(s, *args)
      if s.to_s =~ /^append_tagged_(.*)$/
        fn   = args.shift
        wire = Buffer.wire_for($1.to_sym)

        append_info(fn, wire)
        __send__("append_#{$1}", *args)
      else
        super
      end
    end

  end

end
