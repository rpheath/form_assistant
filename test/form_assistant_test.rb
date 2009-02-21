require 'test_helper'

module FormAssistantHelpers
  attr_accessor :render_options
  def render(options={})
    self.render_options = options
    String.new
  end

  def locals
    render_options[:locals] rescue {}
  end

  def expect_render(expected={})
    assert_hash_includes expected, render_options
  end
  
  def assert_hash_includes(expected, actual)
    expected.each do |k, v|
      assert_equal v, actual[k]
    end  
  end

  def expect_locals(expected={})
    assert_hash_includes expected, locals
  end    

  def template_root
    RPH::FormAssistant::FormBuilder.template_root
  end
  
  def template_path(name)
    File.join(template_root, name) + '.html.erb'
  end
end

class AddressBook < ActiveRecord::Base
  attr_accessor *%w(first_name nickname)
  
  def self.columns
    Hash.new
  end
end

class FormAssistantTest < ActionView::TestCase
  include FormAssistantHelpers
  include ::RPH::FormAssistant::ActionView
  attr_accessor :form

  def setup
    @address_book = AddressBook.new
    # @address_book = OpenStruct.new
    # @address_book.stubs(:errors).returns(@errors ||= ActiveRecord::Errors.new(@address_book))
    @form = RPH::FormAssistant::FormBuilder.new(:address_book, @address_book, self, {}, nil)
    RPH::FormAssistant::FormBuilder.template_root = File.expand_path(File.join(File.dirname(__FILE__), '../forms'))
  end
  
  test "should use template based on input type" do
    form.text_field :first_name
    expect_render :partial => template_path('text_field')
  end
  
  test "should use fallback template if no specific template is found" do
    form.text_field :first_name, :template => 'fancy_template_that_does_not_exist'
    expect_render :partial => template_path(form.fallback_template)
  end
  
  test "should render a valid field" do
    form.text_field :first_name
    expect_locals :errors => nil
  end
  
  test "should render an invalid field" do
    @address_book.errors.add(:first_name, 'cannot be root')
    form.text_field :first_name
    expect_locals :errors => ['First name cannot be root']
    assert_kind_of RPH::FormAssistant::FieldErrors, locals[:errors]
  end
  
  test "should render a field with a tip" do
    form.text_field :nickname, :tip => 'What should we call you?'
    expect_locals :tip => 'What should we call you?' 
  end
  
  test "should render a field without a template" do
    result = form.text_field(:nickname, :template => false)
    assert_equal text_field(:address_book, :nickname), result
  end
  
  test "should create fieldset" do
    fieldset('Information') { "fields-go-here" }
    expect_render :partial => template_path('fieldset')
    expect_locals :legend => 'Information',
      :fields => 'fields-go-here'
  end
  
  test "should support I18n if available" do
    if Object.const_defined?(:I18n)
      I18n.backend = I18n::Backend::Simple.new
      I18n.backend.store_translations 'en', :activerecord => {
        :attributes => { 
          :address_book => {
            :first_name => 'Given name'
          } 
        } 
      }
      
      @address_book.errors.add(:first_name, 'cannot be root')
      @address_book.errors.add(:first_name, 'cannot be admin')
      form.text_field :first_name
      expect_locals :errors => ['Given name cannot be root', 'Given name cannot be admin']
    end
  end
  
  test "should massage error messages when I18n isn't not available" do
    RPH::FormAssistant::Rules.expects(:has_I18n_support?).returns(false)
    @address_book.errors.add(:first_name, 'cannot be root')
    @address_book.errors.add(:first_name, 'cannot be admin')
    form.text_field :first_name
    expect_locals :errors => ['First name cannot be root and cannot be admin']
  end
end