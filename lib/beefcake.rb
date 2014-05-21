require 'beefcake/buffer'

module Beefcake
  module Message

    class WrongTypeError < StandardError
      def initialize(name, exp, got)
        super("Wrong type `#{got}` given for (#{name}).  Expected #{exp}")
      end
    end


    class InvalidValueError < StandardError
      def initialize(name, val)
        super("Invalid Value given for `#{name}`: #{val.inspect}")
      end
    end


    class RequiredFieldNotSetError < StandardError
      def initialize(name)
        super("Field #{name} is required but nil")
      end
    end


    class Field < Struct.new(:rule, :name, :type, :fn, :opts)
      def <=>(o)
        fn <=> o.fn
      end
    end


    module Dsl
      def required(name, type, fn, opts={})
        field(:required, name, type, fn, opts)
      end

      def repeated(name, type, fn, opts={})
        field(:repeated, name, type, fn, opts)
      end

      def optional(name, type, fn, opts={})
        field(:optional, name, type, fn, opts)
      end

      def field(rule, name, type, fn, opts)
        fields[fn] = Field.new(rule, name, type, fn, opts)
        attr_accessor name
      end

      def fields
        @fields ||= {}
      end
    end

    module Encode

      def encode(buf = Buffer.new)
        validate!

        if ! buf.respond_to?(:<<)
          raise ArgumentError, "buf doesn't respond to `<<`"
        end

        if ! buf.is_a?(Buffer)
          buf = Buffer.new(buf)
        end

        # TODO: Error if any required fields at nil

        _fields.values.sort.each do |fld|
          if fld.opts[:packed]
            bytes = encode!(Buffer.new, fld, 0)
            buf.append_info(fld.fn, Buffer.wire_for(fld.type))
            buf.append_uint64(bytes.length)
            buf << bytes
          else
            encode!(buf, fld, fld.fn)
          end
        end

        buf
      end

      def encode!(buf, fld, fn)
        v = self[fld.name]
        v = v.is_a?(Array) ? v : [v]

        v.compact.each do |val|
          case fld.type
          when Class # encodable
            # TODO: raise error if type != val.class
            buf.append(:string, val.encode, fn)
          when Module # enum
            if ! valid_enum?(fld.type, val)
              raise InvalidValueError.new(fld.name, val)
            end

            buf.append(:int32, val, fn)
          else
            buf.append(fld.type, val, fn)
          end
        end

        buf
      end

      def write_delimited(buf = Buffer.new)
        if ! buf.respond_to?(:<<)
          raise ArgumentError, "buf doesn't respond to `<<`"
        end

        if ! buf.is_a?(Buffer)
          buf = Buffer.new(buf)
        end

        buf.append_bytes(encode)

        buf
      end

      def valid_enum?(mod, val)
        !!name_for(mod, val)
      end

      def name_for(mod, val)
        mod.constants.each do |name|
          if mod.const_get(name) == val
            return name
          end
        end
        nil
      end

      def validate!
        _fields.values.each do |fld|
          if fld.rule == :required && self[fld.name].nil?
            raise RequiredFieldNotSetError, fld.name
          end
        end
      end

    end


    module Decode
      def decode(buf, o=self.new)
        if ! buf.is_a?(Buffer)
          buf = Buffer.new(buf)
        end

        # TODO: test for incomplete buffer
        while buf.length > 0
          fn, wire = buf.read_info

          fld = fields[fn]

          # We don't have a field for with index fn.
          # Ignore this data and move on.
          if fld.nil?
            buf.skip(wire)
            next
          end

          exp = Buffer.wire_for(fld.type)
          if wire != exp
            raise WrongTypeError.new(fld.name, exp, wire)
          end

          if fld.rule == :repeated && fld.opts[:packed]
            len = buf.read_uint64
            tmp = Buffer.new(buf.read(len))
            o[fld.name] ||= []
            while tmp.length > 0
              o[fld.name] << tmp.read(fld.type)
            end
          elsif fld.rule == :repeated
            val = buf.read(fld.type)
            (o[fld.name] ||= []) << val
          else
            val = buf.read(fld.type)
            o[fld.name] = val
          end
        end

        # Set defaults
        fields.values.each do |f|
          next if o[f.name] == false
          o[f.name] ||= f.opts[:default]
        end

        o.validate!

        o
      end

      def read_delimited(buf, o=self.new)
        if ! buf.is_a?(Buffer)
          buf = Buffer.new(buf)
        end

        return if buf.length == 0

        n = buf.read_int64
        tmp = Buffer.new(buf.read(n))

        decode(tmp, o)
      end
    end


    def self.included(o)
      o.extend Dsl
      o.extend Decode
      o.send(:include, Encode)
    end

    def initialize(attrs={})
      _fields.values.each do |fld|
        self[fld.name] = attrs[fld.name]
      end
    end

    def _fields
      self.class.fields
    end

    alias :fields :_fields

    def [](k)
      __send__(k)
    end

    def []=(k, v)
      __send__("#{k}=", v)
    end

    def ==(o)
      return false if (o == nil) || (o == false)
      return false unless o.is_a? self.class
      _fields.values.all? {|fld| self[fld.name] == o[fld.name] }
    end

    def inspect
      set = _fields.values.select {|fld| self[fld.name] != nil }

      flds = set.map do |fld|
        val = self[fld.name]

        case fld.type
        when Class
          "#{fld.name}: #{val.inspect}"
        when Module
          title = name_for(fld.type, val) || "-NA-"
          "#{fld.name}: #{title}(#{val.inspect})"
        else
          "#{fld.name}: #{val.inspect}"
        end
      end

      "<#{self.class.name} #{flds.join(", ")}>"
    end

    def to_hash
      _fields.values.inject({}) do |h, fld|
        value = self[fld.name]
        unless value.nil?
          h[fld.name] = value
        end
        h
      end
    end

  end

end
