module Beefcake
  module Decode
    def decode(r, msg)
      while ! r.empty?
        u    = Varint.decode(r)
        wire = (u & 0x7)
        fn   = (u >> 3)

        field = msg.fields.find {|fld| fld.fn == fn }

        # TODO: if field[WIRE] != wire ????
        decoder = get_decoder(wire)

        # TODO: if field.nil? skip
        value = decoder.decode(r)

        msg.send(field.name.to_s+"=", value)
      end
      msg
    end
    module_function :decode

    def get_decoder(wire)
      case wire
      when 0
        Varint
      when 2
        Lendel
      else
        raise UnknownWireType, wire
      end
    end
    module_function :get_decoder
  end
end
