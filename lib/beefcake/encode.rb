require 'beefcake/varint'
require 'beefcake/lendel'

module Beefcake
  module Encode
    def encode(w, value, name, type, fn)
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
    module_function :encode

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
    module_function :get_wire_type
  end
end
