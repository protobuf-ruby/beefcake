# Beefcake (A sane Google Protocol Buffers library for Ruby)
## It's all about being Buf; ProtoBuf.

# Install

```shell
$ gem install beefcake
```

# Example

```ruby
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

# You can create a new message with hash arguments:
x = Variety.new :x => 1, :y => 2

# You can set fields individually using accessor methods:
x = Variety.new
x.x = 1
x.y = 2

# And you can access fields using Hash syntax:
x[:x] # => 1
x[:y] = 4
x # => <Variety x: 1, y: 4>
```

## Encoding

Any object responding to `<<` can accept encoding

```ruby
x # => <Variety x: 1, y: 2>
    
# For example, you can encode into a String:
s = ""
x.encode(s)
s # => "\b\x01\x10\x02)\0"

# If you don't encode into anything, a new Beefcake::Buffer will be returned:
x.encode # => #<Beefcake::Buffer:0x007fbfe1867ab0 @buf="\b\x01\x10\x02)\0">

# And that buffer can be converted to a String:
x.encode.to_s # => "\b\x01\x10\x02)\0"
```

### Decoding

```ruby
x # => <Variety x: 1, y: 2>

# You can decode from a Beefcake::Buffer
encoded = x.encode
Variety.decode(encoded) # => <Variety x: 1, y: 2, pary: [], foo: B(2)>

# Decoding from a String works the same way:
Variety.decode(encoded.to_s) # => <Variety x: 1, y: 2, pary: [], foo: B(2)>

# You can update a Beefcake::Message instance with new data too:
new_data = Variety.new(x: 12345, y: 2).encode
Variety.decoded(new_data, x)
x # => <Variety x: 12345, y: 2, pary: [], foo: B(2)>
```

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

    $ git clone https://github.com/protobuf-ruby/beefcake.git

## Testing:

    $ rake test

Beefcake conducts continuous integration on [Travis CI](http://travis-ci.org).
The current build status for HEAD is [![Build Status](https://travis-ci.org/protobuf-ruby/beefcake.png)](https://travis-ci.org/protobuf-ruby/beefcake).

All pull requests automatically trigger a build request.  Please ensure that
tests succeed.

## VMs:

Currently Beefcake is tested and working on:

* Ruby 1.8.6
* Ruby 1.8.7
* Ruby 1.9.2
* Ruby 2.0.0
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
* Length-delimited fields
* Embedded Messages
* Unknown fields are ignored (as per spec)
* Enums
* Defaults (i.e. `optional :foo, :string, :default => "bar"`)
* Varint-encoded length-delimited message streams


## Future

* Imports
* Use package in generation
* Groups (would be nice for accessing older protos)

# Further Reading

http://code.google.com/apis/protocolbuffers/docs/encoding.html

# Thank You

Keith Rarick (kr) for help with encoding/decoding.
Aman Gupta (tmm1) for help with cross VM support and performance enhancements.
