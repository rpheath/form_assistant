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
    
    private
      def label_for(field, options)
        label(field, options.delete(:text), options)
      end
      
    public
      (field_helpers + 
        %w(date_select datetime_select time_select collection_select select country_select time_zone_select) - 
        %w(hidden_field label fields_for)).each do |name|
          define_method(name) do |field, *args|
            options = args.detect { |arg| arg.is_a?(Hash) } || {}
            # allow for a more convenient way to set custom label text
            (options[:label] ||= {}).merge!({:text => options[:label_text]}) if options[:label_text]
            
            # return the fields
            label_with_field = label_for(field, options.delete(:label) || {}) + super
            wrap_fields_with_paragraph_tag ? @template.content_tag(:p, label_with_field) : label_with_field
          end
        end
    end
  end   
end