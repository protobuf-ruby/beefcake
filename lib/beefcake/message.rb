require 'beefcake/encode'
require 'beefcake/decode'

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
        Encode.encode(w, value, *f.values[1..-1])
      end
      w # Always return the writer from encodes
    end

  end
end
