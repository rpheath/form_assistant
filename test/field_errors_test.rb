require 'test_helper'

class FieldErrorsTest < ActiveSupport::TestCase
  def setup
    @errors = RPH::FormAssistant::FieldErrors.new(%w(A B C))
  end
  
  test "should return errors as sentence" do
    assert_equal 'A, B, and C', @errors.to_s
  end
  
  test "should return errors with breaks" do
    assert_equal 'A<br />B<br />C', @errors.to_s(:break => true)
  end
  
  test "should return errors as list" do
    assert_equal '<ul class="errors"><li>A</li><li>B</li><li>C</li></ul>',
      @errors.to_list
  end

  test "should return errors as list with custom class" do
    assert_equal '<ul class="problems"><li>A</li><li>B</li><li>C</li></ul>',
      @errors.to_list(:class => 'problems')
  end
end