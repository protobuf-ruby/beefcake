module Beefcake
  module Varint
    Wire = 0

    ##
    # A port of
    # http://code.google.com/p/goprotobuf/source/browse/proto/encode.go?r=387ab631eb2dcbebfd5b390bd999f3d657042608#77
    def self.encode(w, v)
      while v > 127
        w << (0x80 | (v&0x7F))
        v = v>>7
      end
      w << v
    end

    ##
    # A port of
    # http://code.google.com/p/goprotobuf/source/browse/proto/decode.go?r=387ab631eb2dcbebfd5b390bd999f3d657042608#62
    def self.decode(r)
      v = shift = 0
      while true
        if ! b = r.slice!(0)
          return 0
        end

        v |= (b & 0x7F) << shift
        if (b & 0x80) == 0
          break
        end
        shift += 7
      end
      v
    end
  end
end
