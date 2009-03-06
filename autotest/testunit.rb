require 'autotest'

class Autotest::Testunit < Autotest
  def initialize # :nodoc:
    super
    @exceptions = /^\.\/(?:config|doc|log|tmp|website)/

    @test_mappings = {
      %r%^test/.*\.rb$% => proc { |filename, _|
        filename
      },
      %r%^lib/(.*)\.rb$% => proc { |_, m|
        ["test/#{m[1]}_test.rb"]
      },
      %r%^test/test_helper.rb$% => proc {
        files_matching %r%^test/.*_test\.rb$%
      },
    }
  end

  # Given the string filename as the path, determine
  # the corresponding tests for it, in an array.
  def tests_for_file(filename)
    super.select { |f| @files.has_key? f }
  end
end