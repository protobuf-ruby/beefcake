require 'beefcake/buffer'

module Beefcake
  module Message

    class InvalidValue < StandardError
      def initialize(name, val)
        super("Invalid Value given for `#{name}`: #{val.inspect}")
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

      def field(rule, name, type, fn, opts)
        fields[fn] = Field.new(rule, name, type, fn, opts)
        attr_accessor name
      end

      def fields
        @fields ||= {}
      end
    end

    def self.included(o)
      o.extend Dsl
    end

    def initialize(attrs={})
      fields.values.each do |fld|
        self[fld.name] = attrs[fld.name] || fld.opts[:default]
      end
    end

    def fields
      self.class.fields
    end

    def [](k)
      __send__(k)
    end

    def []=(k, v)
      __send__(k.to_s+"=", v)
    end

    def encode(buf = Buffer.new)
      if ! buf.respond_to?(:<<)
        raise ArgumentError, "buf doesn't respond to `<<`"
      end

      if ! buf.is_a?(Buffer)
        buf = Buffer.new(buf)
      end

      # TODO: Error if any required fields at nil

      fields.values.sort.each do |fld|
        val = __send__(fld.name)
        case fld.type
        when Class # encodable
          # TODO: raise error if type != val.class
          buf.append_tagged_string(fld.fn, val.encode)
        when Module # enum
          if ! valid_enum?(fld.type, val)
            raise InvalidValue.new(fld.name, val)
          end

          buf.append_tagged_uint64(fld.fn, val)
        else
          buf.__send__("append_tagged_"+fld.type.to_s, fld.fn, val)
        end
      end

      buf
    end

    def valid_enum?(mod, val)
      mod.constants.any? {|name| mod.const_get(name) == val }
    end
  end
end
