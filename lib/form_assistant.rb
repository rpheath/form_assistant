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
    # custom form builder
    class FormBuilder < ActionView::Helpers::FormBuilder
      include RPH::FormAssistant::Helpers
      class_inheritable_accessor :wrap_fields_with_paragraph_tag
      
      # set to true if you want the <label> and the <field>
      # to be automatically wrapped in a <p> tag
      # 
      # Note: this can be set in config/initializers/form_assistant.rb ...
      #   RPH::FormAssistant::FormBuilder.wrap_fields_with_paragraph_tag = true
      self.wrap_fields_with_paragraph_tag = false
      
    public
      send(:form_helpers).each do |name|
        define_method name do |field, *args|
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
          self.class.wrap_fields_with_paragraph_tag ? @template.content_tag(:p, label_with_field) : label_with_field
        end
      end
    end
    
    class InlineErrorFormBuilder < FormBuilder
      # override the field_error_proc so that it no longer wraps the field
      # with <div class="fieldWithErrors">...</div>, but just returns the field
      ActionView::Base.field_error_proc = Proc.new { |html_tag, instance| html_tag }
      
      # ensure that fields are NOT wrapped with <p> tags 
      # (handle that in forms/_partials)
      self.wrap_fields_with_paragraph_tag = false
      
    private
      # get the error messages (if any) for a field
      def error_message(field)
        return unless has_errors?(field)
        errors = object.errors.on(field)
        errors.is_a?(Array) ? errors.to_sentence : errors
      end
      
      # returns true if that field is invalid or the object is missing
      def has_errors?(field)
        !(object.nil? || object.errors.on(field).blank?)
      end
    
    public
      # redefining FormBuilder's methods
      send(:form_helpers).each do |name|
        define_method name do |field, *args|
          render_partial_for(field) { super }
        end
      end
      
      # render the appropriate partial based on whether or not
      # the field has any errors
      def render_partial_for(field)
        @template.capture do
          locals = { :field_with_label => yield }
          
          if has_errors?(field)
            locals.merge! :errors => error_message(field)
            @template.render :partial => 'forms/field_with_errors', :locals => locals
          else
            @template.render :partial => 'forms/field_without_errors', :locals => locals
          end
        end
      end
    end
  end   
end