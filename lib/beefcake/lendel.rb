require 'beefcake/varint'

module Beefcake
  module Lendel
    Wire = 2

    def self.encode(w, v)
      Varint.encode(w, v.length)
      if v.respond_to?(:encode)
        v.encode(w)
      else
        w << v
      end
    end

    def self.decode(r)
      len = Varint.decode(r)
      r.slice!(0, len)
    end
  end
end
