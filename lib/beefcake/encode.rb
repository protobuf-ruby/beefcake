require 'beefcake/varint'
require 'beefcake/lendel'
require 'beefcake/errors'

module Beefcake
  module Encode
    extend self

    ##
    # Encodes an object `obj` to `w` according to fields `flds` after checking
    # with `validate!` that it's safe to do so.
    #
    # `flds` Array
    #     [[:required, :a, :int32, 1], [:optional, :tag, :string, 2]]
    #
    # `obj` Must respond to `[]`
    def encode(w, obj, flds)
      validate!(obj, flds)
      flds.each do |_, name, *rest|
        p [name, rest]
        encode!(w, obj[name], *rest)
      end
      w
    end

    ##
    # Encodes a single field to `w`
    # `w`    ~`<<`
    # `val`  Object
    # `type` Symbol
    # `fn`   Integer
    def encode!(w, val, type, fn)
      return if val.nil?

      wire = get_wire_type(type)

      # It's safe to write to the wire.
      # We will start with the header information
      w << ((fn << 3) | wire)

      case wire
      when 0
        Varint.encode(w, val)
      when 2
        Lendel.encode(w, val)
      else
        raise UnkownWireType, wire
      end
    end

    ##
    # Validates the existance of required fields. If any field is required but
    # does not contain a value in `obj` this will raise a MissingField error.
    def validate!(obj, flds)
      flds.each do |rule, name|
        if rule == :required && obj[name].nil?
          raise MissingField, name
        end
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
