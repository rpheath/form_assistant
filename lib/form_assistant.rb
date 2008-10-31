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
    class Buildee < ActionView::Helpers::FormBuilder
      include RPH::FormAssistant::Helpers
      
      (field_helpers + 
        %w(date_select datetime_select time_select collection_select select country_select time_zone_select) - 
        %w(hidden_field label fields_for)).each do |name|
          define_method(name) do |field, *args|
            options = args.last.is_a?(Hash) ? args.pop : {}
            @template.content_tag(:p, label(field) + super)
          end
        end
    end
  end   
end