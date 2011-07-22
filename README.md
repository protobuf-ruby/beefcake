# Beefcake (A sane Google Protocol Buffers library for Ruby)
## It's all about being Buf; ProtoBuf.

# Install

    $ gem install beefcake

# Example

    require 'beefcake'

    class Variety
      include Beefcake::Message

      # Required
      required :x, :int32, 1
      required :y, :int32, 2

      # Optional
      optional :tag, :string, 3

      # Repeated
      repeated :ary,  :fixed64, 4
      repeated :pary, :fixed64, 5, :packed => true

      # Enums - Simply use a Module (NOTE: defaults are optional)
      module Foonum
        A = 1
        B = 2
      end

      # As per the spec, defaults are only set at the end
      # of decoding a message, not on object creation.
      optional :foo, Foonum, 6, :default => Foonum::B
    end

    x = Variety.new :x => 1, :y => 2
    # or
    x = Variety.new
    x.x = 1
    x.y = 2

## Encoding

Any object responding to `<<` can accept encoding

    s = ""
    x.encode(s)
    p [:s, s]
    # or (because encode returns the string/stream)
    p [:s, x.encode]
    # or
    open("x.dat") do |f|
      x.encode(f)
    end

    # decode
    encoded = x.encode
    decoded = Variety.decode(encoded)
    p [:x, decoded]

    # decode merge
    Variety.decoded(more_data, decoded)

# Why?

  Ruby deserves and needs first-class ProtoBuf support.
  Other libs didn't feel very "Ruby" to me and were hard to parse.

# Generate code from `.proto` file

    $ protoc --beefcake_out output/path -I path/to/proto/files/dir path/to/proto/file

You can set the BEEFCAKE_NAMESPACE variable to generate the classes under a
desired namespace. (i.e. App::Foo::Bar)

# Misc

  This library was built with EventMachine in mind.  Not just blocking-IO.

# Dev

Source:

    $ git clone git://github.com/bmizerany/beefcake

## Testing:

    $ gem install turn
    $ cd /path/to/beefcake
    $ turn

## VMs:

Currently Beefcake is tested and working on:

* Ruby 1.8.6
* Ruby 1.8.7
* Ruby 1.9.2
* JRuby 1.5.6
* Rubinius edge


## Support Features

* Optional fields
* Required fields
* Repeated fields
* Packed Repeated Fields
* Varint fields
* 32-bit fields
* 64-bit fields
* Length delemited fields
* Embeded Messages
* Unknown fields are ignored (as per spec)
* Enums
* Defaults (i.e. `optional :foo, :string, :default => "bar"`)


## Future

* Imports
* Use package in generation
* Groups (would be nice for accessing older protos)

# Further Reading

http://code.google.com/apis/protocolbuffers/docs/encoding.html

# Thank You

Keith Rarick (kr) for help with encoding/decoding.
Aman Gupta (tmm1) for help with cross VM support and performance enhancements.
