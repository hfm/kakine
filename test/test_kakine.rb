require 'minitest_helper'

class TestKakine < Minitest::Test
  def test_that_it_has_a_version_number
    refute_nil ::Kakine::VERSION
  end
end
