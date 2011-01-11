require 'beefcake/varint'
require 'beefcake/lendel'

module Beefcake
  class Message

    ##
    # Errors
    class UnknownWireType < StandardError
    end

    class UnkownType < StandardError
    end

    class MissingField < StandardError
      def initialize(name)
        super("Field not set: name:#{name}")
      end
    end


    ##
    # Stores field information and is sortable
    class Field < Struct.new(:rule, :name, :type, :fn)
      def <=>(o)
        fn <=> o.fn
      end
    end


    ##
    # Class level DSL

    def self.fields
      @fields ||= []
    end

    def self.field(rule, name, type, fn)
      # Create a field with it's initial value set to nil
      fields << Field.new(rule, name, type, fn)
      attr_accessor name
    end

    def self.required(name, type, fn)
      field(:required, name, type, fn)
    end

    def self.optional(name, type, fn)
      field(:optional, name, type, fn)
    end


    ##
    # Decoding
    def self.decode(r)
      msg = self.new
      while ! r.empty?
        decode!(r, msg)
      end
      msg
    end

    def self.decode!(r, msg)
      u    = Varint.decode(r)
      wire = (u & 0x7)
      fn   = (u >> 3)

      field = fields.find {|fld| fld.fn == fn }

      # TODO: if field[WIRE] != wire ????
      decoder = get_decoder(wire)

      # TODO: if field.nil? skip
      value = decoder.decode(r)

      msg.send(field.name.to_s+"=", value)

      msg
    end

    def self.get_decoder(wire)
      case wire
      when 0
        Varint
      when 2
        Lendel
      else
        raise UnknownWireType, wire
      end
    end

    ##
    # Instance Methods
    def initialize(attrs={})
      attrs.each {|n, v| __send__(n.to_s+"=", v) }
    end

    def fields
      self.class.fields
    end

    def validate!
      fields.each do |f|
        if f.rule == :required && __send__(f.name).nil?
          raise MissingField, f.name
        end
      end
    end

    ##
    # Encoding
    def encode(w)
      validate!
      fields.sort.each do |f|
        value = __send__(f.name)
        encode!(w, value, *f.values[1..-1])
      end
      w # Always return the writer from encodes
    end

    # TODO:
    # This could be broken out somewhere and
    # tested in isolation now.
    def encode!(w, value, name, type, fn)
      if value.nil?
        return
      end

      wire = get_wire_type(type)

      # TODO: if required but nil panic

      # It's safe to write to the wire.
      # We will start with the header information
      w << ((fn << 3) | wire)

      case wire
      when 0
        Varint.encode(w, value)
      when 2
        Lendel.encode(w, value)
      else
        raise UnkownWireType, wire
      end
    end

    def get_wire_type(type)
      # Handle embeded Messages
      if type.is_a?(Class)
        return 2
      end

      case type
      when :int32, :int64, :uint32, :uint64, :sint32, :sint64, :bool, :enum
        0
      when :fixed64, :sfixed64, :double
        1
      when :string, :bytes # TODO: packed repeated fields
        2
      when :fixed32, :sfixed32, :float
        5
      else
        raise UnknownType, type
      end
    end

  end
end
