# encoding: ASCII-8BIT
# The above line allows concatenation of constant strings like ".pb.rb" to
# maintain the internal format of the buffers, rather than converting the
# buffer to US-ASCII

require 'beefcake'
require 'stringio'

class CodeGeneratorRequest
  include Beefcake::Message


  class FieldDescriptorProto
    include Beefcake::Message

    module Type
      ## 0 is reserved for errors.
      ## Order is weird for historical reasons.
      TYPE_DOUBLE         = 1
      TYPE_FLOAT          = 2
      TYPE_INT64          = 3   ## Not ZigZag encoded.  Negative numbers
      ## take 10 bytes.  Use TYPE_SINT64 if negative
      ## values are likely.
      TYPE_UINT64         = 4
      TYPE_INT32          = 5   ## Not ZigZag encoded.  Negative numbers
      ## take 10 bytes.  Use TYPE_SINT32 if negative
      ## values are likely.
      TYPE_FIXED64        = 6
      TYPE_FIXED32        = 7
      TYPE_BOOL           = 8
      TYPE_STRING         = 9
      TYPE_GROUP          = 10 ## Tag-delimited aggregate.
      TYPE_MESSAGE        = 11 ## Length-delimited aggregate.

      ## New in version 2.
      TYPE_BYTES          = 12
      TYPE_UINT32         = 13
      TYPE_ENUM           = 14
      TYPE_SFIXED32       = 15
      TYPE_SFIXED64       = 16
      TYPE_SINT32         = 17 ## Uses ZigZag encoding.
      TYPE_SINT64         = 18 ## Uses ZigZag encoding.
    end

    module Label
      LABEL_OPTIONAL      = 1
      LABEL_REQUIRED      = 2
      LABEL_REPEATED      = 3
    end

    optional :name,   :string, 1
    optional :number, :int32,  3
    optional :label,  Label,  4

    ## If type_name is set, this need not be set.  If both this and type_name
    ## are set, this must be either TYPE_ENUM or TYPE_MESSAGE.
    optional :type, Type, 5

    ## For message and enum types, this is the name of the type.  If the name
    ## starts with a '.', it is fully-qualified.  Otherwise, C++-like scoping
    ## rules are used to find the type (i.e. first the nested types within this
    ## message are searched, then within the parent, on up to the root
    ## namespace).
    optional :type_name, :string, 6

    ## For extensions, this is the name of the type being extended.  It is
    ## resolved in the same manner as type_name.
    optional :extended, :string, 2

    ## For numeric types, contains the original text representation of the value.
    ## For booleans, "true" or "false".
    ## For strings, contains the default text contents (not escaped in any way).
    ## For bytes, contains the C escaped value.  All bytes >= 128 are escaped.
    optional :default_value, :string, 7
  end


  class EnumValueDescriptorProto
    include Beefcake::Message

    optional :name,   :string, 1
    optional :number, :int32,  2
    # optional EnumValueOptions options = 3;
  end

  class EnumDescriptorProto
    include Beefcake::Message

    optional :name, :string, 1
    repeated :value, EnumValueDescriptorProto, 2
    # optional :options, EnumOptions, 3
  end

  class DescriptorProto
    include Beefcake::Message

    optional :name, :string, 1

    repeated :field,       FieldDescriptorProto, 2
    repeated :extended,    FieldDescriptorProto, 6
    repeated :nested_type, DescriptorProto,      3
    repeated :enum_type,   EnumDescriptorProto,  4
  end


  class FileDescriptorProto
    include Beefcake::Message

    optional :name, :string, 1       # file name, relative to root of source tree
    optional :package, :string, 2    # e.g. "foo", "foo.bar", etc.

    repeated :message_type, DescriptorProto, 4;
  end


  repeated :file_to_generate, :string, 1
  optional :parameter, :string, 2

  repeated :proto_file, FileDescriptorProto, 15
end

class CodeGeneratorResponse
  include Beefcake::Message

  class File
    include Beefcake::Message

    optional :name,    :string, 1
    optional :content, :string, 15
  end

  repeated :file, File, 15
end

module Beefcake
  class Generator

    L = CodeGeneratorRequest::FieldDescriptorProto::Label
    T = CodeGeneratorRequest::FieldDescriptorProto::Type


    def self.compile(ns, req)
      file = req.proto_file.map do |file|
        g = new(StringIO.new)
        g.compile(ns, file)

        g.c.rewind
        CodeGeneratorResponse::File.new(
          :name => File.basename(file.name, ".proto") + ".pb.rb",
          :content => g.c.read
        )
      end

      CodeGeneratorResponse.new(:file => file)
    end

    attr_reader :c

    def initialize(c)
      @c = c
      @n = 0
    end

    def file!(file)
      puts "## Generated from #{file.name} for #{file.package}"

      file.message_type.each do |mt|
        message!("", mt)
      end
    end

    def indent(&blk)
      @n += 1
      blk.call
      @n -= 1
    end

    def indent!(n)
      @n = n
    end

    def message!(pkg, mt)
      puts
      puts "class #{mt.name}"

      indent do
        puts "include Beefcake::Message"
        puts

        Array(mt.enum_type).each do |et|
          enum!(et)
        end

        ## Generate Types
        Array(mt.nested_type).each do |nt|
          message!(pkg, nt)
        end
        puts

        ## Generate fields
        Array(mt.field).each do |f|
          field!(pkg, f)
        end
        puts
      end

      puts "end"
    end

    def enum!(et)
      puts "module #{et.name}"
      indent do
        et.value.each do |v|
          puts "%s = %d" % [v.name, v.number]
        end
      end
      puts "end"
    end

    def field!(pkg, f)
      # Turn the label into Ruby
      label = name_for(f, L, f.label)

      # Turn the name into a Ruby
      name = ":#{f.name}"

      # Determine the type-name and convert to Ruby
      type = if f.type_name
        # We have a type_name so we will use it after converting to a
        # Ruby friendly version
        t = f.type_name
        t = t.gsub(pkg, "") # Remove the leading package name
        t = t.gsub(/^\.*/, "")       # Remove leading `.`s

        t.gsub(".", "::")  # Convert to Ruby namespacing syntax
      else
        ":#{name_for(f, T, f.type)}"
      end

      # Finally, generate the declaration
      out = "%s %s, %s, %d" % [label, name, type, f.number]

      if f.default_value
        v = case f.type
        when T::TYPE_ENUM
          "%s::%s" % [type, f.default_value]
        when T::TYPE_STRING, T::TYPE_BYTES
          '"%s"' % [f.default_value.gsub('"', '\"')]
        else
          f.default_value
        end

        out += ", :default => #{v}"
      end

      puts out
    end

    # Determines the name for a
    def name_for(b, mod, val)
      b.name_for(mod, val).to_s.gsub(/.*_/, "").downcase
    end

    def compile(ns, file)
      puts "## Generated from #{file.name} for #{file.package}"
      puts "require \"beefcake\""
      puts

      ns!(ns) do
        file.message_type.each do |mt|
          message!(file.package, mt)
        end
      end
    end

    def ns!(modules, &blk)
      if modules.empty?
        blk.call
      else
        puts "module #{modules.first}"
        indent do
          ns!(modules[1..-1], &blk)
        end
        puts "end"
      end
    end

    def puts(msg=nil)
      if msg
        c.puts(("  " * @n) + msg)
      else
        c.puts
      end
    end

  end
end
