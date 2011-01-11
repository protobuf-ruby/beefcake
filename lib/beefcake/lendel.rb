require 'beefcake/varint'

module Beefcake
  module Lendel
    Wire = 2

    def self.encode(w, v)
      if v.respond_to?(:encode)
        v = v.encode("")
      end

      Varint.encode(w, v.length)
      w << v
    end

    def self.decode(r)
      len = Varint.decode(r)
      r.slice!(0, len)
    end
  end
end
