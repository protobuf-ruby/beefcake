# Beefcake Release Notes

# 0.5.0 - 2013-12-20

Release 0.5.0 corrects a few behaviors.

* Drastically revised README, written by Tobias "grobie" Schmidt
* Output fewer newlines in generated files, fixed by Tobias "grobie" Schmidt
* Don't crash when attempting to reencode frozen strings,
  found thanks to Kyle "Aphyr" Kingsbury
* Return `nil` instead of raising a generic Ruby error when trying to
  decode a zero-length buffer, fixed by Tobias "grobie" Schmidt 

# 0.4.0 - 2013-10-10

Release 0.4.0 is the first with new maintainers.

* Modernize tests
* Add Travis CI monitoring
* Support varint-encoded length-delimited buffers
* Support generation with recursive definitions
* Support Ruby 2.0
* Support encoded buffers
* Support false but non-nil values
* Support top-level enums, added by Kim Altintop:
  https://github.com/protobuf-ruby/beefcake/pull/23
