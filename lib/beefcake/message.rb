require 'beefcake/errors'
require 'beefcake/encode'
require 'beefcake/decode'

module Beefcake
  class Message

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


    def self.decode(r)
      Decode.decode(r, self.new)
    end

    ##
    # Instance Methods
    def initialize(attrs={})
      attrs.each {|n, v| __send__(n.to_s+"=", v) }
    end

    def fields
      self.class.fields
    end

    def [](k)
      __send__(k)
    end

    ##
    # Encoding
    def encode(w)
      flds = fields.sort.map(&:values)
      Encode.encode(w, self, flds)
      w # Always return the writer from encodes
    end

  end
end
