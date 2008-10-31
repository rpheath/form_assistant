%w(error builder collector helpers).each do |f|
  require File.join(File.dirname(__FILE__), 'form_assistant', f)
end

# FormAssistant is a module that mixes into the FormBuilder class. It
# provides for a very simple way to extend the functionality of forms
#
# This is currently somewhat tailored to how I personally use forms -
# The idea is that the public methods should be modified (or added/removed)
# to accommodate how you use forms in Rails. Of course, feel free to adopt
# my patterns that I've laid out here.
module RPH
  module FormAssistant
    class FormBuilder < ActionView::Helpers::FormBuilder
      include RPH::FormAssistant::Helpers
      cattr_accessor :wrap_fields_with_paragraph_tag
      
      # set to true if you want the <label> and the <field>
      # to be automatically wrapped in a <p> tag
      # 
      # Note: this can be set in config/initializers/form_assistant.rb ...
      #   RPH::FormAssistant::FormBuilder.wrap_fields_with_paragraph_tag = true
      wrap_fields_with_paragraph_tag = false
      
    public
      (field_helpers + 
        %w(date_select datetime_select time_select collection_select select country_select time_zone_select) - 
        %w(hidden_field label fields_for)).each do |name|
          define_method(name) do |field, *args|
            # pull out the options
            options = args.detect { |arg| arg.is_a?(Hash) } || {}
            
            options[:label] ||= {}
            # allow for a more convenient way to set common label options
            %w(text class).each do |option|
              label_option = "label_#{option}".to_sym
              options[:label].merge!(option.to_sym => options.delete(label_option)) if options[label_option]
            end
            
            # return the fields
            label_with_field = label(field, options[:label].delete(:text), options.delete(:label)) + super
            wrap_fields_with_paragraph_tag ? @template.content_tag(:p, label_with_field) : label_with_field
          end
        end
    end
  end   
end